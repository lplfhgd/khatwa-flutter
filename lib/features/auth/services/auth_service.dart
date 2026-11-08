import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await _ensureParentProfile(credential.user);
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final cleanedName = fullName.trim();
    final cleanedEmail = email.trim();

    if (cleanedName.isEmpty) {
      throw StateError('الاسم الكامل مطلوب.');
    }

    final credential = await _auth.createUserWithEmailAndPassword(
      email: cleanedEmail,
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw StateError('تعذر الحصول على بيانات المستخدم.');
    }

    // حفظ الاسم أيضًا داخل Firebase Authentication.
    await user.updateDisplayName(cleanedName);

    // إنشاء ملف ولي الأمر في Firestore وحفظ الاسم الحقيقي.
    await _firestore.collection('parents').doc(user.uid).set({
      'fullName': cleanedName,
      'email': user.email ?? cleanedEmail,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'profileStatus': 'active',
    });
  }

  Future<void> _ensureParentProfile(User? user) async {
    if (user == null) {
      throw StateError('تعذر الحصول على بيانات المستخدم.');
    }

    final parentRef = _firestore.collection('parents').doc(user.uid);
    final snapshot = await parentRef.get();

    if (!snapshot.exists) {
      await parentRef.set({
        'fullName': user.displayName?.trim() ?? '',
        'email': user.email ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'profileStatus': 'active',
      });

      return;
    }

    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final displayName = user.displayName?.trim();

    if (displayName != null && displayName.isNotEmpty) {
      updates['fullName'] = displayName;
    }

    if (user.email != null && user.email!.trim().isNotEmpty) {
      updates['email'] = user.email!.trim();
    }

    await parentRef.set(
      updates,
      SetOptions(merge: true),
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;

    if (user == null || user.isAnonymous) {
      throw StateError('لا يوجد حساب ولي أمر مسجل حاليًا.');
    }

    final email = user.email;

    if (email == null || email.trim().isEmpty) {
      throw StateError('لا يوجد بريد إلكتروني مرتبط بالحساب.');
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  Future<void> resetPassword(String email) {
    return _auth.sendPasswordResetEmail(
      email: email.trim(),
    );
  }

  Future<void> signOut() {
    return _auth.signOut();
  }
}