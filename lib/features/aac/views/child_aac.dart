import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/k_colors.dart';
import '../controllers/aac_controller.dart';

class ChildAac extends StatelessWidget {
  const ChildAac({super.key});

  @override
  Widget build(BuildContext context) {
    final aacController = Get.find<AacController>();

    return Obx(() {
      final cards = aacController.cards;

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'أتواصل',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'اختر ما تريد قوله',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.95,
            ),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];

              return InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'اخترت: ${card.label} • النطق الصوتي سيُضاف لاحقًا',
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        index.isEven ? KColors.soft : const Color(0xFFFFF1D0),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        card.symbol,
                        size: 66,
                        color: KColors.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        card.label,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      );
    });
  }
}
