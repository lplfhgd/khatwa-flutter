import 'package:get/get.dart';

import '../../features/auth/controllers/auth_controller.dart';
import '../../features/auth/services/auth_service.dart';
import '../../features/children/controllers/selected_child_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // تسجيل خدمة المصادقة مرة واحدة.
    Get.put<AuthService>(
      AuthService(),
      permanent: true,
    );

    // تسجيل Controller المصادقة وربطه بالخدمة.
    Get.put<AuthController>(
      AuthController(Get.find<AuthService>()),
      permanent: true,
    );

    // إدارة الطفل المحدد في واجهات التطبيق.
    Get.put<SelectedChildController>(
      SelectedChildController(),
      permanent: true,
    );
  }
}
