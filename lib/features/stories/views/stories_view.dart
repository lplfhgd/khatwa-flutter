import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/stories_controller.dart';
import '../../communication/models/story_item.dart';

class StoriesView extends GetView<StoriesController> {
  const StoriesView({super.key});

  static const Color background = Color(0xFFF7FBFA);
  static const Color textColor = Color(0xFF1F1F1F);
  static const Color subtitleColor = Color(0xFF6B7B7F);
  static const Color primaryTeal = Color(0xFF148F8C);
  static const Color heroCloudBg = Color(0xFFE6F4F3);
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
                      const SizedBox(height: 18),
                      _buildTitleSection(),
                      const SizedBox(height: 16),
                      _buildHeroIllustration(),
                      const SizedBox(height: 24),
                      _buildSectionHeader(),
                      const SizedBox(height: 14),
                      _buildStoriesList(),
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
            color: const Color(0xFFDDF5EF),
            shape: const CircleBorder(),
            child: IconButton(
              onPressed: controller.goBack,
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Color(0xFF087F80),
                size: 24,
              ),
            ),
          ),
        ),
        Image.asset(
          'assets/images/logo.png',
          height: 78,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Text(
            'خطوة',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: primaryTeal,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: ClipOval(
            child: Image.asset(
              'assets/images/avatar.png',
              width: 54,
              height: 54,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const CircleAvatar(
                radius: 27,
                backgroundColor: Color(0xFFE8F7F6),
                child: Icon(Icons.face_rounded, color: primaryTeal, size: 30),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Text(
              '!!',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: Color(0xFFFFD93B),
                height: 1.1,
              ),
            ),
            SizedBox(width: 10),
            Text(
              'قصصي',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: textColor,
                height: 1.1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'شاهد قصصًا ممتعة وتعلّم منها',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: subtitleColor,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroIllustration() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: double.infinity,
          height: 190,
          decoration: BoxDecoration(
            color: heroCloudBg,
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        Positioned(
          left: -10,
          top: 40,
          child: Image.asset(
            'assets/images/leaf1.png',
            width: 70,
            height: 70,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
        Positioned(
          right: -10,
          top: 30,
          child: Image.asset(
            'assets/images/leaf2.png',
            width: 80,
            height: 80,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
        Image.asset(
          'assets/images/stories_illustration.png',
          height: 170,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.play_circle_filled_rounded,
                size: 90,
                color: primaryTeal,
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'قصص اجتماعية ممتعة',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text(
          'قائمة القصص',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
        ),
        Text(
          'اضغط للمشاهدة',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: subtitleColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStoriesList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: CircularProgressIndicator(color: primaryTeal),
          ),
        );
      }

      if (controller.stories.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE6F2F0)),
          ),
          child: const Column(
            children: [
              Icon(Icons.video_library_outlined, size: 48, color: primaryTeal),
              SizedBox(height: 10),
              Text(
                'لا توجد قصص حالياً',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'سيضيف ولي الأمر قصصًا جديدة قريبًا',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        itemCount: controller.stories.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final story = controller.stories[index];
          return _buildStoryVideoCard(story);
        },
      );
    });
  }

  Widget _buildStoryVideoCard(StoryItem story) {
    final thumbnailUrl = controller.thumbnailUrl(story);

    return Material(
      color: cardBg,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => controller.openStory(story),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Thumbnail / video preview box
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 128,
                      height: 86,
                      color: const Color(0xFFEAF6F4),
                      child: Image.network(
                        thumbnailUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(
                            Icons.smart_display_rounded,
                            size: 42,
                            color: primaryTeal,
                          ),
                        ),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;

                          return const Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: primaryTeal,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // Story info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F7F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.play_circle_outline_rounded,
                              size: 16, color: primaryTeal),
                          SizedBox(width: 6),
                          Text(
                            'مشاهدة القصة',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: primaryTeal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
