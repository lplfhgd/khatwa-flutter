import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/routine_model.dart';

class RoutineService {
  RoutineService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const String _collection = 'routines';

  String get _uid {
    final user = _auth.currentUser;

    if (user == null || user.isAnonymous) {
      throw StateError('يجب تسجيل الدخول كولي أمر.');
    }

    return user.uid;
  }

  Stream<List<RoutineModel>> watchRoutine(String childId) {
    final cleanedChildId = childId.trim();

    if (cleanedChildId.isEmpty) {
      return Stream.value(const <RoutineModel>[]);
    }

    final uid = _uid;

    return _firestore
        .collection(_collection)
        .doc(cleanedChildId)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();

      if (data == null) {
        return const <RoutineModel>[];
      }

      if (data['parentId'] != uid || data['childId'] != cleanedChildId) {
        return const <RoutineModel>[];
      }

      final rawItems = data['items'];

      if (rawItems is! List) {
        return const <RoutineModel>[];
      }

      final items = rawItems
          .whereType<Map>()
          .map(
            (item) => RoutineModel.fromMap(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();

      items.sort((a, b) => a.time.compareTo(b.time));

      return items;
    });
  }

  Future<void> saveRoutine(
    String childId,
    List<RoutineModel> items,
  ) async {
    final cleanedChildId = childId.trim();

    if (cleanedChildId.isEmpty) {
      throw ArgumentError('لم يتم اختيار طفل.');
    }

    final uid = _uid;

    await _firestore.collection(_collection).doc(cleanedChildId).set({
      'parentId': uid,
      'childId': cleanedChildId,
      'items': items.map((item) => item.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
