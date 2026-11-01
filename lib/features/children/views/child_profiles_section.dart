import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/k_colors.dart';
import '../../../shared/widgets/k_button.dart';
import '../../../shared/widgets/k_card.dart';
import '../controllers/children_controller.dart';
import '../controllers/selected_child_controller.dart';
import 'child_profiles_screen.dart';

class ChildProfilesSection extends StatelessWidget {
  const ChildProfilesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final childrenController = Get.find<ChildrenController>();
    final selectedController = Get.find<SelectedChildController>();

    return Obx(() {
      final children = childrenController.children;
      final loading = childrenController.isLoading.value;
      final error = childrenController.errorMessage.value;
      final selectedId = selectedController.selectedChildId.value;

      if (loading && children.isEmpty) {
        return const KCard(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (error != null && children.isEmpty) {
        return KCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(error),
              const SizedBox(height: 8),
              KButton(
                label: 'إعادة المحاولة',
                outlined: true,
                onPressed: childrenController.startWatching,
              ),
            ],
          ),
        );
      }

      final selected = children.where(
        (child) => child.id == selectedId,
      );

      final activeName =
          selected.isEmpty ? 'لم يتم اختيار طفل' : selected.first.name;

      return KCard(
        tint: KColors.soft,
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const CircleAvatar(
            radius: 29,
            child: Icon(
              Icons.child_care,
              size: 32,
            ),
          ),
          title: Text(
            activeName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            children.isEmpty
                ? 'لا توجد ملفات أطفال بعد. أضف طفلًا تجريبيًا.'
                : 'ملفات الأطفال: ${children.length} • اضغط للإدارة أو اختيار طفل',
          ),
          trailing: const Icon(Icons.chevron_left),
          onTap: () => Get.to(
            () => const ChildProfilesScreen(),
          ),
        ),
      );
    });
  }
}
