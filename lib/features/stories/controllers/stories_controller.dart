import 'dart:async';

import 'package:get/get.dart';

import '../../communication/models/story_item.dart';
import '../../communication/services/communication_service.dart';
import '../../pairing/services/linked_child_storage.dart';
import '../story_player/bindings/story_player_binding.dart';
import '../story_player/views/story_player_view.dart';

class StoriesController extends GetxController {
  StoriesController({
    CommunicationService? communicationService,
    LinkedChildStorage? linkedChildStorage,
  })  : _communicationService =
            communicationService ?? Get.find<CommunicationService>(),
        _linkedChildStorage =
            linkedChildStorage ?? Get.find<LinkedChildStorage>();

  final CommunicationService _communicationService;
  final LinkedChildStorage _linkedChildStorage;

  final stories = <StoryItem>[].obs;
  final isLoading = true.obs;
  final errorMessage = ''.obs;

  StreamSubscription<List<StoryItem>>? _storiesSubscription;

  @override
  void onInit() {
    super.onInit();
    _startWatchingStories();
  }

  Future<void> _startWatchingStories() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final linkedChild = await _linkedChildStorage.read();

      if (linkedChild == null) {
        errorMessage.value = 'تعذر العثور على بيانات الطفل المرتبط.';
        isLoading.value = false;
        return;
      }

      await _storiesSubscription?.cancel();

      _storiesSubscription = _communicationService
          .watchChildStories(
        parentId: linkedChild.parentId,
        childId: linkedChild.childId,
      )
          .listen(
        (items) {
          stories.assignAll(items);
          errorMessage.value = '';
          isLoading.value = false;
        },
        onError: (Object error) {
          errorMessage.value = 'تعذر تحميل القصص حاليًا.';
          isLoading.value = false;
        },
      );
    } catch (_) {
      errorMessage.value = 'تعذر تحميل القصص حاليًا.';
      isLoading.value = false;
    }
  }

  String thumbnailUrl(StoryItem story) {
    return 'https://img.youtube.com/vi/${story.videoId}/hqdefault.jpg';
  }

  void openStory(StoryItem story) {
    StoryPlayerBinding().dependencies();

    Get.to(
      () => const StoryPlayerView(),
      arguments: story,
    );
  }

  void goBack() {
    Get.back();
  }

  @override
  void onClose() {
    _storiesSubscription?.cancel();
    super.onClose();
  }
}
