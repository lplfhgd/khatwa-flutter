import 'package:get/get.dart';

class SelectedChildController extends GetxController {
  final childName = ''.obs;
  final selectedChildId = RxnString();

  void selectChild(String id, String name) {
    final cleanedId = id.trim();
    final cleanedName = name.trim();

    if (cleanedId.isEmpty || cleanedName.isEmpty) return;

    selectedChildId.value = cleanedId;
    childName.value = cleanedName;
  }

  void clearSelectedChild() {
    selectedChildId.value = null;
    childName.value = '';
  }

  void renameChild(String name) {
    final cleaned = name.trim();

    if (cleaned.isEmpty || selectedChildId.value == null) return;

    childName.value = cleaned;
  }
}
