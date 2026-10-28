import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      email: email,
      password: password,
    );

    await _ensureParentProfile(credential.user);
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _ensureParentProfile(credential.user);
  }

  Future<void> _ensureParentProfile(User? user) async {
    if (user == null) {
      throw StateError('تعذر الحصول على بيانات المستخدم.');
    }

    final parentRef = _firestore.collection('parents').doc(user.uid);
    final snapshot = await parentRef.get();

    if (!snapshot.exists) {
      await parentRef.set({
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'profileStatus': 'active',
      });
    }
  }

  Future<void> resetPassword(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() {
    return _auth.signOut();
  }
}
