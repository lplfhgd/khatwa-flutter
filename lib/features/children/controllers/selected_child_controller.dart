import 'package:get/get.dart';

class SelectedChildController extends GetxController {
  final childName = 'سامي'.obs;
  final selectedChildId = RxnString();

  void selectChild(String id, String name) {
    selectedChildId.value = id;
    childName.value = name;
  }

  void clearSelectedChild() {
    selectedChildId.value = null;
    childName.value = 'سامي';
  }

  void renameChild(String name) {
    final cleaned = name.trim();

    if (cleaned.isEmpty) return;

    childName.value = cleaned;
  }
}
