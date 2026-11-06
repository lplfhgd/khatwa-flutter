import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/playful_colors.dart';
import '../../children/controllers/children_controller.dart';
import '../../children/controllers/selected_child_controller.dart';
import '../../children/views/child_profiles_screen.dart';
import '../../routine/controllers/routine_controller.dart';

class ParentHome extends StatelessWidget {
  const ParentHome({
    super.key,
    required this.navigate,
    required this.childProfiles,
    required this.onOpenRoutine,
    required this.onOpenPairing,
  });

  final ValueChanged<int> navigate;
  final Widget childProfiles;
  final VoidCallback onOpenRoutine;
  final VoidCallback onOpenPairing;

  @override
  Widget build(BuildContext context) {
    final childrenController = Get.find<ChildrenController>();
    final selectedChild = Get.find<SelectedChildController>();
    final routineController = Get.find<RoutineController>();
    final palette = Theme.of(context).extension<PlayfulColors>()!;

    return Obx(() {
      final childName = selectedChild.childName.value.trim();
      final hasChild = selectedChild.selectedChildId.value != null;

      return RefreshIndicator(
        onRefresh: () async {
          childrenController.startWatching();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            const _Greeting(),
            const SizedBox(height: 16),
            if (hasChild)
              _ChildCard(
                childName: childName.isEmpty ? 'طفلي' : childName,
                palette: palette,
                onTap: () => Get.to(
                  () => const ChildProfilesScreen(),
                ),
              )
            else
              _NoChildCard(
                palette: palette,
                onTap: () => Get.to(
                  () => const ChildProfilesScreen(),
                ),
              ),
            const SizedBox(height: 16),
            Obx(() {
              final total = routineController.routine.length;
              final completed = routineController.completedCount;
              final progress =
                  total == 0 ? 0 : ((completed / total) * 100).round();

              return _StatsRow(
                cardsCount: 0,
                progress: progress,
                palette: palette,
              );
            }),
            const SizedBox(height: 24),
            _MenuGrid(
              palette: palette,
              onCards: () => navigate(1),
              onChildren: () => Get.to(
                () => const ChildProfilesScreen(),
              ),
              onStories: () => navigate(1),
              onRoutine: onOpenRoutine,
              onReports: () => navigate(2),
              onDevice: onOpenPairing,
            ),
          ],
        ),
      );
    });
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مرحبًا بك 👋',
          style: text.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'لنواصل رحلة طفلك خطوة بخطوة',
          style: text.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ChildCard extends StatelessWidget {
  const _ChildCard({
    required this.childName,
    required this.palette,
    required this.onTap,
  });

  final String childName;
  final PlayfulColors palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(28);

    return Material(
      color: scheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _KidAvatar(color: palette.blue),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      childName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _Pill(
                      emoji: '🌟',
                      label: 'في تقدم مستمر',
                      color: palette.green,
                      textColor: palette.onPastel,
                    ),
                  ],
                ),
              ),
              Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoChildCard extends StatelessWidget {
  const _NoChildCard({
    required this.palette,
    required this.onTap,
  });

  final PlayfulColors palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              _KidAvatar(color: palette.blue),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أضف طفلك',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text('أنشئ ملف الطفل للبدء'),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _KidAvatar extends StatelessWidget {
  const _KidAvatar({
    required this.color,
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: 84,
        height: 84,
        color: color,
        child: Image.asset(
          'assets/images/parent/kid.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Center(
            child: Text(
              '🧒',
              style: TextStyle(fontSize: 40),
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.emoji,
    required this.label,
    required this.color,
    required this.textColor,
  });

  final String emoji;
  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.cardsCount,
    required this.progress,
    required this.palette,
  });

  final int cardsCount;
  final int progress;
  final PlayfulColors palette;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _StatTile(
              emoji: '☁️',
              label: 'المزامنة',
              value: 'متزامن',
              color: palette.blue,
              textColor: palette.onPastel,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatTile(
              emoji: '🗂️',
              label: 'البطاقات',
              value: '$cardsCount',
              color: palette.yellow,
              textColor: palette.onPastel,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatTile(
              emoji: '📈',
              label: 'التقدم',
              value: '$progress%',
              color: palette.green,
              textColor: palette.onPastel,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
    required this.textColor,
  });

  final String emoji;
  final String label;
  final String value;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: text.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.titleMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuGrid extends StatelessWidget {
  const _MenuGrid({
    required this.palette,
    required this.onCards,
    required this.onChildren,
    required this.onStories,
    required this.onRoutine,
    required this.onReports,
    required this.onDevice,
  });

  final PlayfulColors palette;
  final VoidCallback onCards;
  final VoidCallback onChildren;
  final VoidCallback onStories;
  final VoidCallback onRoutine;
  final VoidCallback onReports;
  final VoidCallback onDevice;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.9,
      children: [
        _MenuTile(
          emoji: '🗂️',
          title: 'بطاقات التواصل',
          description: 'إدارة بطاقات التواصل الخاصة بالطفل',
          color: palette.yellow,
          onTap: onCards,
        ),
        _MenuTile(
          emoji: '🧒',
          title: 'الأطفال',
          description: 'إدارة ملفات الأطفال ومعلوماتهم',
          color: palette.green,
          onTap: onChildren,
        ),
        _MenuTile(
          emoji: '🎈',
          title: 'القصص',
          description: 'قصص مصورة تساعد الطفل على التعلم',
          color: palette.pink,
          onTap: onStories,
        ),
        _MenuTile(
          emoji: '📅',
          title: 'الروتين',
          description: 'تنظيم الروتين اليومي للطفل',
          color: palette.blue,
          onTap: onRoutine,
        ),
        _MenuTile(
          emoji: '📊',
          title: 'التقارير',
          description: 'متابعة تقدم الطفل وتطوره',
          color: palette.purple,
          onTap: onReports,
        ),
        _MenuTile(
          emoji: '🔗',
          title: 'ربط الجهاز',
          description: 'ربط جهاز الطفل بحساب ولي الأمر',
          color: palette.orange,
          onTap: onDevice,
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.emoji,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Material(
      color: scheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 26),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
