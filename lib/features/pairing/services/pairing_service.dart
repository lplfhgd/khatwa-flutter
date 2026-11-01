import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/linked_child_model.dart';
import '../models/pairing_model.dart';

class PairingService {
  PairingService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _pairingCodes =>
      _firestore.collection('pairingCodes');

  String _generateCode() {
    final random = Random.secure();
    return (100000 + random.nextInt(900000)).toString();
  }

  Future<PairingModel> createPairingCode({
    required String childId,
    required String childName,
  }) async {
    final user = _auth.currentUser;

    if (user == null || user.isAnonymous) {
      throw StateError('يجب تسجيل دخول ولي الأمر أولًا.');
    }

    final normalizedChildId = childId.trim();
    final normalizedChildName = childName.trim();

    if (normalizedChildId.isEmpty) {
      throw StateError('يجب اختيار طفل أولًا.');
    }

    if (normalizedChildName.isEmpty) {
      throw StateError('اسم الطفل غير صالح.');
    }

    final childRef = _firestore
        .collection('parents')
        .doc(user.uid)
        .collection('children')
        .doc(normalizedChildId);

    final childSnapshot = await childRef.get();

    if (!childSnapshot.exists) {
      throw StateError('لم يتم العثور على ملف الطفل.');
    }

    for (var attempt = 0; attempt < 5; attempt++) {
      final code = _generateCode();
      final pairingRef = _pairingCodes.doc(code);

      final expiresAt = DateTime.now().add(
        const Duration(minutes: 10),
      );

      try {
        await pairingRef.set({
          'parentId': user.uid,
          'childId': normalizedChildId,
          'childName': normalizedChildName,
          'used': false,
          'createdAt': FieldValue.serverTimestamp(),
          'expiresAt': Timestamp.fromDate(expiresAt),
          'claimedBy': null,
          'claimedAt': null,
        });

        return PairingModel(
          code: code,
          parentId: user.uid,
          childId: normalizedChildId,
          childName: normalizedChildName,
          expiresAt: expiresAt,
          used: false,
        );
      } on FirebaseException catch (error) {
        // إذا كان الرمز موجودًا مسبقًا، فإن set تصبح update.
        // قواعد Firestore تمنع ولي الأمر من تحديث رمز موجود،
        // لذلك نجرب رقمًا جديدًا.
        if (error.code == 'permission-denied') {
          continue;
        }

        if (attempt == 4) {
          throw StateError('تعذر إنشاء رمز الربط. حاول مجددًا.');
        }
      }
    }

    throw StateError('تعذر إنشاء رمز ربط فريد. حاول مجددًا.');
  }

  Future<LinkedChildModel> consumePairingCode(String code) async {
    final normalizedCode = code.trim();

    if (!RegExp(r'^\d{6}$').hasMatch(normalizedCode)) {
      throw StateError('رمز الربط يجب أن يتكون من 6 أرقام.');
    }

    var user = _auth.currentUser;

    if (user == null) {
      final credential = await _auth.signInAnonymously();
      user = credential.user;
    }

    if (user == null) {
      throw StateError('تعذر تهيئة جهاز الطفل.');
    }

    if (!user.isAnonymous) {
      throw StateError('يجب استخدام حساب جهاز الطفل لإتمام الربط.');
    }

    final pairingRef = _pairingCodes.doc(normalizedCode);

    try {
      final linkedChild = await _firestore
          .runTransaction<LinkedChildModel>((transaction) async {
        final snapshot = await transaction.get(pairingRef);

        if (!snapshot.exists) {
          throw StateError('رمز الربط غير صحيح.');
        }

        final data = snapshot.data();

        if (data == null) {
          throw StateError('بيانات الربط غير صالحة.');
        }

        final used = data['used'] == true;
        final expiresAt = data['expiresAt'];

        if (used) {
          throw StateError('تم استخدام رمز الربط مسبقًا.');
        }

        if (expiresAt is! Timestamp) {
          throw StateError('بيانات صلاحية الرمز غير صالحة.');
        }

        if (expiresAt.toDate().isBefore(DateTime.now())) {
          throw StateError('انتهت صلاحية رمز الربط.');
        }

        final parentId = data['parentId'];
        final childId = data['childId'];
        final childName = data['childName'];

        if (parentId is! String ||
            parentId.isEmpty ||
            childId is! String ||
            childId.isEmpty ||
            childName is! String ||
            childName.isEmpty) {
          throw StateError('بيانات الربط غير صالحة.');
        }

        transaction.update(pairingRef, {
          'used': true,
          'claimedBy': user!.uid,
          'claimedAt': FieldValue.serverTimestamp(),
        });

        return LinkedChildModel(
          parentId: parentId,
          childId: childId,
          childName: childName,
        );
      });

      return linkedChild;
    } on FirebaseException catch (error) {
      if (error.code == 'permission-denied') {
        throw StateError(
          'رمز الربط غير صالح أو انتهت صلاحيته.',
        );
      }

      throw StateError(
        'تعذر إتمام الربط. حاول مجددًا.',
      );
    }
  }
}
