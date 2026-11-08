import 'dart:async';
import 'package:get/get.dart';

class MatchingController extends GetxController {
  final round = 1.obs;
  final stars = 0.obs;
  final selectedFruit = ''.obs;
  final isCorrect = false.obs;
  final isFinished = false.obs;

  final feedback = ''.obs;
  final feedbackType = ''.obs; // 'correct' or 'wrong'

  Timer? _feedbackTimer;

  final fruits = <Map<String, String>>[
    {
      'id': 'orange',
      'name': 'البرتقال',
      'image': 'assets/images/orange.png',
    },
    {
      'id': 'banana',
      'name': 'الموز',
      'image': 'assets/images/banana.png',
    },
    {
      'id': 'apple',
      'name': 'التفاحة',
      'image': 'assets/images/apple.png',
    },
    {
      'id': 'grapes',
      'name': 'العنب',
      'image': 'assets/images/grapes.png',
    },
  ];

  final targets = ['apple', 'banana', 'orange', 'grapes', 'apple'];

  void _showFeedback(String message, String type) {
    _feedbackTimer?.cancel();
    feedback.value = message;
    feedbackType.value = type;
    _feedbackTimer = Timer(const Duration(seconds: 2), () {
      feedback.value = '';
      feedbackType.value = '';
    });
  }

  @override
  void onInit() {
    super.onInit();
    loadProgress();
  }

  String get currentTarget => targets[round.value - 1];

  String get targetImage {
    switch (currentTarget) {
      case 'banana':
        return 'assets/images/banana.png';
      case 'orange':
        return 'assets/images/orange.png';
      case 'grapes':
        return 'assets/images/grapes.png';
      default:
        return 'assets/images/apple.png';
    }
  }

  String get targetName {
    switch (currentTarget) {
      case 'banana':
        return 'الموزة';
      case 'orange':
        return 'البرتقالة';
      case 'grapes':
        return 'العنب';
      default:
        return 'التفاحة';
    }
  }

  Future<void> loadProgress() async {
    round.value = 1;
    stars.value = 0;
    selectedFruit.value = '';
    isCorrect.value = false;
    isFinished.value = false;
    feedback.value = '';
    feedbackType.value = '';
    _feedbackTimer?.cancel();

    update();
  }

  Future<void> saveProgress() async {}

  Future<void> selectFruit(String id) async {
    if (isCorrect.value || isFinished.value) return;

    selectedFruit.value = id;

    if (id == currentTarget) {
      isCorrect.value = true;
      stars.value++;

      await saveProgress();

      _showFeedback('أحسنت! ⭐ إجابة صحيحة، أنت بطل!', 'correct');
    } else {
      _showFeedback('حاول مرة أخرى 💚 ابحث عن الصورة المشابهة.', 'wrong');
    }
  }

  Future<void> nextRound() async {
    if (!isCorrect.value || isFinished.value) return;

    if (round.value >= targets.length) {
      isFinished.value = true;
      await saveProgress();
      return;
    }

    round.value++;
    selectedFruit.value = '';
    isCorrect.value = false;
    feedback.value = '';
    feedbackType.value = '';
    _feedbackTimer?.cancel();

    await saveProgress();
  }

  Future<void> restartGame() async {
    round.value = 1;
    stars.value = 0;
    selectedFruit.value = '';
    isCorrect.value = false;
    isFinished.value = false;
    feedback.value = '';
    feedbackType.value = '';
    _feedbackTimer?.cancel();
  }

  @override
  void onClose() {
    _feedbackTimer?.cancel();
    super.onClose();
  }
}
