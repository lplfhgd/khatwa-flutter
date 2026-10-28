import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/aac_model.dart';

class AacController extends GetxController {
  final cards = <AacModel>[
    const AacModel(
      id: 'water',
      label: 'أريد ماء',
      symbol: Icons.water_drop_outlined,
      category: 'الاحتياجات',
    ),
    const AacModel(
      id: 'food',
      label: 'أريد طعام',
      symbol: Icons.restaurant_outlined,
      category: 'الاحتياجات',
    ),
    const AacModel(
      id: 'help',
      label: 'أحتاج مساعدة',
      symbol: Icons.volunteer_activism_outlined,
      category: 'الاحتياجات',
    ),
    const AacModel(
      id: 'break',
      label: 'أريد استراحة',
      symbol: Icons.self_improvement_outlined,
      category: 'الاحتياجات',
    ),
    const AacModel(
      id: 'happy',
      label: 'أنا سعيد',
      symbol: Icons.sentiment_satisfied_alt_outlined,
      category: 'المشاعر',
    ),
    const AacModel(
      id: 'sad',
      label: 'أنا حزين',
      symbol: Icons.sentiment_dissatisfied_outlined,
      category: 'المشاعر',
    ),
  ].obs;

  void addCard(String label) {
    final cleaned = label.trim();

    if (cleaned.isEmpty) return;

    final card = AacModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      label: cleaned,
      symbol: Icons.chat_bubble_outline,
      category: 'مخصص',
    );

    cards.add(card);
  }
}
