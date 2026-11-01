import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../child/views/child_shell.dart';
import '../../pairing/services/linked_child_storage.dart';
import '../../role/views/role_screen.dart';

class AppStartScreen extends StatefulWidget {
  const AppStartScreen({super.key});

  @override
  State<AppStartScreen> createState() => _AppStartScreenState();
}

class _AppStartScreenState extends State<AppStartScreen> {
  final LinkedChildStorage _linkedChildStorage = Get.find<LinkedChildStorage>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _linkedChildStorage.read(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          return const ChildShell();
        }

        return const RoleScreen();
      },
    );
  }
}
