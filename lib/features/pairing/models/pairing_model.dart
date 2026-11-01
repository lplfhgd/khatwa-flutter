import 'package:cloud_firestore/cloud_firestore.dart';

class PairingModel {
  const PairingModel({
    required this.code,
    required this.parentId,
    required this.childId,
    required this.childName,
    required this.expiresAt,
    required this.used,
  });

  final String code;
  final String parentId;
  final String childId;
  final String childName;
  final DateTime expiresAt;
  final bool used;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  factory PairingModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? <String, dynamic>{};

    return PairingModel(
      code: document.id,
      parentId: data['parentId'] as String? ?? '',
      childId: data['childId'] as String? ?? '',
      childName: data['childName'] as String? ?? '',
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      used: data['used'] as bool? ?? false,
    );
  }
}
