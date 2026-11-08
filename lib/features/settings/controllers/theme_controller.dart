import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/theme_service.dart';

class ThemeController extends GetxController {
  ThemeController(this._service);

  final ThemeService _service;

  final themeMode = ThemeMode.system.obs;
  final isReady = false.obs;

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  Future<void> initialize() async {
    final savedMode = await _service.loadThemeMode();

    themeMode.value = savedMode;
    Get.changeThemeMode(savedMode);

    isReady.value = true;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (themeMode.value == mode) return;

    themeMode.value = mode;
    Get.changeThemeMode(mode);

    await _service.saveThemeMode(mode);
  }

  String get currentLabel {
    return switch (themeMode.value) {
      ThemeMode.system => 'حسب النظام',
      ThemeMode.light => 'فاتح',
      ThemeMode.dark => 'داكن',
    };
  }
}
