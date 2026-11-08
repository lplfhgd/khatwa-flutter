import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../animal_sounds/animal_sounds_binding.dart';
import '../animal_sounds/animal_sounds_view.dart';
import '../colors_shapes/colors_shapes_binding.dart';
import '../colors_shapes/colors_shapes_view.dart';
import '../matching/matching_binding.dart';
import '../matching/matching_view.dart';
import '../sequence/sequence_binding.dart';
import '../sequence/sequence_view.dart';

class GamesController extends GetxController {
  void onGameTap(String gameId) {
    switch (gameId) {
      case 'matching':
        MatchingBinding().dependencies();
        Get.to(() => const MatchingView());
        break;

      case 'sequence':
        SequenceBinding().dependencies();
        Get.to(() => const SequenceView());
        break;

      case 'shapes':
        ColorsShapesBinding().dependencies();
        Get.to(() => const ColorsShapesView());
        break;

      case 'animals':
        AnimalSoundsBinding().dependencies();
        Get.to(() => const AnimalSoundsView());
        break;
    }
  }

  void goBack() {
    Get.back();
  }

  void startGames() {
    Get.snackbar(
      'هيا نلعب!',
      'اختر إحدى الألعاب للبدء.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }
}
