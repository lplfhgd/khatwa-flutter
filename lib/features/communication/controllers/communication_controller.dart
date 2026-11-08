import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import '../../children/controllers/selected_child_controller.dart';
import '../models/communication_card.dart';
import '../models/story_item.dart';
import '../services/communication_service.dart';

class CommunicationController extends GetxController {
  CommunicationController(
    this._service,
    this._selectedChild,
  );

  final CommunicationService _service;
  final SelectedChildController _selectedChild;
  final AudioPlayer _player = AudioPlayer();

  final cards = <CommunicationCard>[].obs;
  final stories = <StoryItem>[].obs;
  final query = ''.obs;

  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMessage = RxnString();
  final playingCardId = RxnString();

  StreamSubscription<List<CommunicationCard>>? _cardsSubscription;
  StreamSubscription<List<StoryItem>>? _storiesSubscription;
  StreamSubscription<void>? _playerSubscription;
  Worker? _selectedChildWorker;

  String? get childId => _selectedChild.selectedChildId.value;

  String get childName => _selectedChild.childName.value;

  bool get hasSelectedChild => childId != null;

  List<CommunicationCard> get visibleCards {
    final cleanedQuery = query.value.trim().toLowerCase();

    if (cleanedQuery.isEmpty) {
      return cards.toList();
    }

    return cards
        .where(
          (card) => card.label.toLowerCase().contains(cleanedQuery),
        )
        .toList();
  }

  @override
  void onInit() {
    super.onInit();

    _playerSubscription = _player.onPlayerComplete.listen((_) {
      playingCardId.value = null;
    });

    _selectedChildWorker = ever<String?>(
      _selectedChild.selectedChildId,
      (_) => loadSelectedChildContent(),
    );

    loadSelectedChildContent();
  }

  Future<void> loadSelectedChildContent() async {
    await _cardsSubscription?.cancel();
    await _storiesSubscription?.cancel();

    cards.clear();
    stories.clear();
    query.value = '';
    playingCardId.value = null;
    errorMessage.value = null;

    final id = childId;

    if (id == null) {
      isLoading.value = false;
      return;
    }

    isLoading.value = true;

    _cardsSubscription = _service.watchCards(id).listen(
      (items) {
        cards.assignAll(items);
        isLoading.value = false;
        errorMessage.value = null;
      },
      onError: (Object error) {
        isLoading.value = false;
        errorMessage.value = _messageFor(error);
      },
    );

    _storiesSubscription = _service.watchStories(id).listen(
      stories.assignAll,
      onError: (Object error) {
        errorMessage.value ??= _messageFor(error);
      },
    );
  }

  void setQuery(String value) {
    query.value = value;
  }

  Future<void> saveCard({
    CommunicationCard? existing,
    required String label,
    String? imageFilePath,
    String? audioFilePath,
  }) async {
    final id = childId;

    if (id == null) {
      _showMessage('اختر طفلًا أولًا.');
      return;
    }

    isSaving.value = true;

    try {
      await _service.saveCard(
        childId: id,
        existing: existing,
        label: label,
        imageFilePath: imageFilePath,
        audioFilePath: audioFilePath,
      );

      if (Get.isBottomSheetOpen == true) {
        Get.back();
      }

      _showMessage(
        existing == null
            ? 'تمت إضافة بطاقة التواصل.'
            : 'تم تحديث بطاقة التواصل.',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'SAVE CARD ERROR:\n$error\nSTACK TRACE:\n$stackTrace',
      );

      _showMessage(_messageFor(error));
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteCard(CommunicationCard card) async {
    try {
      if (playingCardId.value == card.id) {
        await _player.stop();
        playingCardId.value = null;
      }

      await _service.deleteCard(card);
    } catch (error) {
      _showMessage(_messageFor(error));
    }
  }

  Future<void> playCard(CommunicationCard card) async {
    if (card.audioUrl.isEmpty) return;

    try {
      await _player.stop();
      playingCardId.value = card.id;

      await _player.play(
        UrlSource(card.audioUrl),
      );
    } catch (error) {
      playingCardId.value = null;
      _showMessage(_messageFor(error));
    }
  }

  Future<void> saveStory({
    required String title,
    required String youtubeUrl,
  }) async {
    final id = childId;

    if (id == null) {
      _showMessage('اختر طفلًا أولًا.');
      return;
    }

    isSaving.value = true;

    try {
      await _service.saveStory(
        childId: id,
        title: title,
        youtubeUrl: youtubeUrl,
      );

      if (Get.isBottomSheetOpen == true) {
        Get.back();
      }

      _showMessage('تمت إضافة القصة.');
    } catch (error) {
      _showMessage(_messageFor(error));
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteStory(StoryItem story) async {
    try {
      await _service.deleteStory(story);
    } catch (error) {
      _showMessage(_messageFor(error));
    }
  }

  Future<void> openStory(StoryItem story) async {
    final uri = Uri.tryParse(story.watchUrl);

    if (uri == null) {
      _showMessage('رابط القصة غير صالح.');
      return;
    }

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened) {
      _showMessage('تعذر فتح القصة.');
    }
  }

  String _messageFor(Object error) {
    if (error is ArgumentError) {
      return error.message?.toString() ?? 'البيانات المدخلة غير صالحة.';
    }

    if (error is StateError) {
      return error.message;
    }

    return 'حدث خطأ. حاول مرة أخرى.';
  }

  void _showMessage(String message) {
    Get.snackbar(
      'خطوة',
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    _cardsSubscription?.cancel();
    _storiesSubscription?.cancel();
    _playerSubscription?.cancel();
    _selectedChildWorker?.dispose();
    _player.dispose();
    super.onClose();
  }
}
