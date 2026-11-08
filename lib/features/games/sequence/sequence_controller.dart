import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SequenceStep {
  final int id;
  final String title;
  final String imagePath;

  SequenceStep({
    required this.id,
    required this.title,
    required this.imagePath,
  });
}

class SequenceController extends GetxController {
  final isChecked = false.obs;
  final isCorrect = false.obs;
  final isFinished = false.obs;
  final stars = 0.obs;

  final correctOrder = <SequenceStep>[];

  final userOrder = <SequenceStep>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initGame();
  }

  void _initGame() {
    correctOrder.clear();
    correctOrder.addAll([
      SequenceStep(
        id: 1,
        title: 'أضع التربة',
        imagePath: 'assets/images/soil_step.png',
      ),
      SequenceStep(
        id: 2,
        title: 'أزرع البذور',
        imagePath: 'assets/images/seeds_step.png',
      ),
      SequenceStep(
        id: 3,
        title: 'أرويها بالماء',
        imagePath: 'assets/images/water_step.png',
      ),
      SequenceStep(
        id: 4,
        title: 'تنمو الزهرة',
        imagePath: 'assets/images/flower_step.png',
      ),
    ]);

    userOrder.clear();
    userOrder.addAll(List.from(correctOrder)..shuffle());

    isChecked.value = false;
    isCorrect.value = false;
    isFinished.value = false;
    stars.value = 0;
  }

  void onReorder(int oldIndex, int newIndex) {
    if (isChecked.value && isCorrect.value) return;

    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final item = userOrder.removeAt(oldIndex);
    userOrder.insert(newIndex, item);

    isChecked.value = false;
    isCorrect.value = false;
  }

  void checkOrder() {
    if (isFinished.value) return;

    bool correct = true;
    for (int i = 0; i < correctOrder.length; i++) {
      if (userOrder[i].id != correctOrder[i].id) {
        correct = false;
        break;
      }
    }

    isChecked.value = true;
    isCorrect.value = correct;

    if (correct) {
      stars.value = 1;
      Future.delayed(const Duration(milliseconds: 900), () {
        isFinished.value = true;
      });
    } else {
      Get.snackbar(
        'حاول مرة أخرى',
        'الترتيب غير صحيح، اسحب الكروت وحاول مجددًا',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFFFFF4F4),
        colorText: const Color(0xFFB71C1C),
      );
    }
  }

  void restartGame() {
    _initGame();
  }

  void goBack() {
    Get.back();
  }
}
