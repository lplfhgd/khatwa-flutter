import 'package:cloud_firestore/cloud_firestore.dart';

class ChildModel {
  const ChildModel({
    required this.id,
    required this.name,
    this.birthYear,
  });

  final String id;
  final String name;
  final int? birthYear;

  factory ChildModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? <String, dynamic>{};

    return ChildModel(
      id: document.id,
      name: data['name'] is String ? data['name'] as String : 'طفل',
      birthYear: data['birthYear'] is int ? data['birthYear'] as int : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'birthYear': birthYear,
    };
  }
}
