import 'package:get/get.dart';

class ParentNavigationController extends GetxController {
  final requestedTab = RxnInt();

  void openHome() {
    requestedTab.value = 0;
  }

  void openContent() {
    requestedTab.value = 1;
  }

  void openProgress() {
    requestedTab.value = 2;
  }

  void openSettings() {
    requestedTab.value = 3;
  }

  void clearRequest() {
    requestedTab.value = null;
  }
}
