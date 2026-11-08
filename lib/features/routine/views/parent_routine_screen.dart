import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/playful_colors.dart';
import '../controllers/routine_controller.dart';
import '../models/routine_model.dart';

class ParentRoutineScreen extends StatelessWidget {
  const ParentRoutineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RoutineController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الروتين'),
      ),
      body: Obx(() {
        final childId = controller.selectedChildId;

        if (childId == null || childId.isEmpty) {
          return const _NoChildState();
        }

        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final error = controller.errorMessage.value;

        if (error != null) {
          return _ErrorState(
            message: error,
            onRetry: controller.loadRoutine,
          );
        }

        return _RoutineContent(controller: controller);
      }),
    );
  }
}

class _RoutineContent extends StatelessWidget {
  const _RoutineContent({
    required this.controller,
  });

  final RoutineController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final palette = Theme.of(context).extension<PlayfulColors>()!;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(
                  name: controller.selectedChildName,
                  palette: palette,
                ),
                const SizedBox(height: 16),
                _SummaryCard(
                  controller: controller,
                  palette: palette,
                ),
                const SizedBox(height: 14),
                Obx(() {
                  final items = controller.routine;

                  if (items.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: palette.blue,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '📭',
                            style: TextStyle(fontSize: 36),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'لا توجد مهام في الروتين بعد',
                            textAlign: TextAlign.center,
                            style: text.bodyLarge?.copyWith(
                              color: palette.onPastel,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      for (var i = 0; i < items.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _TaskRow(
                            index: i,
                            item: items[i],
                            color: _taskColor(palette, i),
                            controller: controller,
                          ),
                        ),
                    ],
                  );
                }),
                const SizedBox(height: 6),
                _PillButton(
                  emoji: '➕',
                  label: 'إضافة مهمة',
                  color: palette.green,
                  textColor: palette.onPastel,
                  onTap: () => openTaskEditor(controller),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(
                () => controller.isDirty.value
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '⚠️ لديك تغييرات غير محفوظة',
                          style: text.bodySmall?.copyWith(
                            color: scheme.tertiary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              Obx(
                () => _PillButton(
                  emoji: controller.isSaving.value ? '⏳' : '💾',
                  label: 'حفظ الروتين',
                  color: scheme.primary,
                  textColor: scheme.onPrimary,
                  loading: controller.isSaving.value,
                  onTap: controller.isSaving.value ? null : controller.save,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.name,
    required this.palette,
  });

  final String name;
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
              '📋',
              style: TextStyle(fontSize: 28),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الروتين اليومي',
                  style: text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: palette.onPastel,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name.isEmpty
                      ? 'نظّم خطوات اليوم'
                      : 'نظّم يوم $name خطوة بخطوة',
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

  final RoutineController controller;
  final PlayfulColors palette;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.green,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Text(
            '🌅',
            style: TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'روتين الصباح',
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: palette.onPastel,
                  ),
                ),
                const SizedBox(height: 2),
                Obx(
                  () => Text(
                    '${controller.routine.length} مهام',
                    style: text.bodyMedium?.copyWith(
                      color: palette.onPastel,
                    ),
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

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.index,
    required this.item,
    required this.color,
    required this.controller,
  });

  final int index;
  final RoutineModel item;
  final Color color;
  final RoutineController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<PlayfulColors>()!;
    final text = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(24);

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.horizontal,
      background: _dismissBackground(context),
      secondaryBackground: _dismissBackground(context),
      onDismissed: (_) => controller.removeItem(item.id),
      child: Material(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
        ),
        child: InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: radius,
          ),
          onTap: () => openTaskEditor(
            controller,
            existing: item,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${index + 1}',
                    style: text.labelLarge?.copyWith(
                      color: palette.onPastel,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: scheme.surface.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _emojiOf(item.iconName),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        style: text.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: palette.onPastel,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '🕒 ${formatTaskTime(item.time)}',
                        style: text.bodySmall?.copyWith(
                          color: palette.onPastel,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: item.enabled,
                  onChanged: (value) {
                    controller.toggleEnabled(item.id, value);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dismissBackground(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      alignment: AlignmentDirectional.centerEnd,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Text(
        '🗑️',
        style: TextStyle(fontSize: 26),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.emoji,
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
    this.loading = false,
  });

  final String emoji;
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(999);

    return Material(
      color: onTap == null ? color.withValues(alpha: 0.5) : color,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
      ),
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: radius,
        ),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: textColor,
                  ),
                )
              else
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              const SizedBox(width: 8),
              Text(
                label,
                style: text.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String toStoredTime(TimeOfDay time) {
  return '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';
}

String formatTaskTime(String time) {
  final parts = time.split(':');

  if (parts.length != 2) return time;

  final hour = int.tryParse(parts[0]) ?? 0;
  final minute = parts[1];

  final hour12 = hour % 12 == 0 ? 12 : hour % 12;
  final period = hour >= 12 ? 'م' : 'ص';

  return '$hour12:$minute $period';
}

void openTaskEditor(
  RoutineController controller, {
  RoutineModel? existing,
}) {
  Get.bottomSheet(
    _TaskEditorSheet(
      controller: controller,
      existing: existing,
    ),
    isScrollControlled: true,
    backgroundColor: Get.theme.colorScheme.surface,
  );
}

class _TaskEditorSheet extends StatefulWidget {
  const _TaskEditorSheet({
    required this.controller,
    this.existing,
  });

  final RoutineController controller;
  final RoutineModel? existing;

  @override
  State<_TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _TaskEditorSheetState extends State<_TaskEditorSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late TimeOfDay _time;
  late String _iconName;

  static const Map<String, String> _icons = {
    'task': '✅',
    'sun': '☀️',
    'water': '💧',
    'clean': '🧼',
    'food': '🍽️',
    'walk': '🚶',
    'school': '🎒',
    'play': '🎮',
    'sleep': '🌙',
  };

  @override
  void initState() {
    super.initState();

    final existing = widget.existing;

    _titleController = TextEditingController(
      text: existing?.label ?? '',
    );

    _time = existing == null
        ? const TimeOfDay(hour: 7, minute: 0)
        : TimeOfDay(
            hour: existing.hour,
            minute: existing.minute,
          );

    _iconName = existing?.iconName ?? 'task';
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );

    if (picked != null && mounted) {
      setState(() => _time = picked);
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final existing = widget.existing;

    final item = RoutineModel(
      id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      label: _titleController.text.trim(),
      time: toStoredTime(_time),
      iconName: _iconName,
      enabled: existing?.enabled ?? true,
      isCompleted: existing?.isCompleted ?? false,
    );

    widget.controller.upsertItem(item);

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = Theme.of(context).extension<PlayfulColors>()!;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.existing == null ? '➕ إضافة مهمة' : '✏️ تعديل المهمة',
                textAlign: TextAlign.center,
                style: text.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'اسم المهمة',
                  prefixIcon: Icon(Icons.edit_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'اكتب اسم المهمة';
                  }

                  return null;
                },
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 12),
              Material(
                color: palette.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: _pickTime,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        const Text(
                          '🕒',
                          style: TextStyle(fontSize: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'وقت المهمة',
                            style: text.titleSmall?.copyWith(
                              color: palette.onPastel,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          formatTaskTime(
                            toStoredTime(_time),
                          ),
                          style: text.titleSmall?.copyWith(
                            color: palette.onPastel,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'أيقونة المهمة',
                style: text.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _icons.entries.map((entry) {
                  final selected = _iconName == entry.key;

                  return Material(
                    color: selected
                        ? palette.purple
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        setState(() {
                          _iconName = entry.key;
                        });
                      },
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: Center(
                          child: Text(
                            entry.value,
                            style: const TextStyle(
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              _PillButton(
                emoji: '✅',
                label: 'حفظ',
                color: palette.green,
                textColor: palette.onPastel,
                onTap: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoChildState extends StatelessWidget {
  const _NoChildState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '👧',
              style: TextStyle(fontSize: 52),
            ),
            SizedBox(height: 12),
            Text(
              'اختر طفلًا أولًا لإدارة روتينه',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
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
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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

Color _taskColor(PlayfulColors palette, int index) {
  final colors = [
    palette.yellow,
    palette.pink,
    palette.blue,
    palette.green,
    palette.purple,
    palette.orange,
  ];

  return colors[index % colors.length];
}

String _emojiOf(String iconName) {
  const icons = {
    'task': '✅',
    'sun': '☀️',
    'water': '💧',
    'clean': '🧼',
    'food': '🍽️',
    'walk': '🚶',
    'school': '🎒',
    'play': '🎮',
    'sleep': '🌙',
  };

  return icons[iconName] ?? '✅';
}
