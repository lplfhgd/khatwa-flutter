import 'package:shared_preferences/shared_preferences.dart';

class NotificationPreferencesService {
  static const _enabledKey = 'notifications_enabled';
  static const _routineKey = 'notifications_routine';
  static const _progressKey = 'notifications_progress';
  static const _generalKey = 'notifications_general';

  Future<bool> getEnabled() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_enabledKey) ?? true;
  }

  Future<bool> getRoutineEnabled() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_routineKey) ?? true;
  }

  Future<bool> getProgressEnabled() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_progressKey) ?? true;
  }

  Future<bool> getGeneralEnabled() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_generalKey) ?? true;
  }

  Future<void> setEnabled(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_enabledKey, value);
  }

  Future<void> setRoutineEnabled(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_routineKey, value);
  }

  Future<void> setProgressEnabled(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_progressKey, value);
  }

  Future<void> setGeneralEnabled(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_generalKey, value);
  }
}
