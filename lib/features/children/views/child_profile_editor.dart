import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/k_colors.dart';
import '../../../shared/widgets/k_button.dart';
import '../controllers/children_controller.dart';

class ChildProfileEditor extends StatefulWidget {
  const ChildProfileEditor({
    super.key,
    this.childId,
    this.initialName,
    this.initialBirthYear,
  });

  final String? childId;
  final String? initialName;
  final int? initialBirthYear;

  @override
  State<ChildProfileEditor> createState() => _ChildProfileEditorState();
}

class _ChildProfileEditorState extends State<ChildProfileEditor> {
  final _formKey = GlobalKey<FormState>();

  final ChildrenController childrenController = Get.find<ChildrenController>();

  late final TextEditingController _name;
  late final TextEditingController _birthYear;

  @override
  void initState() {
    super.initState();

    _name = TextEditingController(
      text: widget.initialName ?? '',
    );

    _birthYear = TextEditingController(
      text: widget.initialBirthYear?.toString() ?? '',
    );
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

    if (widget.childId == null) {
      succeeded = await childrenController.addChild(
        name: name,
        birthYear: year,
      );
    } else {
      succeeded = await childrenController.updateChild(
        childId: widget.childId!,
        name: name,
        birthYear: year,
      );
    }

    if (succeeded && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(
            widget.childId == null ? 'إضافة طفل' : 'تعديل ملف طفل',
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'ملف الطفل',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      color: KColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'للاختبار استخدم بيانات وهمية، ولا تدخل معلومات طفل حقيقي.',
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _name,
                    maxLength: 40,
                    decoration: const InputDecoration(
                      labelText: 'اسم الطفل التجريبي',
                      prefixIcon: Icon(
                        Icons.child_care_outlined,
                      ),
                    ),
                    validator: (value) {
                      final name = (value ?? '').trim();

                      if (name.isEmpty) {
                        return 'أدخل اسمًا تجريبيًا';
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
                      prefixIcon: Icon(
                        Icons.calendar_today_outlined,
                      ),
                    ),
                    validator: (value) {
                      final text = (value ?? '').trim();

                      if (text.isEmpty) {
                        return null;
                      }

                      final year = int.tryParse(text);
                      final currentYear = DateTime.now().year;

                      if (year == null || year < 2000 || year > currentYear) {
                        return 'أدخل سنة صحيحة بين 2000 و$currentYear';
                      }

                      return null;
                    },
                  ),
                  Obx(() {
                    final error = childrenController.errorMessage.value;

                    if (error == null) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        error,
                        style: const TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  Obx(() {
                    final saving = childrenController.isSaving.value;

                    return KButton(
                      label: saving ? 'جاري الحفظ...' : 'حفظ ملف الطفل',
                      onPressed: saving ? null : _save,
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      );
}
