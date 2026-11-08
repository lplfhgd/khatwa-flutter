import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../controllers/stories_controller.dart';

class StoryPlayerController extends GetxController {
  YoutubePlayerController? youtubeController;
  final isInitialized = false.obs;

  late final String title;
  late final String youtubeUrl;

  @override
  void onInit() {
    super.onInit();
    _resolveArgs();
    initPlayer();
  }

  void _resolveArgs() {
    final args = Get.arguments;
    if (args is StoryVideo) {
      title = args.title;
      youtubeUrl = args.youtubeUrl;
    } else if (args is Map) {
      title = (args['title'] ?? 'قصة').toString();
      youtubeUrl = (args['youtubeUrl'] ?? args['url'] ?? '').toString();
    } else {
      title = 'قصة';
      youtubeUrl = '';
    }
  }

  void initPlayer() {
    final videoId = YoutubePlayer.convertUrlToId(youtubeUrl);
    if (videoId != null) {
      youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          loop: false,
          isLive: false,
          forceHD: false,
          enableCaption: true,
        ),
      );
      isInitialized.value = true;
    }
  }

  void goBack() {
    youtubeController?.pause();
    Get.back();
  }

  @override
  void onClose() {
    youtubeController?.dispose();
    super.onClose();
  }
}
