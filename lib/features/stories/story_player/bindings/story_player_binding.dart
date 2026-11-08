import 'package:get/get.dart';

import '../controllers/story_player_controller.dart';

class StoryPlayerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StoryPlayerController>(() => StoryPlayerController());
  }
}
