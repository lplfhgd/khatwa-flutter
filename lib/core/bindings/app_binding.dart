import 'package:get/get.dart';

import '../../features/children/controllers/selected_child_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SelectedChildController>(
      SelectedChildController(),
      permanent: true,
    );
  }
}
