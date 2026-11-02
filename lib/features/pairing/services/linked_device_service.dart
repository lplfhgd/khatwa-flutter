import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/linked_child_model.dart';

class LinkedDeviceService {
  LinkedDeviceService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // ============================================================
  // Child device
  // ============================================================

  Future<bool> isDeviceActive(LinkedChildModel child) async {
    final user = _auth.currentUser;

    if (user == null || !user.isAnonymous) {
      return false;
    }

    final deviceRef = _firestore
        .collection('parents')
        .doc(child.parentId)
        .collection('children')
        .doc(child.childId)
        .collection('linkedDevices')
        .doc(user.uid);

    try {
      final snapshot = await deviceRef.get();

      if (!snapshot.exists) {
        return false;
      }

      final data = snapshot.data();

      if (data == null) {
        return false;
      }

      return data['active'] == true;
    } on FirebaseException catch (error) {
      if (error.code == 'permission-denied') {
        return false;
      }

      rethrow;
    }
  }

  // ============================================================
  // Parent device management
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> watchLinkedDevices(
    String childId,
  ) {
    final user = _auth.currentUser;

    if (user == null || user.isAnonymous) {
      throw StateError('يجب تسجيل دخول ولي الأمر أولًا.');
    }

    final normalizedChildId = childId.trim();

    if (normalizedChildId.isEmpty) {
      throw StateError('يجب اختيار طفل أولًا.');
    }

    return _firestore
        .collection('parents')
        .doc(user.uid)
        .collection('children')
        .doc(normalizedChildId)
        .collection('linkedDevices')
        .snapshots();
  }

  Future<void> revokeDevice({
    required String childId,
    required String deviceId,
  }) async {
    final user = _auth.currentUser;

    if (user == null || user.isAnonymous) {
      throw StateError('يجب تسجيل دخول ولي الأمر أولًا.');
    }

    final normalizedChildId = childId.trim();
    final normalizedDeviceId = deviceId.trim();

    if (normalizedChildId.isEmpty) {
      throw StateError('يجب اختيار طفل أولًا.');
    }

    if (normalizedDeviceId.isEmpty) {
      throw StateError('معرّف الجهاز غير صالح.');
    }

    final deviceRef = _firestore
        .collection('parents')
        .doc(user.uid)
        .collection('children')
        .doc(normalizedChildId)
        .collection('linkedDevices')
        .doc(normalizedDeviceId);

    final snapshot = await deviceRef.get();

    if (!snapshot.exists) {
      throw StateError('لم يتم العثور على الجهاز المرتبط.');
    }

    await deviceRef.update({
      'active': false,
    });
  }
}
