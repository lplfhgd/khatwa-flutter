import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/k_colors.dart';
import '../../routine/controllers/routine_controller.dart';
import '../../../shared/widgets/k_card.dart';

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
    final routineController = Get.find<RoutineController>();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'أهلًا بك في خطوة',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: KColors.text,
          ),
        ),
        const SizedBox(height: 8),
        const Text('تابع رحلة طفلك، خطوة بخطوة'),
        const SizedBox(height: 20),
        childProfiles,
        const SizedBox(height: 20),
        Obx(() {
          final completed = routineController.completedCount;
          final total = routineController.routine.length;

          return KCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'روتين اليوم',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: routineController.progress,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(height: 8),
                Text('$completed من $total مهام مكتملة'),
              ],
            ),
          );
        }),
        const SizedBox(height: 18),
        const Text(
          'إدارة سريعة',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _Shortcut(
          icon: Icons.chat_bubble_outline,
          title: 'بطاقات التواصل AAC',
          onTap: () => navigate(1),
        ),
        _Shortcut(
          icon: Icons.calendar_month_outlined,
          title: 'إدارة الروتين المصور',
          onTap: onOpenRoutine,
        ),
        _Shortcut(
          icon: Icons.link_outlined,
          title: 'ربط جهاز الطفل',
          onTap: onOpenPairing,
        ),
        _Shortcut(
          icon: Icons.bar_chart_outlined,
          title: 'تقارير وملاحظات التقدم',
          onTap: () => navigate(2),
        ),
      ],
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: KCard(
        child: ListTile(
          leading: Icon(icon, color: KColors.primary, size: 29),
          title: Text(title),
          trailing: const Icon(Icons.chevron_left),
          onTap: onTap,
        ),
      ),
    );
  }
}
