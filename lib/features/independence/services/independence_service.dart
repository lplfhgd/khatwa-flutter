import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/independence_model.dart';

class IndependenceService {
  IndependenceService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _uid {
    final user = _auth.currentUser;

    if (user == null || user.isAnonymous) {
      throw StateError('Parent authentication is required.');
    }

    return user.uid;
  }

  DocumentReference<Map<String, dynamic>> _document(String childId) {
    return _firestore
        .collection('parents')
        .doc(_uid)
        .collection('children')
        .doc(childId)
        .collection('development')
        .doc('independence');
  }

  Stream<List<IndependenceArea>> watchAreas(String childId) {
    final cleanedChildId = childId.trim();

    if (cleanedChildId.isEmpty) {
      return Stream.value(const <IndependenceArea>[]);
    }

    return _document(cleanedChildId).snapshots().map((snapshot) {
      final data = snapshot.data();

      if (data == null) {
        return defaultAreas;
      }

      final rawAreas = data['areas'];

      if (rawAreas is! List) {
        return defaultAreas;
      }

      return rawAreas
          .whereType<Map>()
          .map(
            (area) => IndependenceArea.fromMap(
              Map<String, dynamic>.from(area),
            ),
          )
          .toList();
    });
  }

  Future<void> saveAreas(
    String childId,
    List<IndependenceArea> areas,
  ) async {
    final cleanedChildId = childId.trim();

    if (cleanedChildId.isEmpty) {
      throw ArgumentError('Child id is required.');
    }

    await _document(cleanedChildId).set({
      'parentId': _uid,
      'childId': cleanedChildId,
      'areas': areas.map((area) => area.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static const List<IndependenceArea> defaultAreas = [
    IndependenceArea(
      id: 'self_care',
      title: 'العناية الذاتية',
      icon: '🧼',
      skills: [
        IndependenceSkill(
          id: 'wash_face',
          title: 'غسل الوجه',
        ),
        IndependenceSkill(
          id: 'brush_teeth',
          title: 'تنظيف الأسنان',
        ),
        IndependenceSkill(
          id: 'get_dressed',
          title: 'ارتداء الملابس',
        ),
        IndependenceSkill(
          id: 'wear_shoes',
          title: 'ارتداء الحذاء',
        ),
      ],
    ),
    IndependenceArea(
      id: 'food_drink',
      title: 'الطعام والشراب',
      icon: '🍽️',
      skills: [
        IndependenceSkill(
          id: 'eat_independently',
          title: 'تناول الطعام',
        ),
        IndependenceSkill(
          id: 'drink_independently',
          title: 'الشرب من الكوب',
        ),
        IndependenceSkill(
          id: 'use_spoon',
          title: 'استخدام الملعقة',
        ),
        IndependenceSkill(
          id: 'clean_after_eating',
          title: 'ترتيب مكانه بعد الطعام',
        ),
      ],
    ),
    IndependenceArea(
      id: 'communication',
      title: 'التواصل',
      icon: '💬',
      skills: [
        IndependenceSkill(
          id: 'request_need',
          title: 'التعبير عن احتياجاته',
        ),
        IndependenceSkill(
          id: 'choose_option',
          title: 'الاختيار بين بديلين',
        ),
        IndependenceSkill(
          id: 'ask_for_help',
          title: 'طلب المساعدة',
        ),
        IndependenceSkill(
          id: 'express_refusal',
          title: 'التعبير عن الرفض',
        ),
      ],
    ),
    IndependenceArea(
      id: 'daily_routine',
      title: 'الروتين اليومي',
      icon: '🗓️',
      skills: [
        IndependenceSkill(
          id: 'follow_morning_routine',
          title: 'اتباع روتين الصباح',
        ),
        IndependenceSkill(
          id: 'prepare_belongings',
          title: 'تجهيز أغراضه',
        ),
        IndependenceSkill(
          id: 'move_between_tasks',
          title: 'الانتقال بين المهام',
        ),
        IndependenceSkill(
          id: 'finish_task',
          title: 'إكمال المهمة المطلوبة',
        ),
      ],
    ),
  ];
}
