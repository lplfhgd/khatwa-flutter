import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class NotificationDeviceService {
  NotificationDeviceService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  static const _deviceIdKey = 'notification_device_id';

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Future<String> getOrCreateDeviceId() async {
    final preferences = await SharedPreferences.getInstance();

    final existingId = preferences.getString(_deviceIdKey);

    if (existingId != null && existingId.trim().isNotEmpty) {
      return existingId;
    }

    final deviceId = const Uuid().v4();

    await preferences.setString(
      _deviceIdKey,
      deviceId,
    );

    return deviceId;
  }

  Future<void> saveDevice({
    required String fcmToken,
    required bool notificationsEnabled,
  }) async {
    final user = _auth.currentUser;

    if (user == null || user.isAnonymous) {
      throw StateError('لا يوجد حساب ولي أمر مسجل حاليًا.');
    }

    final token = fcmToken.trim();

    if (token.isEmpty) {
      throw StateError('تعذر الحصول على رمز الإشعارات للجهاز.');
    }

    final deviceId = await getOrCreateDeviceId();

    final deviceRef = _firestore
        .collection('parents')
        .doc(user.uid)
        .collection('notificationDevices')
        .doc(deviceId);

    await deviceRef.set(
      {
        'fcmToken': token,
        'platform': 'android',
        'notificationsEnabled': notificationsEnabled,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> updateEnabled(bool enabled) async {
    final user = _auth.currentUser;

    if (user == null || user.isAnonymous) {
      return;
    }

    final deviceId = await getOrCreateDeviceId();

    final deviceRef = _firestore
        .collection('parents')
        .doc(user.uid)
        .collection('notificationDevices')
        .doc(deviceId);

    await deviceRef.set(
      {
        'notificationsEnabled': enabled,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> removeCurrentDevice() async {
    final user = _auth.currentUser;

    if (user == null || user.isAnonymous) {
      return;
    }

    final deviceId = await getOrCreateDeviceId();

    await _firestore
        .collection('parents')
        .doc(user.uid)
        .collection('notificationDevices')
        .doc(deviceId)
        .delete();
  }
}
