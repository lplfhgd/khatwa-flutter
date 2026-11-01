import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/k_colors.dart';
import '../../../shared/widgets/k_button.dart';
import '../../../shared/widgets/k_card.dart';
import '../controllers/routine_controller.dart';

class ParentRoutineScreen extends StatelessWidget {
  const ParentRoutineScreen({
    super.key,
    required this.onAddRoutine,
  });

  final VoidCallback onAddRoutine;

  @override
  Widget build(BuildContext context) {
    final routineController = Get.find<RoutineController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الروتين'),
      ),
      body: Obx(() {
        final tasks = routineController.routine;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            KButton(
              label: 'إضافة خطوة للروتين',
              onPressed: onAddRoutine,
            ),
            const SizedBox(height: 15),
            ...tasks.asMap().entries.map((entry) {
              final index = entry.key;
              final task = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: KCard(
                  child: CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: Icon(
                      task.symbol,
                      color: KColors.primary,
                    ),
                    title: Text(
                      '${index + 1}. ${task.label}',
                    ),
                    subtitle: const Text(
                      'يمكنك تعليمها كمكتملة للتجربة',
                    ),
                    value: task.isCompleted,
                    onChanged: (_) {
                      routineController.toggleRoutine(index);
                    },
                  ),
                ),
              );
            }),
          ],
        );
      }),
    );
  }
}
