import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../controllers/notification_preferences_controller.dart';
import 'notification_device_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../parent/controllers/parent_navigation_controller.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  NotificationService();
  bool _initialized = false;
  bool _initializing = false;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<String>? _registrationSubscription;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<RemoteMessage>? _notificationOpenedSubscription;

  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    'khatwa_general',
    'إشعارات خطوة',
    description: 'الإشعارات والتنبيهات العامة لتطبيق خطوة',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    if (_initialized || _initializing) return;

    _initializing = true;

    try {
      await _initializeLocalNotifications();
      await _createAndroidChannel();

      _listenForRegistrationUpdates();
      _listenForForegroundMessages();
      _listenForNotificationOpens();
      _listenForAuthChanges();

      await _registerForMessaging();
      await _handleInitialMessage();
      _initialized = true;
    } finally {
      _initializing = false;
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
    );
  }

  Future<void> _createAndroidChannel() async {
    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(
      _androidChannel,
    );
  }

  Future<NotificationSettings> requestPermission() {
    return _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<bool> areNotificationsAuthorized() async {
    final settings = await _messaging.getNotificationSettings();

    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<void> _registerForMessaging() async {
    await _messaging.register();
  }

  Future<void> syncCurrentDevice() async {
    await initialize();

    final token = _fcmToken;

    if (token == null || token.trim().isEmpty) {
      await _registerForMessaging();
      return;
    }

    if (!Get.isRegistered<NotificationDeviceService>()) {
      return;
    }

    var notificationsEnabled = true;

    if (Get.isRegistered<NotificationPreferencesController>()) {
      notificationsEnabled =
          Get.find<NotificationPreferencesController>().enabled.value;
    }

    await Get.find<NotificationDeviceService>().saveDevice(
      fcmToken: token,
      notificationsEnabled: notificationsEnabled,
    );
  }

  void _listenForRegistrationUpdates() {
    _registrationSubscription?.cancel();

    _registrationSubscription = _messaging.onRegistered.listen(
      (token) async {
        _fcmToken = token;

        if (!Get.isRegistered<NotificationDeviceService>()) {
          return;
        }

        final deviceService = Get.find<NotificationDeviceService>();

        var notificationsEnabled = true;

        if (Get.isRegistered<NotificationPreferencesController>()) {
          notificationsEnabled =
              Get.find<NotificationPreferencesController>().enabled.value;
        }

        try {
          await deviceService.saveDevice(
            fcmToken: token,
            notificationsEnabled: notificationsEnabled,
          );
        } catch (_) {}
      },
    );
  }

  void _listenForAuthChanges() {
    _authSubscription?.cancel();

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen(
      (user) async {
        if (user == null || user.isAnonymous) {
          return;
        }

        try {
          await syncCurrentDevice();
        } catch (_) {
          // فشل مزامنة الإشعارات لا يجب أن يمنع المستخدم
          // من تسجيل الدخول أو استخدام التطبيق.
        }
      },
    );
  }

  void _listenForForegroundMessages() {
    _foregroundSubscription?.cancel();

    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      (message) async {
        await showRemoteMessage(message);
      },
    );
  }

  void _listenForNotificationOpens() {
    _notificationOpenedSubscription?.cancel();

    _notificationOpenedSubscription =
        FirebaseMessaging.onMessageOpenedApp.listen(
      _handleNotificationOpen,
    );
  }

  Future<void> _handleInitialMessage() async {
    final message = await _messaging.getInitialMessage();

    if (message == null) {
      return;
    }

    _handleNotificationOpen(message);
  }

  void _handleNotificationOpen(RemoteMessage message) {
    debugPrint('NOTIFICATION OPENED');
    debugPrint('NOTIFICATION DATA: ${message.data}');
    debugPrint('NOTIFICATION TYPE: ${message.data['type']}');

    if (!Get.isRegistered<ParentNavigationController>()) {
      debugPrint('ParentNavigationController NOT REGISTERED');
      return;
    }

    final navigationController = Get.find<ParentNavigationController>();
    final type = message.data['type'];

    switch (type) {
      case 'progress':
        debugPrint('OPENING PROGRESS TAB');
        navigationController.openProgress();
        break;

      case 'general':
        navigationController.openHome();
        break;

      case 'device':
        navigationController.openSettings();
        break;

      case 'routine':
        navigationController.openContent();
        break;

      default:
        debugPrint('UNKNOWN NOTIFICATION TYPE: $type');
        navigationController.openHome();
    }
  }

  Future<void> showRemoteMessage(RemoteMessage message) async {
    final notification = message.notification;

    if (notification == null) {
      return;
    }

    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title ?? 'خطوة',
      body: notification.body ?? '',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'khatwa_general',
          'إشعارات خطوة',
          channelDescription: 'الإشعارات والتنبيهات العامة لتطبيق خطوة',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> showTestNotification() async {
    await _localNotifications.show(
      id: 1001,
      title: 'خطوة',
      body: 'تم تفعيل الإشعارات بنجاح 🌱',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'khatwa_general',
          'إشعارات خطوة',
          channelDescription: 'الإشعارات والتنبيهات العامة لتطبيق خطوة',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> dispose() async {
    await _foregroundSubscription?.cancel();
    await _notificationOpenedSubscription?.cancel();
    await _registrationSubscription?.cancel();
    await _authSubscription?.cancel();
  }
}
