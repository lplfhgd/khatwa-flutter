import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'colors_shapes_controller.dart';

class ColorsShapesView extends GetView<ColorsShapesController> {
  const ColorsShapesView({super.key});

  static const Color background = Colors.white;
  static const Color textColor = Color(0xFF203B40);
  static const Color instructionBg = Color(0xFFE8F6FF);
  static const Color primaryGreen = Color(0xFF0D7C66);

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
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 18),
                        _buildInstructionBox(),
                        const SizedBox(height: 24),
                        _buildShapesGrid(),
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
    return Stack(
      alignment: Alignment.center,
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
        const Text(
          'الألوان والأشكال',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      decoration: BoxDecoration(
        color: instructionBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Obx(
        () => Text(
          controller.currentQuestion.question,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildShapesGrid() {
    return Obx(
      () {
        final choices = controller.currentQuestion.choices;
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1,
          children: choices
              .map((choice) => _buildShapeCard(
                    shape: choice.shape,
                    color: choice.color,
                    id: choice.id,
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildShapeCard({
    required String shape,
    required Color color,
    required String id,
  }) {
    return GestureDetector(
      onTap: () => controller.selectShape(id),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E5E5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: _buildShape(shape, color),
        ),
      ),
    );
  }

  Widget _buildShape(String shape, Color color) {
    switch (shape) {
      case 'circle':
        return Container(
          width: 95,
          height: 95,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        );
      case 'square':
        return Container(
          width: 95,
          height: 95,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      case 'triangle':
        return CustomPaint(
          size: const Size(95, 85),
          painter: TrianglePainter(color: color),
        );
      case 'star':
        return Image.asset(
          'assets/images/star_shape.png',
          width: 95,
          height: 95,
          fit: BoxFit.contain,
          color: color,
          colorBlendMode: BlendMode.srcIn,
          errorBuilder: (context, error, stackTrace) {
            return CustomPaint(
              size: const Size(95, 95),
              painter: StarPainter(color: color),
            );
          },
        );
      default:
        return const SizedBox.shrink();
    }
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
              'جمعت ${controller.stars.value} من ${controller.questions.length} نجوم ⭐',
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

class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class StarPainter extends CustomPainter {
  final Color color;

  StarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double outerRadius = size.width / 2;
    final double innerRadius = outerRadius * 0.4;
    for (int i = 0; i < 5; i++) {
      double angle = (i * 72 - 90) * 3.14159 / 180;
      double x = cx + outerRadius * cos(angle);
      double y = cy + outerRadius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      angle = ((i * 72 + 36) - 90) * 3.14159 / 180;
      x = cx + innerRadius * cos(angle);
      y = cy + innerRadius * sin(angle);
      path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  double cos(double rad) {
    return [
      1,
      0.809,
      0.309,
      -0.309,
      -0.809,
      -1,
      -0.809,
      -0.309,
      0.309,
      0.809
    ][((rad / 0.6283185).round() % 10 + 10) % 10]
        .toDouble();
  }

  double sin(double rad) {
    return [
      0,
      0.5878,
      0.9511,
      0.9511,
      0.5878,
      0,
      -0.5878,
      -0.9511,
      -0.9511,
      -0.5878
    ][((rad / 0.6283185).round() % 10 + 10) % 10]
        .toDouble();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
