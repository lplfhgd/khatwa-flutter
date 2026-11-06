import 'dart:async';

import 'package:get/get.dart';

import '../models/child_model.dart';
import '../services/children_service.dart';
import 'selected_child_controller.dart';

class ChildrenController extends GetxController {
  ChildrenController(
    this._childrenService,
    this._selectedChildController,
  );

  final ChildrenService _childrenService;
  final SelectedChildController _selectedChildController;

  final children = <ChildModel>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMessage = RxnString();

  StreamSubscription<List<ChildModel>>? _subscription;

  void startWatching() {
    _subscription?.cancel();

    children.clear();
    errorMessage.value = null;
    isLoading.value = true;

    try {
      _subscription = _childrenService.watchChildren().listen(
        (items) {
          children.assignAll(items);
          isLoading.value = false;
          errorMessage.value = null;
        },
        onError: (Object error) {
          isLoading.value = false;
          errorMessage.value =
              'تعذر تحميل ملفات الأطفال. تحقق من الاتصال والصلاحيات.';
        },
      );
    } catch (_) {
      isLoading.value = false;
      errorMessage.value = 'يجب تسجيل دخول ولي الأمر أولًا.';
    }
  }

  Future<bool> addChild({
    required String name,
    int? birthYear,
    required ChildGender gender,
    required CommunicationMethod communicationMethod,
    required Set<SensoryPreference> sensoryPreferences,
    required Set<DailyGoal> goals,
    required LessonUnit lessonUnit,
  }) async {
    if (isSaving.value) return false;

    isSaving.value = true;
    errorMessage.value = null;

    try {
      final child = await _childrenService.addChild(
        name: name,
        birthYear: birthYear,
        gender: gender,
        communicationMethod: communicationMethod,
        sensoryPreferences: sensoryPreferences,
        goals: goals,
        lessonUnit: lessonUnit,
      );

      _selectedChildController.selectChild(child.id, child.name);
      return true;
    } catch (_) {
      errorMessage.value = 'تعذر إضافة ملف الطفل. حاول مجددًا.';
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updateChild({
    required String childId,
    required String name,
    required ChildGender gender,
    int? birthYear,
    required CommunicationMethod communicationMethod,
    required Set<SensoryPreference> sensoryPreferences,
    required Set<DailyGoal> goals,
    required LessonUnit lessonUnit,
  }) async {
    if (isSaving.value) return false;

    isSaving.value = true;
    errorMessage.value = null;

    try {
      await _childrenService.updateChild(
        childId: childId,
        name: name,
        birthYear: birthYear,
        gender: gender,
        communicationMethod: communicationMethod,
        sensoryPreferences: sensoryPreferences,
        goals: goals,
        lessonUnit: lessonUnit,
      );

      if (_selectedChildController.selectedChildId.value == childId) {
        _selectedChildController.selectChild(childId, name.trim());
      }

      return true;
    } catch (_) {
      errorMessage.value = 'تعذر تعديل ملف الطفل. حاول مجددًا.';
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  void selectChild(ChildModel child) {
    _selectedChildController.selectChild(child.id, child.name);
  }

  void clearSession() {
    _subscription?.cancel();
    _subscription = null;
    children.clear();
    errorMessage.value = null;
    isLoading.value = false;
    isSaving.value = false;
    _selectedChildController.clearSelectedChild();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
