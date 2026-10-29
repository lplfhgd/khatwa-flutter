import 'package:get/get.dart';

import '../../features/auth/controllers/auth_controller.dart';
import '../../features/auth/services/auth_service.dart';
import '../../features/children/controllers/children_controller.dart';
import '../../features/children/controllers/selected_child_controller.dart';
import '../../features/routine/controllers/routine_controller.dart';
import '../../features/aac/controllers/aac_controller.dart';
import '../../features/children/services/children_service.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Firebase Authentication
    Get.put<AuthService>(
      AuthService(),
      permanent: true,
    );

    Get.put<AuthController>(
      AuthController(Get.find<AuthService>()),
      permanent: true,
    );

    // Selected child state
    Get.put<SelectedChildController>(
      SelectedChildController(),
      permanent: true,
    );

    // Children Firestore service
    Get.put<ChildrenService>(
      ChildrenService(),
      permanent: true,
    );

    // Children state management
    Get.put<ChildrenController>(
      ChildrenController(
        Get.find<ChildrenService>(),
        Get.find<SelectedChildController>(),
      ),
      permanent: true,
    );
    // AAC communication cards
    Get.put<AacController>(
      AacController(),
      permanent: true,
    );
    // Daily routine state management
    Get.put<RoutineController>(
      RoutineController(),
      permanent: true,
    );
  }
}
