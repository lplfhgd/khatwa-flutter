import 'package:flutter/material.dart';
import '../../children/controllers/children_controller.dart';
import 'package:get/get.dart';

class ParentShell extends StatefulWidget {
  const ParentShell({
    super.key,
    required this.homeBuilder,
    required this.content,
    required this.progress,
    required this.settings,
  });

  final Widget Function(ValueChanged<int> navigate) homeBuilder;
  final Widget content;
  final Widget progress;
  final Widget settings;

  @override
  State<ParentShell> createState() => _ParentShellState();
}

class _ParentShellState extends State<ParentShell> {
  int tab = 0;

  @override
  void initState() {
    super.initState();
    Get.find<ChildrenController>().startWatching();
  }

  void changeTab(int index) {
    setState(() {
      tab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      widget.homeBuilder(changeTab),
      widget.content,
      widget.progress,
      widget.settings,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          ['الرئيسية', 'المحتوى', 'التقدم', 'الإعدادات'][tab],
        ),
      ),
      body: pages[tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: changeTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            label: 'المحتوى',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'التقدم',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }
}
