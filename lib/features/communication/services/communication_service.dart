import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../models/communication_card.dart';
import '../models/story_item.dart';

class CommunicationService {
  CommunicationService()
      : _db = FirebaseFirestore.instance,
        _auth = FirebaseAuth.instance;

  static const String _cloudName = 'mwy6vpzi';
  static const String _uploadPreset = 'khatwa_unsigned';

  static const String _cardsCollection = 'cards';
  static const String _storiesCollection = 'videos';

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _cards =>
      _db.collection(_cardsCollection);

  CollectionReference<Map<String, dynamic>> get _stories =>
      _db.collection(_storiesCollection);

  String get _uid {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      throw StateError('يجب تسجيل الدخول أولًا.');
    }

    return uid;
  }

  Stream<List<CommunicationCard>> watchCards(String childId) {
    return _cards
        .where('parentId', isEqualTo: _uid)
        .where('childId', isEqualTo: childId)
        .snapshots()
        .map((snapshot) {
      final cards = snapshot.docs.map(CommunicationCard.fromFirestore).toList();

      cards.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return cards;
    });
  }

  Stream<List<StoryItem>> watchStories(String childId) {
    return _stories
        .where('parentId', isEqualTo: _uid)
        .where('childId', isEqualTo: childId)
        .snapshots()
        .map((snapshot) {
      final stories = snapshot.docs.map(StoryItem.fromFirestore).toList();

      stories.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return stories;
    });
  }

  Stream<List<StoryItem>> watchChildStories({
    required String parentId,
    required String childId,
  }) {
    return _stories
        .where('parentId', isEqualTo: parentId)
        .where('childId', isEqualTo: childId)
        .snapshots()
        .map((snapshot) {
      final stories = snapshot.docs.map(StoryItem.fromFirestore).toList();

      stories.sort(
        (a, b) => b.createdAt.compareTo(a.createdAt),
      );

      return stories;
    });
  }

  Future<void> saveCard({
    required String childId,
    CommunicationCard? existing,
    required String label,
    String? imageFilePath,
    String? audioFilePath,
  }) async {
    final cleanedLabel = label.trim();

    if (cleanedLabel.isEmpty) {
      throw ArgumentError('اسم البطاقة مطلوب.');
    }

    var imageUrl = existing?.imageUrl ?? '';
    var imagePublicId = existing?.imagePublicId ?? '';
    var audioUrl = existing?.audioUrl ?? '';
    var audioPublicId = existing?.audioPublicId ?? '';

    if (imageFilePath != null) {
      final upload = await _uploadFile(
        filePath: imageFilePath,
        resourceType: 'image',
      );

      imageUrl = upload.url;
      imagePublicId = upload.publicId;
    }

    if (audioFilePath != null) {
      final upload = await _uploadFile(
        filePath: audioFilePath,
        resourceType: 'video',
      );

      audioUrl = upload.url;
      audioPublicId = upload.publicId;
    }

    if (imageUrl.isEmpty) {
      throw ArgumentError('صورة بطاقة التواصل مطلوبة.');
    }

    if (audioUrl.isEmpty) {
      throw ArgumentError('تسجيل صوتي للبطاقة مطلوب.');
    }

    final document = existing == null ? _cards.doc() : _cards.doc(existing.id);

    await document.set(
      {
        'parentId': _uid,
        'childId': childId,
        'label': cleanedLabel,
        'imageUrl': imageUrl,
        'imagePublicId': imagePublicId,
        'audioUrl': audioUrl,
        'audioPublicId': audioPublicId,
        'updatedAt': FieldValue.serverTimestamp(),
        if (existing == null) 'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> deleteCard(CommunicationCard card) async {
    if (card.parentId != _uid) {
      throw StateError('لا تملك صلاحية حذف هذه البطاقة.');
    }

    await _cards.doc(card.id).delete();
  }

  Future<void> saveStory({
    required String childId,
    required String title,
    required String youtubeUrl,
  }) async {
    final cleanedTitle = title.trim();
    final cleanedUrl = youtubeUrl.trim();
    final videoId = StoryItem.extractYoutubeId(cleanedUrl);

    if (cleanedTitle.isEmpty) {
      throw ArgumentError('عنوان القصة مطلوب.');
    }

    if (videoId == null) {
      throw ArgumentError('رابط YouTube غير صالح.');
    }

    await _stories.doc().set({
      'parentId': _uid,
      'childId': childId,
      'title': cleanedTitle,
      'youtubeUrl': cleanedUrl,
      'videoId': videoId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteStory(StoryItem story) async {
    if (story.parentId != _uid) {
      throw StateError('لا تملك صلاحية حذف هذه القصة.');
    }

    await _stories.doc(story.id).delete();
  }

  Future<_CloudinaryUpload> _uploadFile({
    required String filePath,
    required String resourceType,
  }) async {
    final file = File(filePath);

    if (!await file.exists()) {
      throw ArgumentError('الملف المحدد غير موجود.');
    }

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/'
      '$_cloudName/$resourceType/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['folder'] = 'khatwa/$_uid'
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
        ),
      );

    final response = await request.send().timeout(
          const Duration(seconds: 60),
        );

    final body = await response.stream.bytesToString();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'فشل رفع الملف إلى Cloudinary (${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(body);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('استجابة Cloudinary غير صالحة.');
    }

    final secureUrl = decoded['secure_url'];
    final publicId = decoded['public_id'];

    if (secureUrl is! String || publicId is! String) {
      throw const FormatException(
        'لم تُرجع Cloudinary بيانات الملف المطلوبة.',
      );
    }

    return _CloudinaryUpload(
      url: secureUrl,
      publicId: publicId,
    );
  }
}

class _CloudinaryUpload {
  const _CloudinaryUpload({
    required this.url,
    required this.publicId,
  });

  final String url;
  final String publicId;
}
