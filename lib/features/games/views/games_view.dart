import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../controllers/games_controller.dart';
import '../widgets/game_card.dart';

class GamesView extends GetView<GamesController> {
  const GamesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Material(
                              color: const Color(0xFFDDF5EF),
                              shape: const CircleBorder(),
                              child: IconButton(
                                onPressed: controller.goBack,
                                tooltip: 'رجوع',
                                icon: const Icon(
                                  Icons.arrow_back_ios_rounded,
                                  color: AppColors.primaryDark,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                          Image.asset(
                            'assets/images/logo.png',
                            height: 90,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'ألعابي',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'اختر لعبة لتبدأ!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 21,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: constraints.maxWidth > 600 ? 220 : 200,
                        child: Image.asset(
                          'assets/images/hero_child1.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.92,
                        children: [
                          GameCard(
                            title: 'مطابقة الصور',
                            imagePath: 'assets/images/matching_game.png',
                            icon: Icons.extension_rounded,
                            iconColor: const Color(0xFFF5A623),
                            onTap: () => controller.onGameTap('matching'),
                          ),
                          GameCard(
                            title: 'ترتيب الخطوات',
                            imagePath: 'assets/images/sequence_game.png',
                            icon: Icons.eco_rounded,
                            iconColor: AppColors.primary,
                            onTap: () => controller.onGameTap('sequence'),
                          ),
                          GameCard(
                            title: 'الألوان والأشكال',
                            imagePath: 'assets/images/shapes_game.png',
                            icon: Icons.category_rounded,
                            iconColor: const Color(0xFFEF6370),
                            onTap: () => controller.onGameTap('shapes'),
                          ),
                          GameCard(
                            title: 'أصوات الحيوانات',
                            imagePath: 'assets/images/animals_game.png',
                            icon: Icons.pets_rounded,
                            iconColor: const Color(0xFF858B9B),
                            onTap: () => controller.onGameTap('animals'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 68,
                        child: ElevatedButton(
                          onPressed: controller.startGames,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: const StadiumBorder(),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 32,
                              ),
                              Spacer(),
                              Text(
                                'ابدأ اللعب',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Spacer(),
                              SizedBox(width: 32),
                            ],
                          ),
                        ),
                      ),
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
}
