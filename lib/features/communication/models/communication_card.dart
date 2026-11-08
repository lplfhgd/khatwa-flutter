import 'package:cloud_firestore/cloud_firestore.dart';

class CommunicationCard {
  const CommunicationCard({
    required this.id,
    required this.parentId,
    required this.childId,
    required this.label,
    required this.imageUrl,
    required this.imagePublicId,
    required this.audioUrl,
    required this.audioPublicId,
    required this.createdAt,
  });

  final String id;
  final String parentId;
  final String childId;
  final String label;
  final String imageUrl;
  final String imagePublicId;
  final String audioUrl;
  final String audioPublicId;
  final DateTime createdAt;

  factory CommunicationCard.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};

    return CommunicationCard(
      id: doc.id,
      parentId: data['parentId'] as String? ?? '',
      childId: data['childId'] as String? ?? '',
      label: data['label'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      imagePublicId: data['imagePublicId'] as String? ?? '',
      audioUrl: data['audioUrl'] as String? ?? '',
      audioPublicId: data['audioPublicId'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
