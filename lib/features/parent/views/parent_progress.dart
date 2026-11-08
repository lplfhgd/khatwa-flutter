import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/playful_colors.dart';
import '../../reports/controllers/reports_controller.dart';
import '../../reports/models/child_report.dart';
import '../../independence/views/independence_screen.dart';

class ParentProgress extends StatelessWidget {
  const ParentProgress({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReportsController>();

    return Obx(() {
      if (controller.children.isEmpty) {
        return const _EmptyChildrenState();
      }

      if (controller.isLoading.value && controller.report.value == null) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      final error = controller.errorMessage.value;

      if (error != null && controller.report.value == null) {
        return _ErrorState(
          message: error,
          onRetry: controller.retry,
        );
      }

      return _ReportsContent(controller: controller);
    });
  }
}

class _ReportsContent extends StatelessWidget {
  const _ReportsContent({
    required this.controller,
  });

  final ReportsController controller;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PlayfulColors>()!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        _Header(palette: palette),
        const SizedBox(height: 16),
        _ChildSelector(controller: controller),
        const SizedBox(height: 12),
        const _IndependenceButton(),
        const SizedBox(height: 16),
        Obx(() {
          final report = controller.report.value;

          if (report == null) {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _ReportStat(
                        emoji: '🧩',
                        label: 'مجالات الاستقلالية',
                        value: '${report.independentAreas}',
                        color: palette.blue,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ReportStat(
                        emoji: '🃏',
                        label: 'البطاقات المستخدمة',
                        value: '${report.cardsInUse}',
                        color: palette.pink,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ReportStat(
                        emoji: '⏰',
                        label: 'إنجاز الروتين',
                        value: '${report.routineCompletion}%',
                        color: palette.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                emoji: '📈',
                title: 'تقدم الطفل',
                hint: 'متابعة مستوى التقدم خلال الفترة الأخيرة',
                color: palette.yellow,
                child: _ProgressChart(points: report.progress),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                emoji: '🌟',
                title: 'الملاحظات',
                hint: 'أبرز الملاحظات المسجلة حول تقدم الطفل',
                color: palette.purple,
                child: _NotesList(notes: report.notes),
              ),
            ],
          );
        }),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.palette,
  });

  final PlayfulColors palette;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.yellow,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
            child: const Text(
              '📊',
              style: TextStyle(fontSize: 28),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تقارير التقدم',
                  style: text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: palette.onPastel,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'تابع تطور طفلك وإنجازاته خطوة بخطوة',
                  style: text.bodyMedium?.copyWith(
                    color: palette.onPastel,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChildSelector extends StatelessWidget {
  const _ChildSelector({
    required this.controller,
  });

  final ReportsController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: scheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          const Text(
            '👧',
            style: TextStyle(fontSize: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Obx(() {
              final selected = controller.selectedId.value;

              return DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: controller.children.any(
                    (child) => child.id == selected,
                  )
                      ? selected
                      : null,
                  hint: const Text('اختر الطفل'),
                  items: [
                    for (final child in controller.children)
                      DropdownMenuItem<String>(
                        value: child.id,
                        child: Text(child.name),
                      ),
                  ],
                  onChanged: (id) {
                    if (id != null && id != selected) {
                      controller.selectChild(id);
                    }
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _IndependenceButton extends StatelessWidget {
  const _IndependenceButton();

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PlayfulColors>()!;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          Get.to(
            () => const IndependenceScreen(),
          );
        },
        icon: const Text(
          '🌱',
          style: TextStyle(fontSize: 20),
        ),
        label: const Text(
          'تقييم مهارات الاستقلالية',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.onPastel,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

class _ReportStat extends StatelessWidget {
  const _ReportStat({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  final String emoji;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PlayfulColors>()!;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: text.labelSmall?.copyWith(
              color: palette.onPastel,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: text.titleLarge?.copyWith(
              color: palette.onPastel,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.emoji,
    required this.title,
    required this.hint,
    required this.color,
    required this.child,
  });

  final String emoji;
  final String title;
  final String hint;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<PlayfulColors>()!;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: scheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: palette.onPastel,
                      ),
                    ),
                    Text(
                      hint,
                      style: text.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ProgressChart extends StatelessWidget {
  const _ProgressChart({
    required this.points,
  });

  final List<ProgressPoint> points;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<PlayfulColors>()!;
    final text = Theme.of(context).textTheme;

    if (points.isEmpty) {
      return SizedBox(
        height: 160,
        child: Center(
          child: Text(
            '🌱 لا توجد بيانات تقدم كافية حتى الآن',
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox(
        height: 190,
        child: CustomPaint(
          size: Size.infinite,
          painter: _LineChartPainter(
            points: points,
            lineColor: palette.onPastel,
            fillColor: palette.green,
            gridColor: scheme.outlineVariant,
            labelStyle: (text.labelSmall ?? const TextStyle()).copyWith(
              color: palette.onPastel,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.points,
    required this.lineColor,
    required this.fillColor,
    required this.gridColor,
    required this.labelStyle,
  });

  final List<ProgressPoint> points;
  final Color lineColor;
  final Color fillColor;
  final Color gridColor;
  final TextStyle labelStyle;

  static const double _leftPad = 30;
  static const double _bottomPad = 24;

  @override
  void paint(Canvas canvas, Size size) {
    final chart = Rect.fromLTRB(
      _leftPad,
      8,
      size.width - 8,
      size.height - _bottomPad,
    );

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (final value in const [0, 50, 100]) {
      final y = chart.bottom - chart.height * value / 100;

      canvas.drawLine(
        Offset(chart.left, y),
        Offset(chart.right, y),
        gridPaint,
      );

      _label(
        canvas,
        '$value',
        Offset(chart.left - 14, y),
      );
    }

    final count = points.length;

    Offset pointAt(int index) {
      final x = count == 1
          ? chart.center.dx
          : chart.left + chart.width * index / (count - 1);

      final percent = points[index].percent.clamp(0, 100);

      return Offset(
        x,
        chart.bottom - chart.height * percent / 100,
      );
    }

    if (count == 1) {
      canvas.drawCircle(
        pointAt(0),
        6,
        Paint()..color = lineColor,
      );
    } else {
      final line = Path()
        ..moveTo(
          pointAt(0).dx,
          pointAt(0).dy,
        );

      for (var index = 1; index < count; index++) {
        line.lineTo(
          pointAt(index).dx,
          pointAt(index).dy,
        );
      }

      final area = Path.from(line)
        ..lineTo(
          pointAt(count - 1).dx,
          chart.bottom,
        )
        ..lineTo(
          pointAt(0).dx,
          chart.bottom,
        )
        ..close();

      canvas.drawPath(
        area,
        Paint()
          ..color = fillColor.withValues(
            alpha: 0.55,
          ),
      );

      canvas.drawPath(
        line,
        Paint()
          ..color = lineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );

      for (var index = 0; index < count; index++) {
        final point = pointAt(index);

        canvas.drawCircle(
          point,
          points[index].percent >= 100 ? 6 : 4.5,
          Paint()..color = lineColor,
        );

        canvas.drawCircle(
          point,
          2,
          Paint()..color = fillColor,
        );
      }
    }

    final step = math.max(
      1,
      (count / 4).ceil(),
    );

    final labelled = <int>{
      for (var index = 0; index < count; index += step) index,
      count - 1,
    };

    for (final index in labelled) {
      _label(
        canvas,
        _formatShortDay(points[index].date),
        Offset(
          pointAt(index).dx,
          chart.bottom + 12,
        ),
      );
    }
  }

  void _label(
    Canvas canvas,
    String value,
    Offset center,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: value,
        style: labelStyle,
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(
      canvas,
      center -
          Offset(
            painter.width / 2,
            painter.height / 2,
          ),
    );
  }

  @override
  bool shouldRepaint(
    covariant _LineChartPainter oldDelegate,
  ) {
    return oldDelegate.points != points ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.labelStyle != labelStyle;
  }
}

class _NotesList extends StatelessWidget {
  const _NotesList({
    required this.notes,
  });

  final List<ReportNote> notes;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<PlayfulColors>()!;
    final text = Theme.of(context).textTheme;

    if (notes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
        ),
        child: Text(
          '📝 لا توجد ملاحظات مسجلة حتى الآن',
          textAlign: TextAlign.center,
          style: text.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final note in notes)
          Padding(
            padding: const EdgeInsets.only(
              bottom: 10,
            ),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: palette.pink,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '⭐',
                    style: TextStyle(fontSize: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title,
                          style: text.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: palette.onPastel,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          note.body,
                          style: text.bodySmall?.copyWith(
                            color: palette.onPastel,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _formatDay(note.createdAt),
                      style: text.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptyChildrenState extends StatelessWidget {
  const _EmptyChildrenState();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '👧',
              style: TextStyle(fontSize: 52),
            ),
            const SizedBox(height: 16),
            Text(
              'لا يوجد ملف طفل',
              textAlign: TextAlign.center,
              style: text.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'أضف ملف طفل أولًا حتى تتمكن من متابعة تقاريره.',
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatShortDay(DateTime date) {
  return '${date.day}/${date.month}';
}

String _formatDay(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}
