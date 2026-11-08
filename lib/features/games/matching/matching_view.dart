import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'matching_controller.dart';

class MatchingView extends GetView<MatchingController> {
  const MatchingView({super.key});

  static const Color teal = Color(0xFF119C99);
  static const Color darkTeal = Color(0xFF087F80);
  static const Color background = Color(0xFFF5FBF8);
  static const Color textColor = Color(0xFF203B40);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Obx(() {
          if (controller.isFinished.value) {
            return _buildResult();
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 24,
                  ),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 18),
                      const Text(
                        'لعبة مطابقة الصور',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'طابق الصورة مع مثلها',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF607983),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildProgress(),
                      const SizedBox(height: 12),
                      _buildFeedback(),
                      const SizedBox(height: 10),
                      _buildTarget(),
                      const SizedBox(height: 18),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'اختَر الصورة المطابقة',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildChoices(),
                      const SizedBox(height: 16),
                      _buildStars(),
                      const SizedBox(height: 16),
                      _buildNextButton(),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Material(
            color: const Color(0xFFDDF5EF),
            shape: const CircleBorder(),
            child: IconButton(
              onPressed: Get.back,
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  color: darkTeal, size: 24),
            ),
          ),
        ),
        Image.asset(
          'assets/images/logo.png',
          width: 100,
          height: 72,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Text(
            'خطوة',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: teal,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: ClipOval(
            child: Image.asset(
              'assets/images/avatar.png',
              width: 54,
              height: 54,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const CircleAvatar(
                radius: 27,
                backgroundColor: Color(0xFFDDF5EF),
                child: Icon(Icons.face_rounded, color: darkTeal, size: 32),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgress() {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: controller.round.value / 5,
                minHeight: 10,
                backgroundColor: const Color(0xFFDCECE6),
                color: teal,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${controller.round.value} / 5',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: darkTeal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedback() {
    return Obx(() {
      if (controller.feedback.value.isEmpty) {
        return const SizedBox.shrink();
      }

      final isCorrect = controller.feedbackType.value == 'correct';

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: Container(
          key: ValueKey(controller.feedback.value),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color:
                isCorrect ? const Color(0xFFE8F8F1) : const Color(0xFFFFF4F2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  isCorrect ? const Color(0xFFB7E5D0) : const Color(0xFFFFD6D1),
            ),
          ),
          child: Text(
            controller.feedback.value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color:
                  isCorrect ? const Color(0xFF1F7C5B) : const Color(0xFFD6453D),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTarget() {
    return Obx(() {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0xFFE2F0EA)),
          boxShadow: [
            BoxShadow(
              color: teal.withValues(alpha: 0.07),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            const Text(
              'أين الصورة المشابهة؟',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF607983),
              ),
            ),
            const SizedBox(height: 6),
            Image.asset(
              controller.targetImage,
              height: 145,
              width: 170,
              fit: BoxFit.contain,
            ),
            Text(
              controller.targetName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildChoices() {
    return Obx(() {
      final selectedId = controller.selectedFruit.value;

      return GridView.builder(
        itemCount: controller.fruits.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.12,
        ),
        itemBuilder: (context, index) {
          final fruit = controller.fruits[index];

          final isSelected = selectedId == fruit['id'];
          final isAnswer = fruit['id'] == controller.currentTarget;

          return InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => controller.selectFruit(fruit['id']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected && isAnswer
                    ? const Color(0xFFE0F6E8)
                    : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected
                      ? (isAnswer ? teal : const Color(0xFFFFB5A8))
                      : const Color(0xFFE2F0EA),
                  width: isSelected ? 2.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.035),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Image.asset(
                      fruit['image']!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.image_outlined,
                        size: 48,
                        color: teal,
                      ),
                    ),
                  ),
                  Text(
                    fruit['name']!,
                    style: const TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildStars() {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFFFFC84D), size: 30),
          const SizedBox(width: 5),
          Text(
            '${controller.stars.value} نجوم',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: controller.isCorrect.value ? controller.nextRound : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: teal,
            disabledBackgroundColor: const Color(0xFFB9D9D2),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 0,
          ),
          child: Text(
            controller.round.value == 5 ? 'عرض النتيجة' : 'التالي',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResult() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.emoji_events_rounded,
              color: Color(0xFFFFC84D),
              size: 90,
            ),
            const SizedBox(height: 16),
            const Text(
              'أحسنت يا بطل!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'جمعت ${controller.stars.value} من 5 نجوم ⭐',
              style: const TextStyle(fontSize: 18, color: textColor),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: controller.restartGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: teal,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'العب مرة أخرى',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            TextButton(
              onPressed: Get.back,
              child: const Text('العودة للألعاب'),
            ),
          ],
        ),
      ),
    );
  }
}
