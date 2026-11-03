import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../aac/views/child_aac.dart';
import '../../activities/views/child_activities.dart';
import '../../children/controllers/selected_child_controller.dart';
import '../../pairing/models/linked_child_model.dart';
import '../../pairing/services/linked_child_storage.dart';
import '../../pairing/services/linked_device_service.dart';
import '../../role/views/role_screen.dart';
import '../../routine/views/child_routine.dart';
import 'child_home.dart';

class ChildShell extends StatefulWidget {
  const ChildShell({super.key});

  @override
  State<ChildShell> createState() => _ChildShellState();
}

class _ChildShellState extends State<ChildShell> with WidgetsBindingObserver {
  final LinkedChildStorage _linkedChildStorage = Get.find<LinkedChildStorage>();

  final LinkedDeviceService _linkedDeviceService =
      Get.find<LinkedDeviceService>();

  StreamSubscription<bool>? _deviceSubscription;
  Timer? _heartbeatTimer;

  LinkedChildModel? _linkedChild;

  int tab = 0;
  bool _isRevoking = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _startDeviceMonitoring();
  }

  Future<void> _startDeviceMonitoring() async {
    final LinkedChildModel? linkedChild = await _linkedChildStorage.read();

    if (linkedChild == null || !mounted) {
      return;
    }

    _linkedChild = linkedChild;

    _deviceSubscription =
        _linkedDeviceService.watchDeviceActive(linkedChild).listen(
      (isActive) {
        if (!isActive) {
          _handleDeviceRevoked();
        }
      },
      onError: (_) {
        // إذا انقطع الإنترنت لا نلغي الربط المحلي.
        // سيستمر التطبيق بالعمل، وسيعود الـStream للمراقبة
        // عند استعادة الاتصال.
      },
    );

    if (!mounted || _isRevoking) {
      return;
    }

    _startHeartbeat();
  }

  Future<void> _sendHeartbeat() async {
    final linkedChild = _linkedChild;

    if (linkedChild == null || _isRevoking) {
      return;
    }

    try {
      await _linkedDeviceService.updateLastSeen(linkedChild);
    } catch (_) {
      // فشل تحديث آخر نشاط لا يجب أن يعطل تجربة الطفل.
      // ستتم المحاولة مجددًا في الـ heartbeat التالي.
    }
  }

  Future<void> _handleDeviceRevoked() async {
    if (_isRevoking) {
      return;
    }

    _isRevoking = true;

    _stopHeartbeat();

    await _deviceSubscription?.cancel();
    _deviceSubscription = null;

    await _linkedChildStorage.clear();

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null && currentUser.isAnonymous) {
      await FirebaseAuth.instance.signOut();
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const RoleScreen(),
      ),
      (route) => false,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _startHeartbeat();
      return;
    }

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      _stopHeartbeat();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _stopHeartbeat();
    _deviceSubscription?.cancel();

    super.dispose();
  }

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

  void _startHeartbeat() {
    if (_isRevoking || _linkedChild == null) {
      return;
    }

    _heartbeatTimer?.cancel();

    _sendHeartbeat();

    _heartbeatTimer = Timer.periodic(
      const Duration(minutes: 3),
      (_) {
        _sendHeartbeat();
      },
    );
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }
}
