import 'package:get/get.dart';

import 'animal_sounds_controller.dart';

class AnimalSoundsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AnimalSoundsController>(() => AnimalSoundsController());
  }
}
