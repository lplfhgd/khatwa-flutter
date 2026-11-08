import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'sequence_controller.dart';

class SequenceView extends GetView<SequenceController> {
  const SequenceView({super.key});

  static const Color primaryGreen = Color(0xFF0D7C66);
  static const Color lightBlue = Color(0xFFF0F8FF);
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color textColor = Color(0xFF203B40);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          if (controller.isFinished.value) {
            return _buildResult();
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 12),
                        _buildInstructionBox(),
                        const SizedBox(height: 18),
                        const Text(
                          'اسحب الكروت وأعد ترتيبها بالترتيب الصحيح',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF607983),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildReorderList(),
                        const SizedBox(height: 22),
                        _buildCheckButton(),
                      ],
                    ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Material(
            color: const Color(0xFFDDF5EF),
            shape: const CircleBorder(),
            child: IconButton(
              onPressed: controller.goBack,
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Color(0xFF087F80),
                size: 24,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Image.asset(
          'assets/images/plant_header.png',
          height: 95,
          width: 95,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 95,
              width: 95,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE8F5F3),
              ),
              child: const Icon(
                Icons.eco_rounded,
                size: 55,
                color: primaryGreen,
              ),
            );
          },
        ),
        const SizedBox(height: 6),
        const Text(
          'لعبة ترتيب الخطوات',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'ترتيب خطوات زراعة الزهرة',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: lightBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'رتب خطوات زراعة الزهرة بالترتيب الصحيح',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildReorderList() {
    return Obx(
      () => ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        buildDefaultDragHandles: true,
        onReorder: controller.onReorder,
        itemCount: controller.userOrder.length,
        itemBuilder: (context, index) {
          final step = controller.userOrder[index];

          return AnimatedContainer(
            key: ValueKey(step.id),
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: controller.isChecked.value
                    ? (controller.isCorrect.value
                        ? primaryGreen
                        : (step.id == controller.correctOrder[index].id
                            ? primaryGreen
                            : const Color(0xFFFFB5A8)))
                    : borderColor,
                width: controller.isChecked.value ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              leading: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryGreen,
                ),
                child: Center(
                  child: Text(
                    '${step.id}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              title: Text(
                step.title,
                style: const TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    step.imagePath,
                    width: 52,
                    height: 52,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.image_not_supported_outlined,
                        size: 40,
                        color: primaryGreen,
                      );
                    },
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.drag_handle_rounded,
                      color: Color(0xFF9CA3AF)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCheckButton() {
    return Obx(
      () => SizedBox(
        height: 56,
        child: ElevatedButton(
          onPressed: controller.isChecked.value && controller.isCorrect.value
              ? null
              : controller.checkOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            disabledBackgroundColor: const Color(0xFFB9D9D2),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            controller.isChecked.value && controller.isCorrect.value
                ? 'تم التحقق'
                : 'تحقق من الترتيب',
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
              size: 95,
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
              'جمعت ${controller.stars.value} نجمة ⭐',
              style: const TextStyle(fontSize: 18, color: textColor),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: controller.restartGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'العب مرة أخرى',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: Get.back,
              child: const Text(
                'العودة للألعاب',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: primaryGreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
