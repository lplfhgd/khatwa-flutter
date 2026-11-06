import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/linked_child_model.dart';
import '../models/pairing_model.dart';

class PairingService {
  PairingService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const Duration _pairingCodeLifetime = Duration(minutes: 9);

  CollectionReference<Map<String, dynamic>> get _pairingCodes =>
      _firestore.collection('pairingCodes');

  String _generateCode() {
    final random = Random.secure();
    return (100000 + random.nextInt(900000)).toString();
  }

  Future<PairingModel> createPairingCode({
    required String childId,
    required String childName,
  }) async {
    final user = _auth.currentUser;

    if (user == null || user.isAnonymous) {
      throw StateError('يجب تسجيل دخول ولي الأمر أولًا.');
    }

    final normalizedChildId = childId.trim();
    final normalizedChildName = childName.trim();

    if (normalizedChildId.isEmpty) {
      throw StateError('يجب اختيار طفل أولًا.');
    }

    if (normalizedChildName.isEmpty) {
      throw StateError('اسم الطفل غير صالح.');
    }

    final childRef = _firestore
        .collection('parents')
        .doc(user.uid)
        .collection('children')
        .doc(normalizedChildId);

    final childSnapshot = await childRef.get();

    if (!childSnapshot.exists) {
      throw StateError('لم يتم العثور على ملف الطفل.');
    }

    final code = _generateCode();
    final pairingRef = _pairingCodes.doc(code);

    final expiresAt = DateTime.now().add(
      _pairingCodeLifetime,
    );

    try {
      await pairingRef.set({
        'parentId': user.uid,
        'childId': normalizedChildId,
        'childName': normalizedChildName,
        'used': false,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(expiresAt),
        'claimedBy': null,
        'claimedAt': null,
      });

      return PairingModel(
        code: code,
        parentId: user.uid,
        childId: normalizedChildId,
        childName: normalizedChildName,
        expiresAt: expiresAt,
        used: false,
      );
    } on FirebaseException catch (error) {
      if (error.code == 'permission-denied') {
        throw StateError(
          'تعذر إنشاء رمز الربط. حاول إنشاء رمز جديد.',
        );
      }

      if (error.code == 'unavailable') {
        throw StateError(
          'تعذر الاتصال بالخادم. تحقق من الإنترنت وحاول مجددًا.',
        );
      }

      throw StateError(
        'تعذر إنشاء رمز الربط. حاول مجددًا.',
      );
    }
  }

  Future<LinkedChildModel> consumePairingCode(String code) async {
    final normalizedCode = code.trim();

    if (!RegExp(r'^\d{6}$').hasMatch(normalizedCode)) {
      throw StateError('رمز الربط يجب أن يتكون من 6 أرقام.');
    }

    var user = _auth.currentUser;

    if (user == null) {
      final credential = await _auth.signInAnonymously();
      user = credential.user;
    }

    if (user == null) {
      throw StateError('تعذر تهيئة جهاز الطفل.');
    }

    if (!user.isAnonymous) {
      throw StateError('يجب استخدام حساب جهاز الطفل لإتمام الربط.');
    }

    final deviceUid = user.uid;
    final pairingRef = _pairingCodes.doc(normalizedCode);

    try {
      return await _firestore.runTransaction<LinkedChildModel>(
        (transaction) async {
          // ---------------------------------------------------------
          // 1. قراءة رمز الربط
          // ---------------------------------------------------------

          final pairingSnapshot = await transaction.get(pairingRef);

          if (!pairingSnapshot.exists) {
            throw StateError('رمز الربط غير صحيح.');
          }

          final data = pairingSnapshot.data();

          if (data == null) {
            throw StateError('بيانات الربط غير صالحة.');
          }

          final used = data['used'] == true;
          final expiresAt = data['expiresAt'];

          if (used) {
            throw StateError('تم استخدام رمز الربط مسبقًا.');
          }

          if (expiresAt is! Timestamp) {
            throw StateError('بيانات صلاحية الرمز غير صالحة.');
          }

          if (expiresAt.toDate().isBefore(DateTime.now())) {
            throw StateError('انتهت صلاحية رمز الربط.');
          }

          final parentId = data['parentId'];
          final childId = data['childId'];
          final childName = data['childName'];

          if (parentId is! String ||
              parentId.isEmpty ||
              childId is! String ||
              childId.isEmpty ||
              childName is! String ||
              childName.isEmpty) {
            throw StateError('بيانات الربط غير صالحة.');
          }

          // ---------------------------------------------------------
          // 2. مراجع الجهاز والجلسة
          // ---------------------------------------------------------

          final childRef = _firestore
              .collection('parents')
              .doc(parentId)
              .collection('children')
              .doc(childId);

          final deviceRef = childRef.collection('linkedDevices').doc(deviceUid);

          final sessionRef =
              childRef.collection('deviceSession').doc('current');

          // ---------------------------------------------------------
          // 3. قراءة الجلسة الحالية قبل أي عملية كتابة
          // ---------------------------------------------------------

          final sessionSnapshot = await transaction.get(sessionRef);

          DocumentReference<Map<String, dynamic>>? oldDeviceRef;
          DocumentSnapshot<Map<String, dynamic>>? oldDeviceSnapshot;

          if (sessionSnapshot.exists) {
            final sessionData = sessionSnapshot.data();
            final oldDeviceId = sessionData?['deviceId'];

            if (oldDeviceId is String &&
                oldDeviceId.isNotEmpty &&
                oldDeviceId != deviceUid) {
              oldDeviceRef =
                  childRef.collection('linkedDevices').doc(oldDeviceId);

              oldDeviceSnapshot = await transaction.get(oldDeviceRef);
            }
          }

          // ---------------------------------------------------------
          // 4. بعد انتهاء جميع القراءات نبدأ الكتابة
          // ---------------------------------------------------------

          transaction.update(pairingRef, {
            'used': true,
            'claimedBy': deviceUid,
            'claimedAt': FieldValue.serverTimestamp(),
          });

          // إلغاء الجهاز السابق إن وُجد وكان مختلفًا عن الجهاز الجديد.
          if (oldDeviceRef != null &&
              oldDeviceSnapshot != null &&
              oldDeviceSnapshot.exists &&
              oldDeviceSnapshot.data()?['active'] == true) {
            transaction.update(oldDeviceRef, {
              'active': false,
            });
          }

          // تسجيل الجهاز الجديد.
          transaction.set(deviceRef, {
            'active': true,
            'pairingCode': normalizedCode,
            'linkedAt': FieldValue.serverTimestamp(),
            'lastSeenAt': FieldValue.serverTimestamp(),
          });

          // جعل الجهاز الجديد هو الجلسة الوحيدة الحالية للطفل.
          transaction.set(sessionRef, {
            'deviceId': deviceUid,
            'active': true,
            'linkedAt': FieldValue.serverTimestamp(),
          });

          return LinkedChildModel(
            parentId: parentId,
            childId: childId,
            childName: childName,
          );
        },
      );
    } on FirebaseException catch (error) {
      if (error.code == 'permission-denied') {
        throw StateError(
          'رمز الربط غير صالح أو انتهت صلاحيته.',
        );
      }

      if (error.code == 'unavailable') {
        throw StateError(
          'تعذر الاتصال بالخادم. تحقق من الإنترنت وحاول مجددًا.',
        );
      }

      throw StateError(
        'تعذر إتمام الربط. حاول مجددًا.',
      );
    }
  }
}
