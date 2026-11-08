import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../controllers/story_player_controller.dart';

class StoryPlayerView extends GetView<StoryPlayerController> {
  const StoryPlayerView({super.key});

  static const Color background = Color(0xFFF7FBFA);
  static const Color textColor = Color(0xFF1F1F1F);
  static const Color primaryTeal = Color(0xFF148F8C);
  static const Color arrowBg = Color(0xFFDDF5EF);
  static const Color arrowIcon = Color(0xFF087F80);
  static const Color cardBg = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 16),
                      _buildPlayer(),
                      const SizedBox(height: 18),
                      _buildHintCard(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Material(
            color: arrowBg,
            shape: const CircleBorder(),
            child: IconButton(
              onPressed: controller.goBack,
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: arrowIcon,
                size: 24,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 56),
          child: Text(
            controller.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayer() {
    return Obx(() {
      if (!controller.isInitialized.value ||
          controller.youtubeController == null) {
        return Container(
          height: 240,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: controller.youtubeUrl.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'رابط الفيديو غير متاح',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : const CircularProgressIndicator(color: primaryTeal),
          ),
        );
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: YoutubePlayer(
          controller: controller.youtubeController!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: primaryTeal,
          progressColors: const ProgressBarColors(
            playedColor: primaryTeal,
            handleColor: primaryTeal,
          ),
        ),
      );
    });
  }

  Widget _buildHintCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F7F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: const [
          Icon(Icons.info_outline_rounded, color: primaryTeal),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'اضغط على الفيديو لمشاهدته. يمكنك إيقافه أو تكبير الشاشة من أدوات المشغل.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF205B5A),
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
