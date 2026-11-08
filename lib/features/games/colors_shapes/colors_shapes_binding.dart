import 'package:get/get.dart';

import 'colors_shapes_controller.dart';

class ColorsShapesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ColorsShapesController>(() => ColorsShapesController());
  }
}
