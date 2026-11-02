import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../child/views/child_shell.dart';
import '../../pairing/models/linked_child_model.dart';
import '../../pairing/services/linked_child_storage.dart';
import '../../pairing/services/linked_device_service.dart';
import '../../role/views/role_screen.dart';

class AppStartScreen extends StatefulWidget {
  const AppStartScreen({super.key});

  @override
  State<AppStartScreen> createState() => _AppStartScreenState();
}

class _AppStartScreenState extends State<AppStartScreen> {
  final LinkedChildStorage _linkedChildStorage = Get.find<LinkedChildStorage>();

  final LinkedDeviceService _linkedDeviceService =
      Get.find<LinkedDeviceService>();

  late final Future<bool> _startupCheck;

  @override
  void initState() {
    super.initState();
    _startupCheck = _checkLinkedDevice();
  }

  Future<bool> _checkLinkedDevice() async {
    final LinkedChildModel? linkedChild = await _linkedChildStorage.read();

    if (linkedChild == null) {
      return false;
    }

    try {
      final isActive = await _linkedDeviceService.isDeviceActive(linkedChild);

      if (!isActive) {
        await _linkedChildStorage.clear();

        final currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser != null && currentUser.isAnonymous) {
          await FirebaseAuth.instance.signOut();
        }

        return false;
      }

      return true;
    } catch (_) {
      // في حال تعذر الاتصال بالإنترنت لا نمسح الربط المحلي.
      // نسمح بالدخول مؤقتًا حتى لا يتعطل تطبيق الطفل بسبب الشبكة.
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _startupCheck,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.data == true) {
          return const ChildShell();
        }

        return const RoleScreen();
      },
    );
  }
}
