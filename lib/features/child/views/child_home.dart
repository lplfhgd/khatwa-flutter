import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/k_colors.dart';
import '../../children/controllers/selected_child_controller.dart';

class ChildHome extends StatelessWidget {
  const ChildHome({
    super.key,
    required this.openTab,
  });

  final ValueChanged<int> openTab;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Obx(
          () => Text(
            'أهلًا يا ${Get.find<SelectedChildController>().childName.value}!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'ماذا تريد أن تفعل اليوم؟',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 28),
        ChildEntry(
          title: 'أتواصل',
          icon: Icons.chat_bubble_outline,
          color: KColors.soft,
          onTap: () => openTab(1),
        ),
        ChildEntry(
          title: 'روتيني',
          icon: Icons.calendar_today_outlined,
          color: const Color(0xFFFFF1D0),
          onTap: () => openTab(2),
        ),
        ChildEntry(
          title: 'ألعابي',
          icon: Icons.extension_outlined,
          color: const Color(0xFFE8EFFA),
          onTap: () => openTab(3),
        ),
      ],
    );
  }
}

class ChildEntry extends StatelessWidget {
  const ChildEntry({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          constraints: const BoxConstraints(minHeight: 120),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 58,
                color: KColors.primary,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_back_ios_new,
                color: KColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
