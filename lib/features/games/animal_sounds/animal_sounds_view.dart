import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'animal_sounds_controller.dart';

class AnimalSoundsView extends GetView<AnimalSoundsController> {
  const AnimalSoundsView({super.key});

  static const Color textColor = Color(0xFF203B40);
  static const Color instructionBg = Color(0xFFE8F6FF);
  static const Color soundBtnColor = Color(0xFF119C99);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 16),
                      _buildInstructionBox(),
                      const SizedBox(height: 22),
                      _buildAnimalsGrid(),
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
        const Text(
          'أصوات الحيوانات',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      decoration: BoxDecoration(
        color: instructionBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        'اضغط على الحيوان للاستماع إلى صوته',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildAnimalsGrid() {
    return GridView.builder(
      itemCount: controller.animals.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.88,
      ),
      itemBuilder: (context, index) {
        final animal = controller.animals[index];
        return _buildAnimalCard(animal);
      },
    );
  }

  Widget _buildAnimalCard(AnimalItem animal) {
    return Material(
      color: animal.bgColor,
      elevation: 0,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => controller.playSound(animal.id, animal.soundPath),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Expanded(
                child: Image.asset(
                  animal.imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.pets_rounded,
                      size: 70,
                      color: Colors.grey.shade600,
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text(
                animal.name,
                style: const TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: soundBtnColor,
                ),
                child: const Icon(
                  Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
