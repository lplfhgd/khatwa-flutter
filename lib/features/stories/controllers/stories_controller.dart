import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// Model for a story video. Designed to map easily to/from Firebase documents.
/// When integrating with Firebase, add fromMap/toMap and fields like createdAt, addedBy, etc.
class StoryVideo {
  final String id;
  final String title;
  final String youtubeUrl;
  final String? description;
  final DateTime? createdAt;

  StoryVideo({
    required this.id,
    required this.title,
    required this.youtubeUrl,
    this.description,
    this.createdAt,
  });

  String? get videoId => YoutubePlayer.convertUrlToId(youtubeUrl);

  String? get thumbnailUrl {
    final id = videoId;
    if (id == null) return null;
    return 'https://img.youtube.com/vi/$id/hqdefault.jpg';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'youtubeUrl': youtubeUrl,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory StoryVideo.fromMap(Map<String, dynamic> map) {
    return StoryVideo(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      youtubeUrl: map['youtubeUrl']?.toString() ?? '',
      description: map['description']?.toString(),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
    );
  }
}

class StoriesController extends GetxController {
  final stories = <StoryVideo>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadStories();
  }

  /// Loads stories. Currently uses local sample data.
  /// TODO(Firebase): Replace with a repository/service that streams from Firestore.
  /// Example: stories.bindStream(storiesRepository.watchStories());
  Future<void> loadStories() async {
    isLoading.value = true;
    try {
      // Sample stories - replace with Firebase data later
      stories.assignAll([
        StoryVideo(
          id: 'bedtime',
          title: 'قصةالفأر الطماع',
          youtubeUrl: 'https://youtu.be/wKi7l_Gbx5w',
          description: ' فأر صغير طمع وأكل كثيراً من القمح حتى علق ولم يستطع الخروج، فتعلم أن الطمع يضيع كل شيء'


        ),
        // أضف روابط يوتيوب جديدة هنا أو اجلبها من Firebase لاحقًا
        // StoryVideo(
        //   id: 'school',
        //   title: 'الذهاب إلى المدرسة',
        //   youtubeUrl: 'https://www.youtube.com/watch?v=XXXX',
        //   description: 'قصة عن الروتين الصباحي والذهاب للمدرسة',
        // ),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  void openStory(StoryVideo story) {
    Get.toNamed('/story_player', arguments: story);
  }

  void goBack() {
    Get.back();
  }
}
