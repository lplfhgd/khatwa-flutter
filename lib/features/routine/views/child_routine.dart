import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/k_colors.dart';
import '../controllers/routine_controller.dart';

class ChildRoutine extends StatelessWidget {
  const ChildRoutine({super.key});

  @override
  Widget build(BuildContext context) {
    final routineController = Get.find<RoutineController>();

    return Obx(() {
      final tasks = routineController.routine;

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'روتيني اليوم',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ...tasks.asMap().entries.map((entry) {
            final index = entry.key;
            final task = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => routineController.toggleRoutine(index),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  constraints: const BoxConstraints(minHeight: 92),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: KColors.border),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: KColors.soft,
                        child: Icon(
                          task.symbol,
                          color: KColors.primary,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Text(
                          task.label,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Icon(
                        task.isCompleted
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color:
                            task.isCompleted ? Colors.green : Colors.blueGrey,
                        size: 34,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      );
    });
  }
}
