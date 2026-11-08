import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../controllers/bedtime_story_controller.dart';

class BedtimeStoryView extends GetView<BedtimeStoryController> {
  const BedtimeStoryView({super.key});

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
                      _buildYoutubePlayer(),
                      const SizedBox(height: 26),
                      _buildOtherStories(),
                      const SizedBox(height: 14),
                      _buildOtherStoriesList(),
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
        const Text(
          'قصة وقت النوم',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildYoutubePlayer() {
    return Obx(() {
      if (!controller.isInitialized.value ||
          controller.youtubeController == null) {
        return Container(
          height: 280,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: primaryTeal,
            ),
          ),
        );
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(28),
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

  Widget _buildOtherStories() {
    return const Align(
      alignment: Alignment.centerRight,
      child: Text(
        'قصص أخرى',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildOtherStoriesList() {
    final items = [
      _OtherStoryItem(
        title: 'الذهاب إلى المدرسة',
        imagePath: 'assets/images/stories/story_school.png',
      ),
      _OtherStoryItem(
        title: 'زيارة الطبيب',
        imagePath: 'assets/images/stories/story_doctor.png',
      ),
      _OtherStoryItem(
        title: 'مساعدة في المنزل',
        imagePath: 'assets/images/stories/story_home_help.png',
      ),
      _OtherStoryItem(
        title: 'وقت النوم',
        imagePath: 'assets/images/stories/story_bedtime.png',
      ),
    ];

    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            width: 240,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    item.imagePath,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F9F8),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.auto_stories_rounded,
                        color: primaryTeal,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.title,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OtherStoryItem {
  final String title;
  final String imagePath;

  _OtherStoryItem({
    required this.title,
    required this.imagePath,
  });
}
