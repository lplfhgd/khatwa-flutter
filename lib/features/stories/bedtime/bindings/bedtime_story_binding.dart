import 'package:get/get.dart';

import '../controllers/bedtime_story_controller.dart';

class BedtimeStoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BedtimeStoryController>(() => BedtimeStoryController());
  }
}
