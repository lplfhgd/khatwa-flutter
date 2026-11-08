import 'dart:async';

import 'package:get/get.dart';

import '../../children/controllers/children_controller.dart';
import '../../children/controllers/selected_child_controller.dart';
import '../../children/models/child_model.dart';
import '../models/child_report.dart';
import '../services/reports_service.dart';

class ReportsController extends GetxController {
  ReportsController(
    this._service,
    this._childrenController,
    this._selectedChildController,
  );

  final ReportsService _service;
  final ChildrenController _childrenController;
  final SelectedChildController _selectedChildController;

  final report = Rxn<ChildReport>();
  final selectedId = RxnString();

  final isLoading = false.obs;
  final errorMessage = RxnString();

  StreamSubscription<ChildReport>? _reportSubscription;
  Worker? _childrenWorker;

  List<ChildModel> get children => _childrenController.children;

  bool get hasChildren => children.isNotEmpty;

  @override
  void onInit() {
    super.onInit();

    _childrenWorker = ever<List<ChildModel>>(
      _childrenController.children,
      (_) => _handleChildrenChanged(),
    );

    _handleChildrenChanged();
  }

  void _handleChildrenChanged() {
    if (children.isEmpty) {
      selectedId.value = null;
      report.value = null;
      isLoading.value = false;
      return;
    }

    final currentId = selectedId.value;

    if (currentId != null && children.any((child) => child.id == currentId)) {
      return;
    }

    final globallySelectedId = _selectedChildController.selectedChildId.value;

    final initialChild = children.firstWhereOrNull(
          (child) => child.id == globallySelectedId,
        ) ??
        children.first;

    selectChild(initialChild.id);
  }

  Future<void> selectChild(String childId) async {
    final child = children.firstWhereOrNull(
      (item) => item.id == childId,
    );

    if (child == null) return;

    selectedId.value = child.id;

    _selectedChildController.selectChild(
      child.id,
      child.name,
    );

    await loadReport(child.id);
  }

  Future<void> loadReport([String? childId]) async {
    final id = childId ?? selectedId.value;

    await _reportSubscription?.cancel();
    _reportSubscription = null;

    report.value = null;
    errorMessage.value = null;

    if (id == null || id.trim().isEmpty) {
      isLoading.value = false;
      return;
    }

    isLoading.value = true;

    _reportSubscription = _service.watchReport(id).listen(
      (value) {
        report.value = value;
        errorMessage.value = null;
        isLoading.value = false;
      },
      onError: (Object error) {
        isLoading.value = false;
        errorMessage.value =
            'تعذر تحميل تقرير الطفل. تحقق من الاتصال والصلاحيات.';
      },
    );
  }

  Future<void> retry() async {
    await loadReport();
  }

  @override
  void onClose() {
    _reportSubscription?.cancel();
    _childrenWorker?.dispose();
    super.onClose();
  }
}
