import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/playful_colors.dart';
import '../controllers/independence_controller.dart';
import '../models/independence_model.dart';

class IndependenceScreen extends StatelessWidget {
  const IndependenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<IndependenceController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('تقييم الاستقلالية'),
      ),
      body: Obx(() {
        if (controller.selectedChildId == null) {
          return const _NoChildState();
        }

        if (controller.isLoading.value && controller.areas.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final error = controller.errorMessage.value;

        if (error != null && controller.areas.isEmpty) {
          return _ErrorState(
            message: error,
            onRetry: controller.retry,
          );
        }

        return _AssessmentContent(
          controller: controller,
        );
      }),
    );
  }
}

class _AssessmentContent extends StatelessWidget {
  const _AssessmentContent({
    required this.controller,
  });

  final IndependenceController controller;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PlayfulColors>()!;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _Header(
                childName: controller.selectedChildName,
                palette: palette,
              ),
              const SizedBox(height: 16),
              _SummaryCard(
                controller: controller,
                palette: palette,
              ),
              const SizedBox(height: 18),
              for (final area in controller.areas) ...[
                _AreaCard(
                  area: area,
                  controller: controller,
                ),
                const SizedBox(height: 14),
              ],
            ],
          ),
        ),
        _SaveBar(controller: controller),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.childName,
    required this.palette,
  });

  final String childName;
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
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              shape: BoxShape.circle,
            ),
            child: const Text(
              '🌱',
              style: TextStyle(fontSize: 30),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'استقلالية $childName',
                  style: text.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: palette.onPastel,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'قيّم مستوى أداء الطفل في مهاراته اليومية.',
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.controller,
    required this.palette,
  });

  final IndependenceController controller;
  final PlayfulColors palette;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Obx(() {
      final percent = (controller.overallIndependenceRate * 100).round();

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: palette.green,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'ملخص الاستقلالية',
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: palette.onPastel,
                    ),
                  ),
                ),
                Text(
                  '$percent%',
                  style: text.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: palette.onPastel,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 10,
                value: controller.overallIndependenceRate,
                backgroundColor: Colors.white.withValues(alpha: 0.55),
                color: palette.onPastel,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${controller.independentAreasCount} من '
              '${controller.totalAreasCount} مجالات مستقلة',
              style: text.bodyMedium?.copyWith(
                color: palette.onPastel,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _AreaCard extends StatelessWidget {
  const _AreaCard({
    required this.area,
    required this.controller,
  });

  final IndependenceArea area;
  final IndependenceController controller;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PlayfulColors>()!;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final currentArea = controller.areas.firstWhereOrNull(
          (item) => item.id == area.id,
        ) ??
        area;

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
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: palette.blue,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  currentArea.icon,
                  style: const TextStyle(fontSize: 23),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  currentArea.title,
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (currentArea.isIndependent)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: palette.green,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'مستقل ✓',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          for (var index = 0; index < currentArea.skills.length; index++) ...[
            _SkillRow(
              areaId: currentArea.id,
              skill: currentArea.skills[index],
              controller: controller,
            ),
            if (index != currentArea.skills.length - 1)
              const Divider(height: 20),
          ],
        ],
      ),
    );
  }
}

class _SkillRow extends StatelessWidget {
  const _SkillRow({
    required this.areaId,
    required this.skill,
    required this.controller,
  });

  final String areaId;
  final IndependenceSkill skill;
  final IndependenceController controller;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          skill.title,
          style: text.bodyMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 9),
        Row(
          children: [
            Expanded(
              child: _LevelButton(
                title: 'لم ينجز',
                emoji: '○',
                selected: skill.level == IndependenceLevel.notYet,
                onTap: () => controller.updateSkillLevel(
                  areaId: areaId,
                  skillId: skill.id,
                  level: IndependenceLevel.notYet,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _LevelButton(
                title: 'بمساعدة',
                emoji: '🤝',
                selected: skill.level == IndependenceLevel.withHelp,
                onTap: () => controller.updateSkillLevel(
                  areaId: areaId,
                  skillId: skill.id,
                  level: IndependenceLevel.withHelp,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _LevelButton(
                title: 'مستقل',
                emoji: '✓',
                selected: skill.level == IndependenceLevel.independent,
                onTap: () => controller.updateSkillLevel(
                  areaId: areaId,
                  skillId: skill.id,
                  level: IndependenceLevel.independent,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LevelButton extends StatelessWidget {
  const _LevelButton({
    required this.title,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PlayfulColors>()!;
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected ? palette.green : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? palette.onPastel.withValues(alpha: 0.18)
                : scheme.outlineVariant,
          ),
        ),
        child: Column(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 17),
            ),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({
    required this.controller,
  });

  final IndependenceController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: controller.isSaving.value
                  ? null
                  : () async {
                      final success = await controller.save();

                      if (!context.mounted) return;

                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'تم حفظ تقييم الاستقلالية بنجاح',
                            ),
                          ),
                        );
                      }
                    },
              icon: controller.isSaving.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(
                controller.isSaving.value ? 'جارٍ الحفظ...' : 'حفظ التقييم',
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _NoChildState extends StatelessWidget {
  const _NoChildState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          'اختر طفلًا أولًا حتى تتمكن من تقييم مهارات الاستقلالية.',
          textAlign: TextAlign.center,
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
              size: 46,
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
