import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/routine_model.dart';

class RoutineController extends GetxController {
  final routine = <RoutineModel>[
    const RoutineModel(
      id: 'wake_up',
      label: 'الاستيقاظ',
      symbol: Icons.wb_sunny_outlined,
    ),
    const RoutineModel(
      id: 'wash_face',
      label: 'غسل الوجه',
      symbol: Icons.wash_outlined,
    ),
    const RoutineModel(
      id: 'brush_teeth',
      label: 'تنظيف الأسنان',
      symbol: Icons.clean_hands_outlined,
    ),
    const RoutineModel(
      id: 'breakfast',
      label: 'الإفطار',
      symbol: Icons.breakfast_dining_outlined,
    ),
    const RoutineModel(
      id: 'get_ready',
      label: 'الاستعداد للخروج',
      symbol: Icons.backpack_outlined,
    ),
  ].obs;

  int get completedCount => routine.where((item) => item.isCompleted).length;

  double get progress {
    if (routine.isEmpty) return 0;
    return completedCount / routine.length;
  }

  void addRoutine(String label) {
    final cleaned = label.trim();

    if (cleaned.isEmpty) return;

    routine.add(
      RoutineModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        label: cleaned,
        symbol: Icons.checklist_outlined,
      ),
    );
  }

  void toggleRoutine(int index) {
    if (index < 0 || index >= routine.length) return;

    final item = routine[index];

    routine[index] = item.copyWith(
      isCompleted: !item.isCompleted,
    );
  }
}
