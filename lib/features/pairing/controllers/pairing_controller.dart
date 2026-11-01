import 'package:get/get.dart';

import '../../children/controllers/selected_child_controller.dart';
import '../models/pairing_model.dart';
import '../services/pairing_service.dart';

class PairingController extends GetxController {
  PairingController(
    this._pairingService,
    this._selectedChildController,
  );

  final PairingService _pairingService;
  final SelectedChildController _selectedChildController;

  final activePairing = Rxn<PairingModel>();
  final isCreating = false.obs;
  final errorMessage = RxnString();

  Future<bool> createCode() async {
    if (isCreating.value) return false;

    final childId = _selectedChildController.selectedChildId.value;
    final childName = _selectedChildController.childName.value;

    if (childId == null || childId.isEmpty) {
      errorMessage.value = 'اختر ملف الطفل أولًا قبل إنشاء رمز الربط.';
      return false;
    }

    isCreating.value = true;
    errorMessage.value = null;

    try {
      activePairing.value = await _pairingService.createPairingCode(
        childId: childId,
        childName: childName,
      );

      return true;
    } catch (_) {
      errorMessage.value = 'تعذر إنشاء رمز الربط. حاول مجددًا.';
      return false;
    } finally {
      isCreating.value = false;
    }
  }

  void clearPairing() {
    activePairing.value = null;
    errorMessage.value = null;
  }
}
