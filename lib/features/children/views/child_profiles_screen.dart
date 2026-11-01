import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/k_colors.dart';
import '../../../shared/widgets/k_button.dart';
import '../../../shared/widgets/k_card.dart';
import '../controllers/children_controller.dart';
import '../controllers/selected_child_controller.dart';
import 'child_profile_editor.dart';

class ChildProfilesScreen extends StatelessWidget {
  const ChildProfilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final childrenController = Get.find<ChildrenController>();
    final selectedController = Get.find<SelectedChildController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ملفات الأطفال'),
      ),
      body: Obx(() {
        final children = childrenController.children.toList();
        final loading = childrenController.isLoading.value;
        final error = childrenController.errorMessage.value;
        final selectedId = selectedController.selectedChildId.value;

        if (loading && children.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (error != null && children.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    error,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  KButton(
                    label: 'إعادة المحاولة',
                    onPressed: childrenController.startWatching,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'إدارة أطفال العائلة',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: KColors.text,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'استخدم أسماء تجريبية فقط خلال التطوير. يتيح لك الاختيار تحديد الطفل النشط في هذه الجلسة.',
            ),
            const SizedBox(height: 18),
            KButton(
              label: 'إضافة طفل جديد',
              onPressed: () => Get.to(
                () => const ChildProfileEditor(),
              ),
            ),
            const SizedBox(height: 18),
            if (error != null) ...[
              Text(
                error,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 12),
            ],
            if (children.isEmpty)
              const KCard(
                child: Text(
                  'لا توجد ملفات أطفال حاليًا. اضغط «إضافة طفل جديد» للبدء.',
                ),
              ),
            ...children.map((child) {
              final isSelected = selectedId == child.id;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: KCard(
                  tint: isSelected ? KColors.soft : Colors.white,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.child_care_outlined,
                      color: KColors.primary,
                      size: 32,
                    ),
                    title: Text(
                      child.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      child.birthYear == null
                          ? 'سنة الميلاد غير محددة'
                          : 'سنة الميلاد: ${child.birthYear}',
                    ),
                    onTap: () {
                      childrenController.selectChild(child);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم اختيار ${child.name} للواجهة التجريبية.',
                          ),
                        ),
                      );
                    },
                    trailing: IconButton(
                      tooltip: 'تعديل الملف',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => Get.to(
                        () => ChildProfileEditor(
                          childId: child.id,
                          initialName: child.name,
                          initialBirthYear: child.birthYear,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      }),
    );
  }
}
