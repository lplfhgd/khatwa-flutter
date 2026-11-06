import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/playful_colors.dart';
import '../controllers/children_controller.dart';
import '../models/child_model.dart';

class ChildProfileEditor extends StatefulWidget {
  const ChildProfileEditor({
    super.key,
    this.child,
  });

  final ChildModel? child;

  @override
  State<ChildProfileEditor> createState() => _ChildProfileEditorState();
}

class _ChildProfileEditorState extends State<ChildProfileEditor> {
  final _formKey = GlobalKey<FormState>();

  final ChildrenController childrenController = Get.find<ChildrenController>();

  late final TextEditingController _name;
  late final TextEditingController _birthYear;

  late CommunicationMethod _communicationMethod;
  late Set<SensoryPreference> _sensoryPreferences;
  late Set<DailyGoal> _goals;
  late LessonUnit _lessonUnit;
  late ChildGender _gender;

  bool get _isEditing => widget.child != null;

  @override
  void initState() {
    super.initState();

    final child = widget.child;
    _gender = child?.gender ?? ChildGender.male;

    _name = TextEditingController(
      text: child?.name ?? '',
    );

    _birthYear = TextEditingController(
      text: child?.birthYear?.toString() ?? '',
    );

    _communicationMethod =
        child?.communicationMethod ?? CommunicationMethod.picturesAndSound;

    _sensoryPreferences = {
      ...?child?.sensoryPreferences,
    };

    _goals = {
      ...?child?.goals,
    };

    _lessonUnit = child?.lessonUnit ?? LessonUnit.communication;
  }

  @override
  void dispose() {
    _name.dispose();
    _birthYear.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (childrenController.isSaving.value ||
        !_formKey.currentState!.validate()) {
      return;
    }

    final name = _name.text.trim();
    final yearText = _birthYear.text.trim();
    final year = yearText.isEmpty ? null : int.parse(yearText);

    final bool succeeded;

    if (widget.child == null) {
      succeeded = await childrenController.addChild(
        name: name,
        birthYear: year,
        gender: _gender,
        communicationMethod: _communicationMethod,
        sensoryPreferences: _sensoryPreferences,
        goals: _goals,
        lessonUnit: _lessonUnit,
      );
    } else {
      succeeded = await childrenController.updateChild(
        childId: widget.child!.id,
        name: name,
        birthYear: year,
        gender: _gender,
        communicationMethod: _communicationMethod,
        sensoryPreferences: _sensoryPreferences,
        goals: _goals,
        lessonUnit: _lessonUnit,
      );
    }

    if (succeeded && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PlayfulColors>()!;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'تعديل ملف الطفل' : 'إضافة طفل',
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(palette: palette),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _name,
                      maxLength: 40,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'اسم الطفل',
                        prefixIcon: Icon(Icons.face_rounded),
                      ),
                      validator: (value) {
                        final name = (value ?? '').trim();

                        if (name.isEmpty) {
                          return 'أدخل اسم الطفل';
                        }

                        if (name.length < 2) {
                          return 'الاسم قصير جدًا';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _birthYear,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      decoration: const InputDecoration(
                        labelText: 'سنة الميلاد (اختياري)',
                        prefixIcon: Icon(Icons.calendar_today_rounded),
                      ),
                      validator: (value) {
                        final valueText = (value ?? '').trim();

                        if (valueText.isEmpty) {
                          return null;
                        }

                        final year = int.tryParse(valueText);
                        final currentYear = DateTime.now().year;

                        if (year == null || year < 2000 || year > currentYear) {
                          return 'أدخل سنة صحيحة بين 2000 و$currentYear';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 28),
                    _Section(
                      title: 'الجنس',
                      hint: 'اختر جنس الطفل لتخصيص صورته داخل التطبيق.',
                      child: Row(
                        children: [
                          Expanded(
                            child: _GenderCard(
                              label: 'ولد',
                              imagePath: 'assets/images/parent/boy.png',
                              color: palette.blue,
                              selected: _gender == ChildGender.male,
                              onTap: () {
                                setState(() {
                                  _gender = ChildGender.male;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _GenderCard(
                              label: 'بنت',
                              imagePath: 'assets/images/parent/girl.png',
                              color: palette.pink,
                              selected: _gender == ChildGender.female,
                              onTap: () {
                                setState(() {
                                  _gender = ChildGender.female;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    _Section(
                      title: 'طريقة التواصل',
                      hint: 'اختر الطريقة الأنسب التي يتفاعل بها الطفل.',
                      child: _ChoiceRow<CommunicationMethod>(
                        values: CommunicationMethod.values,
                        selected: {_communicationMethod},
                        emojiOf: _communicationEmoji,
                        labelOf: _communicationLabel,
                        colorOf: (value) => _communicationColor(palette, value),
                        onTap: (value) {
                          setState(() {
                            _communicationMethod = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 28),
                    _Section(
                      title: 'التفضيلات الحسية',
                      hint: 'يمكنك اختيار أكثر من تفضيل يناسب الطفل.',
                      child: _ChoiceRow<SensoryPreference>(
                        values: SensoryPreference.values,
                        selected: _sensoryPreferences,
                        emojiOf: _sensoryEmoji,
                        labelOf: _sensoryLabel,
                        colorOf: (value) => _sensoryColor(palette, value),
                        onTap: (value) {
                          setState(() {
                            if (_sensoryPreferences.contains(value)) {
                              _sensoryPreferences.remove(value);
                            } else {
                              _sensoryPreferences.add(value);
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 28),
                    _Section(
                      title: 'الأهداف اليومية',
                      hint: 'حدد المهارات التي تريد التركيز عليها مع الطفل.',
                      child: _ChoiceRow<DailyGoal>(
                        values: DailyGoal.values,
                        selected: _goals,
                        emojiOf: _goalEmoji,
                        labelOf: _goalLabel,
                        colorOf: (value) => _goalColor(palette, value),
                        onTap: (value) {
                          setState(() {
                            if (_goals.contains(value)) {
                              _goals.remove(value);
                            } else {
                              _goals.add(value);
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 28),
                    _Section(
                      title: 'الوحدة التعليمية',
                      hint: 'اختر الوحدة التي تريد البدء بها.',
                      child: _ChoiceRow<LessonUnit>(
                        values: LessonUnit.values,
                        selected: {_lessonUnit},
                        emojiOf: _unitEmoji,
                        labelOf: _unitLabel,
                        colorOf: (value) => _unitColor(palette, value),
                        onTap: (value) {
                          setState(() {
                            _lessonUnit = value;
                          });
                        },
                      ),
                    ),
                    Obx(() {
                      final error = childrenController.errorMessage.value;

                      if (error == null) {
                        return const SizedBox.shrink();
                      }

                      return Container(
                        margin: const EdgeInsets.only(top: 24),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: scheme.errorContainer,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          error,
                          style: textTheme.bodyMedium?.copyWith(
                            color: scheme.onErrorContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 28),
                    Obx(() {
                      final saving = childrenController.isSaving.value;

                      return FilledButton(
                        onPressed: saving ? null : _save,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          shape: const StadiumBorder(),
                        ),
                        child: saving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                _isEditing ? 'حفظ التعديلات' : 'حفظ ومتابعة',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      );
                    }),
                  ],
                ),
              ),
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
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
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
            child: Text(
              'ساعدنا في معرفة ما يناسب طفلك لنقدم له تجربة أفضل.',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: palette.onPastel,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.hint,
    required this.child,
  });

  final String title;
  final String hint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          hint,
          style: textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),
        child,
      ],
    );
  }
}

class _GenderCard extends StatelessWidget {
  const _GenderCard({
    required this.label,
    required this.imagePath,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String imagePath;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final palette = Theme.of(context).extension<PlayfulColors>()!;

    final radius = BorderRadius.circular(24);

    return AnimatedScale(
      scale: selected ? 1.03 : 1,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutBack,
      child: Material(
        color: color,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: selected ? scheme.primary : Colors.transparent,
                width: 3,
              ),
            ),
            child: Row(
              children: [
                ClipOval(
                  child: Image.asset(
                    imagePath,
                    width: 58,
                    height: 58,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: text.titleMedium?.copyWith(
                      color: palette.onPastel,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (selected)
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: scheme.primary,
                    child: Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: scheme.onPrimary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChoiceRow<T> extends StatelessWidget {
  const _ChoiceRow({
    required this.values,
    required this.selected,
    required this.emojiOf,
    required this.labelOf,
    required this.colorOf,
    required this.onTap,
  });

  final List<T> values;
  final Set<T> selected;
  final String Function(T) emojiOf;
  final String Function(T) labelOf;
  final Color Function(T) colorOf;
  final void Function(T) onTap;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          for (final value in values)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: _ChoiceCard(
                  emoji: emojiOf(value),
                  label: labelOf(value),
                  color: colorOf(value),
                  selected: selected.contains(value),
                  onTap: () => onTap(value),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.emoji,
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<PlayfulColors>()!;
    final textTheme = Theme.of(context).textTheme;

    final radius = BorderRadius.circular(24);

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: AnimatedScale(
        scale: selected ? 1.05 : 1,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        child: Material(
          color: color,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.fromLTRB(6, 16, 6, 14),
              decoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(
                  color: selected ? scheme.primary : Colors.transparent,
                  width: 3,
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          emoji,
                          style: const TextStyle(fontSize: 36),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          style: textTheme.labelLarge?.copyWith(
                            color: palette.onPastel,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selected)
                    PositionedDirectional(
                      top: -4,
                      end: -4,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: scheme.primary,
                        child: Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: scheme.onPrimary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _communicationEmoji(CommunicationMethod value) {
  return switch (value) {
    CommunicationMethod.picturesAndSound => '🖼️🔊',
    CommunicationMethod.sound => '🔊',
    CommunicationMethod.pictures => '🖼️',
  };
}

String _communicationLabel(CommunicationMethod value) {
  return switch (value) {
    CommunicationMethod.picturesAndSound => 'صور وصوت',
    CommunicationMethod.sound => 'صوت',
    CommunicationMethod.pictures => 'صور',
  };
}

Color _communicationColor(
  PlayfulColors palette,
  CommunicationMethod value,
) {
  return switch (value) {
    CommunicationMethod.picturesAndSound => palette.pink,
    CommunicationMethod.sound => palette.blue,
    CommunicationMethod.pictures => palette.green,
  };
}

String _sensoryEmoji(SensoryPreference value) {
  return switch (value) {
    SensoryPreference.calmColors => '🎨',
    SensoryPreference.calmSounds => '🔇',
    SensoryPreference.dimLights => '🌃',
  };
}

String _sensoryLabel(SensoryPreference value) {
  return switch (value) {
    SensoryPreference.calmColors => 'ألوان هادئة',
    SensoryPreference.calmSounds => 'أصوات هادئة',
    SensoryPreference.dimLights => 'إضاءة خافتة',
  };
}

Color _sensoryColor(
  PlayfulColors palette,
  SensoryPreference value,
) {
  return switch (value) {
    SensoryPreference.calmColors => palette.purple,
    SensoryPreference.calmSounds => palette.blue,
    SensoryPreference.dimLights => palette.yellow,
  };
}

String _goalEmoji(DailyGoal value) {
  return switch (value) {
    DailyGoal.emotions => '❤️',
    DailyGoal.routine => '📋',
    DailyGoal.requests => '✋',
  };
}

String _goalLabel(DailyGoal value) {
  return switch (value) {
    DailyGoal.emotions => 'المشاعر',
    DailyGoal.routine => 'الروتين',
    DailyGoal.requests => 'الطلبات',
  };
}

Color _goalColor(
  PlayfulColors palette,
  DailyGoal value,
) {
  return switch (value) {
    DailyGoal.emotions => palette.pink,
    DailyGoal.routine => palette.green,
    DailyGoal.requests => palette.orange,
  };
}

String _unitEmoji(LessonUnit value) {
  return switch (value) {
    LessonUnit.communication => '💬',
    LessonUnit.emotions => '😊',
    LessonUnit.routine => '🗓️',
  };
}

String _unitLabel(LessonUnit value) {
  return switch (value) {
    LessonUnit.communication => 'التواصل',
    LessonUnit.emotions => 'المشاعر',
    LessonUnit.routine => 'الروتين',
  };
}

Color _unitColor(
  PlayfulColors palette,
  LessonUnit value,
) {
  return switch (value) {
    LessonUnit.communication => palette.blue,
    LessonUnit.emotions => palette.pink,
    LessonUnit.routine => palette.yellow,
  };
}
