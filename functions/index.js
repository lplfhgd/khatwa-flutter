const {setGlobalOptions} = require("firebase-functions/v2");
const {onCall, HttpsError} = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const crypto = require("crypto");

admin.initializeApp();

setGlobalOptions({
  maxInstances: 10,
});

const db = admin.firestore();

/**
 * Generates a secure six-digit pairing code.
 * @return {string} The generated pairing code.
 */
function generatePairingCode() {
  return crypto.randomInt(100000, 1000000).toString();
}

exports.createPairingCode = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError(
        "unauthenticated",
        "Parent must be signed in.",
    );
  }

  const parentId = request.auth.uid;

  const rawChildId = request.data && request.data.childId;
  const childId = typeof rawChildId === "string" ?
    rawChildId.trim() :
    "";

  if (childId.length === 0) {
    throw new HttpsError(
        "invalid-argument",
        "Child ID is required.",
    );
  }

  const childRef = db
      .collection("parents")
      .doc(parentId)
      .collection("children")
      .doc(childId);

  const childSnapshot = await childRef.get();

  if (!childSnapshot.exists) {
    throw new HttpsError(
        "not-found",
        "Child was not found.",
    );
  }

  const childData = childSnapshot.data();
  const childName =
    typeof childData.name === "string" ?
      childData.name.trim() :
      "";

  if (childName.length === 0) {
    throw new HttpsError(
        "failed-precondition",
        "Child data is incomplete.",
    );
  }

  const expiresAt = admin.firestore.Timestamp.fromMillis(
      Date.now() + (10 * 60 * 1000),
  );

  for (let attempt = 0; attempt < 5; attempt++) {
    const code = generatePairingCode();
    const pairingRef = db.collection("pairingCodes").doc(code);

    try {
      await pairingRef.create({
        parentId,
        childId,
        childName,
        used: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        expiresAt,
      });

      return {
        code,
        childId,
        childName,
        expiresAt: expiresAt.toMillis(),
      };
    } catch (error) {
      if (error.code === 6 || error.code === "already-exists") {
        continue;
      }

      console.error("Failed to create pairing code:", error);

      throw new HttpsError(
          "internal",
          "Failed to create pairing code.",
      );
    }
  }

  throw new HttpsError(
      "resource-exhausted",
      "Could not generate a unique pairing code.",
  );
});

exports.consumePairingCode = onCall(async (request) => {
  const rawCode = request.data && request.data.code;
  const code = typeof rawCode === "string" ? rawCode.trim() : "";

  if (!/^\d{6}$/.test(code)) {
    throw new HttpsError(
        "invalid-argument",
        "Pairing code must contain exactly 6 digits.",
    );
  }

  const pairingRef = db.collection("pairingCodes").doc(code);

  const result = await db.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(pairingRef);

    if (!snapshot.exists) {
      throw new HttpsError(
          "not-found",
          "Pairing code was not found.",
      );
    }

    const data = snapshot.data();

    if (data.used === true) {
      throw new HttpsError(
          "failed-precondition",
          "Pairing code has already been used.",
      );
    }

    const expiresAt = data.expiresAt;

    if (!expiresAt || typeof expiresAt.toMillis !== "function") {
      throw new HttpsError(
          "failed-precondition",
          "Pairing code has an invalid expiration time.",
      );
    }

    if (expiresAt.toMillis() <= Date.now()) {
      throw new HttpsError(
          "deadline-exceeded",
          "Pairing code has expired.",
      );
    }

    const parentId = data.parentId;
    const childId = data.childId;
    const childName = data.childName;

    if (
      typeof parentId !== "string" ||
      parentId.length === 0 ||
      typeof childId !== "string" ||
      childId.length === 0 ||
      typeof childName !== "string" ||
      childName.length === 0
    ) {
      throw new HttpsError(
          "failed-precondition",
          "Pairing data is incomplete.",
      );
    }

    transaction.update(pairingRef, {
      used: true,
      usedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      parentId,
      childId,
      childName,
    };
  });

  return result;
});
