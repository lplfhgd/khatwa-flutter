import 'package:get/get.dart';

import '../services/notification_preferences_service.dart';

class NotificationPreferencesController extends GetxController {
  NotificationPreferencesController(this._service);

  final NotificationPreferencesService _service;

  final enabled = true.obs;
  final routineEnabled = true.obs;
  final progressEnabled = true.obs;
  final generalEnabled = true.obs;

  final isReady = false.obs;

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  Future<void> initialize() async {
    enabled.value = await _service.getEnabled();
    routineEnabled.value = await _service.getRoutineEnabled();
    progressEnabled.value = await _service.getProgressEnabled();
    generalEnabled.value = await _service.getGeneralEnabled();

    isReady.value = true;
  }

  Future<void> setEnabled(bool value) async {
    enabled.value = value;
    await _service.setEnabled(value);
  }

  Future<void> setRoutineEnabled(bool value) async {
    routineEnabled.value = value;
    await _service.setRoutineEnabled(value);
  }

  Future<void> setProgressEnabled(bool value) async {
    progressEnabled.value = value;
    await _service.setProgressEnabled(value);
  }

  Future<void> setGeneralEnabled(bool value) async {
    generalEnabled.value = value;
    await _service.setGeneralEnabled(value);
  }
}
