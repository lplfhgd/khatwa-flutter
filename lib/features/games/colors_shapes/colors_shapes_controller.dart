import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ShapeChoice {
  final String id;
  final String shape;
  final Color color;

  ShapeChoice({
    required this.id,
    required this.shape,
    required this.color,
  });
}

class QuestionItem {
  final String question;
  final String correctId;
  final List<ShapeChoice> choices;

  QuestionItem({
    required this.question,
    required this.correctId,
    required this.choices,
  });
}

class ColorsShapesController extends GetxController {
  final currentIndex = 0.obs;
  final stars = 0.obs;
  final isFinished = false.obs;

  final questions = <QuestionItem>[
    QuestionItem(
      question: 'اختر الشكل باللون الأحمر',
      correctId: 'circle_red',
      choices: [
        ShapeChoice(id: 'circle_red', shape: 'circle', color: Colors.red),
        ShapeChoice(id: 'triangle_blue', shape: 'triangle', color: Colors.blue),
        ShapeChoice(
            id: 'star_yellow', shape: 'star', color: const Color(0xFFFFB800)),
        ShapeChoice(id: 'square_green', shape: 'square', color: Colors.green),
      ],
    ),
    QuestionItem(
      question: 'اختر المربع باللون الأزرق',
      correctId: 'square_blue',
      choices: [
        ShapeChoice(id: 'circle_green', shape: 'circle', color: Colors.green),
        ShapeChoice(id: 'square_blue', shape: 'square', color: Colors.blue),
        ShapeChoice(id: 'star_red', shape: 'star', color: Colors.red),
        ShapeChoice(
            id: 'triangle_yellow',
            shape: 'triangle',
            color: const Color(0xFFFFB800)),
      ],
    ),
    QuestionItem(
      question: 'اختر النجمة باللون الأصفر',
      correctId: 'star_yellow2',
      choices: [
        ShapeChoice(id: 'triangle_red', shape: 'triangle', color: Colors.red),
        ShapeChoice(id: 'circle_blue', shape: 'circle', color: Colors.blue),
        ShapeChoice(
            id: 'star_yellow2', shape: 'star', color: const Color(0xFFFFB800)),
        ShapeChoice(id: 'square_green', shape: 'square', color: Colors.green),
      ],
    ),
    QuestionItem(
      question: 'اختر المثلث باللون الأخضر',
      correctId: 'triangle_green',
      choices: [
        ShapeChoice(id: 'circle_red', shape: 'circle', color: Colors.red),
        ShapeChoice(
            id: 'triangle_green', shape: 'triangle', color: Colors.green),
        ShapeChoice(id: 'star_blue', shape: 'star', color: Colors.blue),
        ShapeChoice(
            id: 'square_yellow',
            shape: 'square',
            color: const Color(0xFFFFB800)),
      ],
    ),
  ];

  QuestionItem get currentQuestion => questions[currentIndex.value];

  void selectShape(String id) {
    if (isFinished.value) return;

    if (id == currentQuestion.correctId) {
      stars.value++;

      if (currentIndex.value < questions.length - 1) {
        Future.delayed(const Duration(milliseconds: 400), () {
          currentIndex.value++;
        });
      } else {
        Future.delayed(const Duration(milliseconds: 400), () {
          isFinished.value = true;
        });
      }
    } else {
      Get.snackbar(
        'حاول مرة أخرى',
        'غير صحيح، جرّب مرة أخرى',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFFFFF4F4),
        colorText: const Color(0xFFB71C1C),
      );
    }
  }

  void restartGame() {
    currentIndex.value = 0;
    stars.value = 0;
    isFinished.value = false;
  }

  void goBack() {
    Get.back();
  }
}
