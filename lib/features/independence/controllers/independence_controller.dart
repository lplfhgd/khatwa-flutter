import 'dart:async';

import 'package:get/get.dart';

import '../../children/controllers/selected_child_controller.dart';
import '../models/independence_model.dart';
import '../services/independence_service.dart';

class IndependenceController extends GetxController {
  IndependenceController(
    this._service,
    this._selectedChild,
  );

  final IndependenceService _service;
  final SelectedChildController _selectedChild;

  final areas = <IndependenceArea>[].obs;

  final isLoading = false.obs;
  final isSaving = false.obs;
  final isDirty = false.obs;
  final errorMessage = RxnString();

  StreamSubscription<List<IndependenceArea>>? _subscription;
  Worker? _childWorker;

  String? get selectedChildId => _selectedChild.selectedChildId.value;

  String get selectedChildName => _selectedChild.childName.value;

  int get independentAreasCount =>
      areas.where((area) => area.isIndependent).length;

  int get totalAreasCount => areas.length;

  int get independentSkillsCount => areas.fold(
        0,
        (total, area) => total + area.independentSkills,
      );

  int get totalSkillsCount => areas.fold(
        0,
        (total, area) => total + area.skills.length,
      );

  double get overallIndependenceRate {
    if (totalSkillsCount == 0) return 0;

    return independentSkillsCount / totalSkillsCount;
  }

  @override
  void onInit() {
    super.onInit();

    _childWorker = ever<String?>(
      _selectedChild.selectedChildId,
      (_) => loadAreas(),
    );

    loadAreas();
  }

  Future<void> loadAreas() async {
    await _subscription?.cancel();
    _subscription = null;

    areas.clear();
    errorMessage.value = null;

    final childId = selectedChildId;

    if (childId == null || childId.trim().isEmpty) {
      isLoading.value = false;
      return;
    }

    isLoading.value = true;

    _subscription = _service.watchAreas(childId).listen(
      (value) {
        areas.assignAll(value);
        isDirty.value = false;
        isLoading.value = false;
        errorMessage.value = null;
      },
      onError: (Object error) {
        isLoading.value = false;
        errorMessage.value =
            'تعذر تحميل تقييم الاستقلالية. تحقق من الاتصال والصلاحيات.';
      },
    );
  }

  void updateSkillLevel({
    required String areaId,
    required String skillId,
    required IndependenceLevel level,
  }) {
    final areaIndex = areas.indexWhere(
      (area) => area.id == areaId,
    );

    if (areaIndex == -1) return;

    final area = areas[areaIndex];

    final skillIndex = area.skills.indexWhere(
      (skill) => skill.id == skillId,
    );

    if (skillIndex == -1) return;

    final updatedSkills = List<IndependenceSkill>.from(
      area.skills,
    );

    updatedSkills[skillIndex] = updatedSkills[skillIndex].copyWith(
      level: level,
    );

    areas[areaIndex] = area.copyWith(
      skills: updatedSkills,
    );

    areas.refresh();
    isDirty.value = true;
  }

  Future<bool> save() async {
    final childId = selectedChildId;

    if (childId == null || childId.trim().isEmpty) {
      errorMessage.value = 'اختر طفلًا أولًا.';
      return false;
    }

    if (isSaving.value) return false;

    isSaving.value = true;
    errorMessage.value = null;

    try {
      await _service.saveAreas(
        childId,
        areas.toList(),
      );

      isDirty.value = false;
      return true;
    } catch (_) {
      errorMessage.value = 'تعذر حفظ تقييم الاستقلالية. حاول مرة أخرى.';
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> retry() async {
    await loadAreas();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    _childWorker?.dispose();
    super.onClose();
  }
}
