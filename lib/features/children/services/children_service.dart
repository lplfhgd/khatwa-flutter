import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/child_model.dart';

class ChildrenService {
  ChildrenService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> _childrenCollection() {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('يجب تسجيل دخول ولي الأمر أولًا.');
    }

    return _firestore
        .collection('parents')
        .doc(user.uid)
        .collection('children');
  }

  Stream<List<ChildModel>> watchChildren() {
    return _childrenCollection().snapshots().map((snapshot) {
      final children = snapshot.docs.map(ChildModel.fromFirestore).toList();

      children.sort((a, b) => a.name.compareTo(b.name));

      return children;
    });
  }

  Future<ChildModel> addChild({
    required String name,
    int? birthYear,
    required ChildGender gender,
    required CommunicationMethod communicationMethod,
    required Set<SensoryPreference> sensoryPreferences,
    required Set<DailyGoal> goals,
    required LessonUnit lessonUnit,
  }) async {
    final collection = _childrenCollection();
    final ref = collection.doc();

    final child = ChildModel(
      id: ref.id,
      name: name.trim(),
      birthYear: birthYear,
      gender: gender,
      communicationMethod: communicationMethod,
      sensoryPreferences: sensoryPreferences,
      goals: goals,
      lessonUnit: lessonUnit,
    );

    await ref.set({
      ...child.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return child;
  }

  Future<void> updateChild({
    required String childId,
    required String name,
    int? birthYear,
    required ChildGender gender,
    required CommunicationMethod communicationMethod,
    required Set<SensoryPreference> sensoryPreferences,
    required Set<DailyGoal> goals,
    required LessonUnit lessonUnit,
  }) async {
    await _childrenCollection().doc(childId).update({
      'name': name.trim(),
      'birthYear': birthYear,
      'gender': gender.name,
      'communicationMethod': communicationMethod.name,
      'sensoryPreferences':
          sensoryPreferences.map((item) => item.name).toList(),
      'goals': goals.map((item) => item.name).toList(),
      'lessonUnit': lessonUnit.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
