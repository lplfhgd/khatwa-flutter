import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../aac/views/child_aac.dart';
import '../../activities/views/child_activities.dart';
import '../../children/controllers/selected_child_controller.dart';
import '../../routine/views/child_routine.dart';
import 'child_home.dart';

class ChildShell extends StatefulWidget {
  const ChildShell({super.key});

  @override
  State<ChildShell> createState() => _ChildShellState();
}

class _ChildShellState extends State<ChildShell> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            '${Get.find<SelectedChildController>().childName.value} • خطوة',
          ),
        ),
      ),
      body: [
        ChildHome(
          openTab: (index) {
            setState(() {
              tab = index;
            });
          },
        ),
        const ChildAac(),
        const ChildRoutine(),
        const ChildActivities(),
      ][tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (value) {
          setState(() {
            tab = value;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'أتواصل',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            label: 'روتيني',
          ),
          NavigationDestination(
            icon: Icon(Icons.extension_outlined),
            label: 'ألعابي',
          ),
        ],
      ),
    );
  }
}
