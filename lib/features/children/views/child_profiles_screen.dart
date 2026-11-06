import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/playful_colors.dart';
import '../../pairing/views/parent_pair_screen.dart';
import '../controllers/children_controller.dart';
import '../controllers/selected_child_controller.dart';
import '../models/child_model.dart';
import 'child_profile_editor.dart';

class ChildProfilesScreen extends StatelessWidget {
  const ChildProfilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final childrenController = Get.find<ChildrenController>();
    final selectedController = Get.find<SelectedChildController>();
    final palette = Theme.of(context).extension<PlayfulColors>()!;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Obx(() {
              final children = childrenController.children.toList();
              final loading = childrenController.isLoading.value;
              final error = childrenController.errorMessage.value;
              final selectedId = selectedController.selectedChildId.value;

              return RefreshIndicator(
                onRefresh: () async {
                  childrenController.startWatching();
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    _TopBar(
                      onBack: Get.back,
                    ),
                    const SizedBox(height: 12),
                    _Header(palette: palette),
                    const SizedBox(height: 18),
                    _AddChildButton(
                      onTap: () => Get.to(
                        () => const ChildProfileEditor(),
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (loading && children.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (error != null && children.isEmpty)
                      _StatusMessage(
                        icon: Icons.error_outline_rounded,
                        title: error,
                        actionLabel: 'إعادة المحاولة',
                        onAction: childrenController.startWatching,
                      )
                    else if (children.isEmpty)
                      const _StatusMessage(
                        icon: Icons.child_friendly_outlined,
                        title: 'لا يوجد أطفال بعد',
                        body: 'أضف ملف طفلك للبدء.',
                      )
                    else ...[
                      if (error != null) ...[
                        Text(
                          error,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      for (var i = 0; i < children.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _ChildCard(
                            child: children[i],
                            color: _childColor(palette, i),
                            isActive: selectedId == children[i].id,
                            onSelect: () {
                              childrenController.selectChild(children[i]);
                            },
                            onEdit: () {
                              Get.to(
                                () => ChildProfileEditor(
                                  child: children[i],
                                ),
                              );
                            },
                            onOpenFile: () {
                              _showChildFile(
                                context,
                                children[i],
                              );
                            },
                            onLink: () {
                              childrenController.selectChild(children[i]);

                              Get.to(
                                () => const ParentPairScreen(),
                              );
                            },
                          ),
                        ),
                    ],
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  void _showChildFile(
    BuildContext context,
    ChildModel child,
  ) {
    Get.bottomSheet(
      _ChildFileSheet(child: child),
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
    );
  }
}

Color _childColor(PlayfulColors palette, int index) {
  final colors = [
    palette.pink,
    palette.blue,
    palette.green,
    palette.yellow,
    palette.purple,
    palette.orange,
  ];

  return colors[index % colors.length];
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.onBack,
  });

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        _RoundButton(
          tooltip: 'رجوع',
          color: scheme.surface,
          icon: Directionality.of(context) == TextDirection.rtl
              ? Icons.arrow_forward_rounded
              : Icons.arrow_back_rounded,
          onTap: onBack,
        ),
        const Spacer(),
        _RoundButton(
          tooltip: 'الأطفال',
          color: scheme.primaryContainer,
          icon: Icons.child_care_rounded,
          onTap: () {},
        ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.tooltip,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: color,
        shape: CircleBorder(
          side: BorderSide(
            color: scheme.outlineVariant,
          ),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(
              icon,
              size: 22,
            ),
          ),
        ),
      ),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(
              'assets/images/parent/logo.png',
              width: 64,
              height: 64,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الأطفال',
                  style: text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: palette.onPastel,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'أضف أطفالك وأدر ملفاتهم واختر الطفل النشط.',
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

class _AddChildButton extends StatelessWidget {
  const _AddChildButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Material(
      color: scheme.primary,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_rounded,
                size: 22,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                'إضافة طفل',
                style: text.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: scheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  const _ChildCard({
    required this.child,
    required this.color,
    required this.isActive,
    required this.onSelect,
    required this.onEdit,
    required this.onOpenFile,
    required this.onLink,
  });

  final ChildModel child;
  final Color color;
  final bool isActive;

  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onOpenFile;
  final VoidCallback onLink;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<PlayfulColors>()!;
    final text = Theme.of(context).textTheme;

    final radius = BorderRadius.circular(28);

    return Material(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: isActive ? scheme.primary : Colors.transparent,
          width: 3,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: onSelect,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                12,
              ),
              child: Row(
                children: [
                  _KidAvatar(child: child),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: palette.onPastel,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (child.birthYear != null)
                          Text(
                            _childAgeLabel(child.birthYear!),
                            style: text.bodyMedium?.copyWith(
                              color: palette.onPastel.withValues(alpha: 0.75),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            const _SyncChip(),
                            if (isActive) const _ActiveBadge(),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.chevron_left_rounded
                        : Icons.chevron_right_rounded,
                    color: palette.onPastel,
                    size: 26,
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: scheme.surface.withValues(alpha: 0.55),
            padding: const EdgeInsets.fromLTRB(
              12,
              10,
              12,
              12,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _ActionChip(
                        emoji: '✏️',
                        label: 'تعديل',
                        onTap: onEdit,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ActionChip(
                        emoji: '📄',
                        label: 'ملف الطفل',
                        onTap: onOpenFile,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _ActionChip(
                  emoji: '🔗',
                  label: 'ربط الجهاز',
                  onTap: onLink,
                  fullWidth: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KidAvatar extends StatelessWidget {
  const _KidAvatar({
    required this.child,
  });

  final ChildModel child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final imagePath = switch (child.gender) {
      ChildGender.male => 'assets/images/parent/boy.png',
      ChildGender.female => 'assets/images/parent/girl.png',
      null => 'assets/images/parent/boy.png',
    };

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: scheme.surface,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: Image.asset(
          imagePath,
          width: 70,
          height: 70,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

String _childAgeLabel(int birthYear) {
  final age = DateTime.now().year - birthYear;

  if (age <= 0) {
    return 'أقل من سنة';
  }

  if (age == 1) {
    return 'سنة واحدة';
  }

  if (age == 2) {
    return 'سنتان';
  }

  if (age >= 3 && age <= 10) {
    return '$age سنوات';
  }

  return '$age سنة';
}

class _ActiveBadge extends StatelessWidget {
  const _ActiveBadge();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '⭐ الطفل النشط',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.onPrimary,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _SyncChip extends StatelessWidget {
  const _SyncChip();

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PlayfulColors>()!;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: palette.green,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: scheme.surface.withValues(alpha: 0.6),
        ),
      ),
      child: Text(
        '☁️ متزامن',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: palette.onPastel,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.emoji,
    required this.label,
    required this.onTap,
    this.fullWidth = false,
  });

  final String emoji;
  final String label;
  final VoidCallback onTap;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<PlayfulColors>()!;
    final text = Theme.of(context).textTheme;

    final radius = BorderRadius.circular(999);

    return Material(
      color: palette.pink,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          width: fullWidth ? double.infinity : null,
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 12,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: text.labelLarge?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w800,
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

class _ChildFileSheet extends StatelessWidget {
  const _ChildFileSheet({
    required this.child,
  });

  final ChildModel child;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<PlayfulColors>()!;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: scheme.outlineVariant,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      switch (child.gender) {
                        ChildGender.male => 'assets/images/parent/boy.png',
                        ChildGender.female => 'assets/images/parent/girl.png',
                        null => 'assets/images/parent/boy.png',
                      },
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        child.name,
                        style: text.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ملف الطفل',
                        style: text.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _FileRow(
              emoji: '🧒',
              label: 'اسم الطفل',
              value: child.name,
            ),
            _FileRow(
              emoji: '🎂',
              label: 'سنة الميلاد',
              value: child.birthYear?.toString() ?? 'غير محددة',
            ),
            _FileRow(
              emoji: child.gender == ChildGender.female ? '👧' : '👦',
              label: 'الجنس',
              value: switch (child.gender) {
                ChildGender.male => 'ذكر',
                ChildGender.female => 'أنثى',
                null => 'غير محدد',
              },
            ),
            _FileRow(
              emoji: '💬',
              label: 'طريقة التواصل',
              value: _communicationMethodLabel(
                child.communicationMethod,
              ),
            ),
            _FileRow(
              emoji: '🎨',
              label: 'التفضيلات الحسية',
              value: child.sensoryPreferences.isEmpty
                  ? 'غير محددة'
                  : child.sensoryPreferences
                      .map(_sensoryPreferenceLabel)
                      .join('، '),
            ),
            _FileRow(
              emoji: '🎯',
              label: 'الأهداف اليومية',
              value: child.goals.isEmpty
                  ? 'غير محددة'
                  : child.goals.map(_dailyGoalLabel).join('، '),
            ),
            _FileRow(
              emoji: '📚',
              label: 'الوحدة التعليمية',
              value: _lessonUnitLabel(child.lessonUnit),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: palette.yellow,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _MiniStat(
                      label: 'المستوى',
                      value: '${child.level}',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 42,
                    color: palette.onPastel.withValues(alpha: 0.15),
                  ),
                  Expanded(
                    child: _MiniStat(
                      label: 'التقدم',
                      value: '${child.progressPercent}%',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 42,
                    color: palette.onPastel.withValues(alpha: 0.15),
                  ),
                  Expanded(
                    child: _MiniStat(
                      label: 'ملفات التواصل',
                      value: '${child.communicationFilesCount}',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = Theme.of(context).extension<PlayfulColors>()!;

    return Column(
      children: [
        Text(
          value,
          style: text.titleLarge?.copyWith(
            color: palette.onPastel,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: text.labelSmall?.copyWith(
            color: palette.onPastel,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _FileRow extends StatelessWidget {
  const _FileRow({
    required this.emoji,
    required this.label,
    required this.value,
  });

  final String emoji;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = Theme.of(context).extension<PlayfulColors>()!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: palette.blue,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: text.labelMedium?.copyWith(
                      color: palette.onPastel,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: text.bodyLarge?.copyWith(
                      color: palette.onPastel,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _communicationMethodLabel(CommunicationMethod value) {
  return switch (value) {
    CommunicationMethod.picturesAndSound => 'صور وصوت',
    CommunicationMethod.sound => 'صوت',
    CommunicationMethod.pictures => 'صور',
  };
}

String _sensoryPreferenceLabel(SensoryPreference value) {
  return switch (value) {
    SensoryPreference.calmColors => 'ألوان هادئة',
    SensoryPreference.calmSounds => 'أصوات هادئة',
    SensoryPreference.dimLights => 'إضاءة خافتة',
  };
}

String _dailyGoalLabel(DailyGoal value) {
  return switch (value) {
    DailyGoal.emotions => 'المشاعر',
    DailyGoal.routine => 'الروتين',
    DailyGoal.requests => 'الطلبات',
  };
}

String _lessonUnitLabel(LessonUnit value) {
  return switch (value) {
    LessonUnit.communication => 'التواصل',
    LessonUnit.emotions => 'المشاعر',
    LessonUnit.routine => 'الروتين',
  };
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({
    required this.icon,
    required this.title,
    this.body,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        children: [
          Icon(
            icon,
            size: 54,
            color: scheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          if (body != null) ...[
            const SizedBox(height: 6),
            Text(
              body!,
              textAlign: TextAlign.center,
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
