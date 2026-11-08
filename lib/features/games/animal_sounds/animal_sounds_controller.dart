import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnimalItem {
  final String id;
  final String name;
  final String imagePath;
  final String soundPath;
  final Color bgColor;

  AnimalItem({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.soundPath,
    required this.bgColor,
  });
}

class AnimalSoundsController extends GetxController {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final playingId = ''.obs;

  final animals = <AnimalItem>[
    AnimalItem(
      id: 'lion',
      name: 'أسد',
      imagePath: 'assets/images/lion.png',
      soundPath: 'sounds/lion.mp3',
      bgColor: const Color(0xFFFFF7DC),
    ),
    AnimalItem(
      id: 'elephant',
      name: 'فيل',
      imagePath: 'assets/images/elephant.png',
      soundPath: 'sounds/elephant.mp3',
      bgColor: const Color(0xFFF0F8FF),
    ),
    AnimalItem(
      id: 'bird',
      name: 'عصفور',
      imagePath: 'assets/images/bird.png',
      soundPath: 'sounds/bird.wav',
      bgColor: const Color(0xFFF3FFF3),
    ),
    AnimalItem(
      id: 'cat',
      name: 'قطة',
      imagePath: 'assets/images/cat.png',
      soundPath: 'sounds/cat.wav',
      bgColor: const Color(0xFFFFF0F6),
    ),
    AnimalItem(
      id: 'horse',
      name: 'حصان',
      imagePath: 'assets/images/horse.png',
      soundPath: 'sounds/horse.aac',
      bgColor: const Color(0xFFFFF7E6),
    ),
    AnimalItem(
      id: 'dog',
      name: 'كلب',
      imagePath: 'assets/images/dog.png',
      soundPath: 'sounds/dog.aac',
      bgColor: const Color(0xFFF6F8FF),
    ),
  ];

  Future<void> playSound(String id, String soundPath) async {
    playingId.value = id;
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource(soundPath));
  }

  void stopSound() {
    _audioPlayer.stop();
    playingId.value = '';
  }

  void goBack() {
    stopSound();
    Get.back();
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }
}
