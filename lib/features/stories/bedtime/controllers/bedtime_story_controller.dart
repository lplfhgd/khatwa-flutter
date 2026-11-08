import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class BedtimeStoryController extends GetxController {
  YoutubePlayerController? youtubeController;
  final isInitialized = false.obs;

  // ضع رابط يوتيوب الخاص بقصة الفأر الطماع هنا
  final String youtubeUrl = 'https://youtu.be/wKi7l_Gbx5w';

  @override
  void onInit() {
    super.onInit();
    initPlayer();
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
