import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../aac/controllers/aac_controller.dart';
import '../../../shared/widgets/k_button.dart';
import '../../../shared/widgets/k_card.dart';

class ParentContent extends StatelessWidget {
  const ParentContent({
    super.key,
    required this.onAddAacCard,
    required this.onOpenRoutine,
  });

  final VoidCallback onAddAacCard;
  final VoidCallback onOpenRoutine;

  @override
  Widget build(BuildContext context) {
    final aacController = Get.find<AacController>();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'محتوى طفلك',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'أضف بطاقات التواصل والروتينات التي يحتاجها طفلك.',
        ),
        const SizedBox(height: 20),
        KButton(
          label: 'إضافة بطاقة تواصل',
          onPressed: onAddAacCard,
        ),
        const SizedBox(height: 12),
        Obx(() {
          final cards = aacController.cards;

          return Column(
            children: cards.map((card) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: KCard(
                  child: ListTile(
                    leading: Icon(
                      card.symbol,
                      color: const Color(0xFF168F8B),
                      size: 32,
                    ),
                    title: Text(card.label),
                    subtitle: Text(card.category),
                  ),
                ),
              );
            }).toList(),
          );
        }),
        const SizedBox(height: 10),
        KButton(
          label: 'إدارة الروتين اليومي',
          outlined: true,
          onPressed: onOpenRoutine,
        ),
        const SizedBox(height: 16),
        const KCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'القصص والألعاب',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'شاشات تجريبية مبدئية؛ إدارة المحتوى التفصيلية ستُضاف في المرحلة التالية.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
