import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../aac/controllers/aac_controller.dart';
import '../../routine/controllers/routine_controller.dart';
import '../../../shared/widgets/k_card.dart';

class ParentProgress extends StatelessWidget {
  const ParentProgress({super.key});

  @override
  Widget build(BuildContext context) {
    final routineController = Get.find<RoutineController>();
    final aacController = Get.find<AacController>();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'تقرير الأنشطة',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'هذا عرض تجريبي لمتابعة إنجاز الأنشطة، وليس تقييمًا أو تشخيصًا طبيًا.',
        ),
        const SizedBox(height: 24),
        Obx(() {
          final completed = routineController.completedCount;
          final total = routineController.routine.length;

          return KCard(
            child: Column(
              children: [
                const Icon(
                  Icons.insights,
                  color: Color(0xFF168F8B),
                  size: 50,
                ),
                const SizedBox(height: 12),
                Text(
                  '$completed / $total',
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text('خطوات الروتين المنجزة'),
                const SizedBox(height: 15),
                LinearProgressIndicator(
                  value: routineController.progress,
                  minHeight: 12,
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 15),
        Obx(() {
          final cardCount = aacController.cards.length;

          return KCard(
            child: Column(
              children: [
                const Text(
                  'بطاقات التواصل المتاحة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$cardCount',
                  style: const TextStyle(
                    fontSize: 36,
                    color: Color(0xFF168F8B),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
