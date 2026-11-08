import 'package:get/get.dart';
import 'matching_controller.dart';

class MatchingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MatchingController>(() => MatchingController());
  }
}
