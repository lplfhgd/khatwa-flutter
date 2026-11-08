import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';

import '../../children/controllers/selected_child_controller.dart';
import '../models/routine_model.dart';
import '../services/routine_service.dart';

class RoutineController extends GetxController {
  RoutineController(
    this._service,
    this._selectedChild,
  );

  final RoutineService _service;
  final SelectedChildController _selectedChild;

  final routine = <RoutineModel>[].obs;

  final isLoading = false.obs;
  final isSaving = false.obs;
  final isDirty = false.obs;
  final errorMessage = RxnString();

  StreamSubscription<List<RoutineModel>>? _routineSubscription;
  Worker? _selectedChildWorker;

  List<RoutineModel> _savedRoutine = const [];

  static const List<RoutineModel> defaultRoutine = [
    RoutineModel(
      id: 'wake_up',
      label: 'الاستيقاظ',
      time: '07:00',
      iconName: 'sun',
    ),
    RoutineModel(
      id: 'wash_face',
      label: 'غسل الوجه',
      time: '07:20',
      iconName: 'water',
    ),
    RoutineModel(
      id: 'brush_teeth',
      label: 'تنظيف الأسنان',
      time: '07:30',
      iconName: 'clean',
    ),
    RoutineModel(
      id: 'breakfast',
      label: 'الإفطار',
      time: '07:50',
      iconName: 'food',
    ),
    RoutineModel(
      id: 'get_ready',
      label: 'الاستعداد للخروج',
      time: '08:10',
      iconName: 'walk',
    ),
  ];

  String? get selectedChildId => _selectedChild.selectedChildId.value;

  String get selectedChildName => _selectedChild.childName.value;

  int get completedCount => routine.where((item) => item.isCompleted).length;

  double get progress {
    if (routine.isEmpty) return 0;
    return completedCount / routine.length;
  }

  @override
  void onInit() {
    super.onInit();

    _selectedChildWorker = ever<String?>(
      _selectedChild.selectedChildId,
      (_) => loadRoutine(),
    );

    loadRoutine();
  }

  Future<void> loadRoutine() async {
    await _routineSubscription?.cancel();
    _routineSubscription = null;

    final childId = selectedChildId;

    errorMessage.value = null;
    isDirty.value = false;

    if (childId == null || childId.trim().isEmpty) {
      routine.clear();
      _savedRoutine = const [];
      isLoading.value = false;
      return;
    }

    isLoading.value = true;

    _routineSubscription = _service.watchRoutine(childId).listen(
      (items) {
        if (items.isEmpty) {
          final defaults = List<RoutineModel>.of(defaultRoutine);

          routine.assignAll(defaults);
          _savedRoutine = List<RoutineModel>.of(defaults);
        } else {
          final sorted = List<RoutineModel>.of(items)
            ..sort((a, b) => a.time.compareTo(b.time));

          routine.assignAll(sorted);
          _savedRoutine = List<RoutineModel>.of(sorted);
        }

        isDirty.value = false;
        isLoading.value = false;
        errorMessage.value = null;
      },
      onError: (Object error) {
        errorMessage.value = _messageFor(error);
        isLoading.value = false;
      },
    );
  }

  void addRoutine(String label) {
    final cleaned = label.trim();

    if (cleaned.isEmpty) return;

    upsertItem(
      RoutineModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        label: cleaned,
        time: '07:00',
        iconName: 'task',
      ),
    );
  }

  void upsertItem(RoutineModel item) {
    final index = routine.indexWhere((entry) => entry.id == item.id);

    if (index == -1) {
      routine.add(item);
    } else {
      routine[index] = item;
    }

    _sortRoutine();
    _markDirty();
  }

  void removeItem(String id) {
    routine.removeWhere((item) => item.id == id);
    _markDirty();
  }

  void toggleEnabled(String id, bool enabled) {
    final index = routine.indexWhere((item) => item.id == id);

    if (index == -1) return;

    routine[index] = routine[index].copyWith(enabled: enabled);
    _markDirty();
  }

  void toggleRoutine(int index) {
    if (index < 0 || index >= routine.length) return;

    final item = routine[index];

    routine[index] = item.copyWith(
      isCompleted: !item.isCompleted,
    );

    _markDirty();
  }

  Future<void> save() async {
    final childId = selectedChildId;

    if (childId == null || childId.trim().isEmpty) {
      Get.snackbar(
        'خطوة',
        'اختر طفلًا أولًا.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (isSaving.value) return;

    isSaving.value = true;

    try {
      final snapshot = List<RoutineModel>.of(routine);

      await _service.saveRoutine(childId, snapshot);

      _savedRoutine = List<RoutineModel>.of(snapshot);
      isDirty.value = false;

      Get.snackbar(
        'خطوة',
        'تم حفظ الروتين بنجاح.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'خطوة',
        _messageFor(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  void _sortRoutine() {
    final sorted = List<RoutineModel>.of(routine)
      ..sort((a, b) => a.time.compareTo(b.time));

    routine.assignAll(sorted);
  }

  void _markDirty() {
    final current = jsonEncode(
      routine.map((item) => item.toMap()).toList(),
    );

    final saved = jsonEncode(
      _savedRoutine.map((item) => item.toMap()).toList(),
    );

    isDirty.value = current != saved;
  }

  String _messageFor(Object error) {
    final message = error.toString();

    if (message.contains('permission-denied')) {
      return 'ليس لديك صلاحية للوصول إلى هذا الروتين.';
    }

    if (message.contains('network')) {
      return 'تحقق من اتصال الإنترنت وحاول مرة أخرى.';
    }

    return 'حدث خطأ أثناء التعامل مع الروتين.';
  }

  @override
  void onClose() {
    _routineSubscription?.cancel();
    _selectedChildWorker?.dispose();
    super.onClose();
  }
}
