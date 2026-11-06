import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../children/controllers/children_controller.dart';

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
      appBar: tab == 0
          ? const _ParentHomeAppBar()
          : AppBar(
              title: Text(
                ['الرئيسية', 'المحتوى', 'التقدم', 'الإعدادات'][tab],
              ),
              centerTitle: true,
            ),
      body: pages[tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: changeTab,
        destinations: const [
          NavigationDestination(
            icon: _NavEmoji('🏠'),
            selectedIcon: _NavEmoji('🏠'),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: _NavEmoji('📚'),
            selectedIcon: _NavEmoji('📚'),
            label: 'المحتوى',
          ),
          NavigationDestination(
            icon: _NavEmoji('📊'),
            selectedIcon: _NavEmoji('📊'),
            label: 'التقدم',
          ),
          NavigationDestination(
            icon: _NavEmoji('⚙️'),
            selectedIcon: _NavEmoji('⚙️'),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }
}

class _ParentHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ParentHomeAppBar();

  static const double _height = 92;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: _height,
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: Image.asset(
        'assets/images/parent/logo.png',
        height: 90,
        width: 70,
        fit: BoxFit.fill,
      ),
      actions: [
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 12),
          child: IconButton(
            tooltip: 'الإشعارات',
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {
              Get.bottomSheet(
                const SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none_rounded),
                        SizedBox(width: 10),
                        Text('لا توجد إشعارات جديدة'),
                      ],
                    ),
                  ),
                ),
                backgroundColor: Theme.of(context).colorScheme.surface,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _NavEmoji extends StatelessWidget {
  const _NavEmoji(this.emoji);

  final String emoji;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(
            fontSize: 22,
            height: 1,
          ),
        ),
      ),
    );
  }
}
