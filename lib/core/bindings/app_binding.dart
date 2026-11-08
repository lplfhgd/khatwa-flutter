import 'package:get/get.dart';

import '../../features/auth/controllers/auth_controller.dart';
import '../../features/auth/services/auth_service.dart';
import '../../features/children/controllers/children_controller.dart';
import '../../features/children/controllers/selected_child_controller.dart';
import '../../features/routine/controllers/routine_controller.dart';
import '../../features/aac/controllers/aac_controller.dart';
import '../../features/children/services/children_service.dart';
import '../../features/pairing/controllers/pairing_controller.dart';
import '../../features/pairing/services/pairing_service.dart';
import '../../features/pairing/services/linked_child_storage.dart';
import '../../features/pairing/services/linked_device_service.dart';
import '../../features/communication/controllers/communication_controller.dart';
import '../../features/communication/services/communication_service.dart';
import '../../features/routine/services/routine_service.dart';
import '../../features/reports/controllers/reports_controller.dart';
import '../../features/reports/services/reports_service.dart';
import '../../features/independence/controllers/independence_controller.dart';
import '../../features/independence/services/independence_service.dart';

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
    // Parent communication content
    Get.put<CommunicationService>(
      CommunicationService(),
      permanent: true,
    );

    Get.put<CommunicationController>(
      CommunicationController(
        Get.find<CommunicationService>(),
        Get.find<SelectedChildController>(),
      ),
      permanent: true,
    );
    // Device pairing service
    Get.put<PairingService>(
      PairingService(),
      permanent: true,
    );

// Device pairing state management
    Get.put<LinkedChildStorage>(
      LinkedChildStorage(),
      permanent: true,
    );
    Get.put<LinkedDeviceService>(
      LinkedDeviceService(),
      permanent: true,
    );
    Get.put<PairingController>(
      PairingController(
        Get.find<PairingService>(),
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
    // Daily routine Firestore service
    Get.put<RoutineService>(
      RoutineService(),
      permanent: true,
    );

// Daily routine state management
    Get.put<RoutineController>(
      RoutineController(
        Get.find<RoutineService>(),
        Get.find<SelectedChildController>(),
      ),
      permanent: true,
    );
    // Independence assessment service
    Get.put<IndependenceService>(
      IndependenceService(),
      permanent: true,
    );

// Independence assessment state management
    Get.put<IndependenceController>(
      IndependenceController(
        Get.find<IndependenceService>(),
        Get.find<SelectedChildController>(),
      ),
      permanent: true,
    );

    // Parent reports service
    Get.put<ReportsService>(
      ReportsService(
        Get.find<CommunicationService>(),
        Get.find<RoutineService>(),
        Get.find<IndependenceService>(),
      ),
      permanent: true,
    );

    // Parent reports state management
    Get.put<ReportsController>(
      ReportsController(
        Get.find<ReportsService>(),
        Get.find<ChildrenController>(),
        Get.find<SelectedChildController>(),
      ),
      permanent: true,
    );
  }
}
