import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/k_colors.dart';
import '../../pairing/services/linked_child_storage.dart';

class ChildHome extends StatefulWidget {
  const ChildHome({
    super.key,
    required this.openTab,
  });

  final ValueChanged<int> openTab;

  @override
  State<ChildHome> createState() => _ChildHomeState();
}

class _ChildHomeState extends State<ChildHome> {
  final LinkedChildStorage _linkedChildStorage =
      Get.find<LinkedChildStorage>();

  String? _childName;

  @override
  void initState() {
    super.initState();
    _loadLinkedChild();
  }

  Future<void> _loadLinkedChild() async {
    final linkedChild = await _linkedChildStorage.read();

    if (!mounted) return;

    setState(() {
      _childName = linkedChild?.childName;
    });
  }

  @override
  Widget build(BuildContext context) {
    final childName = _childName;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          childName == null || childName.isEmpty
              ? 'أهلًا!'
              : 'أهلًا يا $childName!',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
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
          onTap: () => widget.openTab(1),
        ),
        ChildEntry(
          title: 'روتيني',
          icon: Icons.calendar_today_outlined,
          color: const Color(0xFFFFF1D0),
          onTap: () => widget.openTab(2),
        ),
        ChildEntry(
          title: 'ألعابي',
          icon: Icons.extension_outlined,
          color: const Color(0xFFE8EFFA),
          onTap: () => widget.openTab(3),
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