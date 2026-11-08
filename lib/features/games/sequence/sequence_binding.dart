import 'package:get/get.dart';

import 'sequence_controller.dart';

class SequenceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SequenceController>(() => SequenceController());
  }
}
