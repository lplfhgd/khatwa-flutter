import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../pairing/services/linked_child_storage.dart';

class ChildHome extends StatefulWidget {
  const ChildHome({
    super.key,
    required this.openTab,
  });

  final ValueChanged<int> openTab;

  @override
  State<ChildHome> createState() => _ChildHomeState();
}

class _ChildHomeState extends State<ChildHome> {
  static const Color primary = Color(0xFF119C99);
  static const Color primaryDark = Color(0xFF087F80);
  static const Color background = Color(0xFFF5FBF8);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF203B40);
  static const Color textSecondary = Color(0xFF607983);
  static const Color mint = Color(0xFFE5F6F1);
  static const Color accent = Color(0xFFFFC84D);

  final LinkedChildStorage _linkedChildStorage = Get.find<LinkedChildStorage>();

  String? _childName;

  @override
  void initState() {
    super.initState();
    _loadLinkedChild();
  }

  Future<void> _loadLinkedChild() async {
    final linkedChild = await _linkedChildStorage.read();

    if (!mounted) return;

    setState(() {
      _childName = linkedChild?.childName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: background,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 22),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _WelcomeHeader(childName: _childName),
                  const SizedBox(height: 24),
                  _CommunicationCard(
                    onTap: () => widget.openTab(1),
                  ),
                  const SizedBox(height: 18),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.88,
                    children: [
                      _FeatureCard(
                        title: 'ألعابي',
                        subtitle: 'ألعب وتعلّم',
                        imagePath: 'assets/images/games_icon.png',
                        onTap: () => widget.openTab(3),
                      ),
                      _FeatureCard(
                        title: 'روتيني',
                        subtitle: 'أنجز مهامي اليومية',
                        imagePath: 'assets/images/routine_icon.png',
                        onTap: () => widget.openTab(2),
                      ),
                      _FeatureCard(
                        title: 'قصصي',
                        subtitle: 'أقرأ وأستمع للقصص',
                        imagePath: 'assets/images/stories_icon.png',
                        onTap: () {
                          Get.snackbar(
                            'قصصي',
                            'سنربط واجهة القصص في الخطوة التالية.',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    height: 68,
                    child: ElevatedButton(
                      onPressed: () => widget.openTab(1),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: const StadiumBorder(),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 34,
                          ),
                          Spacer(),
                          Text(
                            'ابدأ',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Spacer(),
                          SizedBox(width: 34),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({
    required this.childName,
  });

  final String? childName;

  @override
  Widget build(BuildContext context) {
    final cleanedName = childName?.trim();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 66,
              height: 66,
              decoration: const BoxDecoration(
                color: Color(0xFFDDF5EF),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: _ChildHomeState.primaryDark,
                  size: 34,
                ),
              ),
            ),
            Image.asset(
              'assets/images/parent/logo.png',
              width: 125,
              height: 125,
              fit: BoxFit.contain,
            ),
            Image.asset(
              'assets/images/avatar.png',
              width: 66,
              height: 66,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                return const CircleAvatar(
                  radius: 33,
                  backgroundColor: _ChildHomeState.mint,
                  child: Icon(
                    Icons.child_care_rounded,
                    size: 38,
                    color: _ChildHomeState.primary,
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 4),
        Stack(
          alignment: Alignment.center,
          children: [
            Text(
              cleanedName == null || cleanedName.isEmpty
                  ? 'أهلًا يا بطل'
                  : 'أهلًا يا $cleanedName',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: _ChildHomeState.textPrimary,
                height: 1.4,
              ),
            ),
            const Positioned(
              left: 8,
              top: 0,
              child: Icon(
                Icons.wb_sunny_rounded,
                color: _ChildHomeState.accent,
                size: 25,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'ماذا تريد أن تفعل اليوم؟',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            color: _ChildHomeState.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _CommunicationCard extends StatelessWidget {
  const _CommunicationCard({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFECF9F5),
      borderRadius: BorderRadius.circular(30),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 220,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'أتواصل',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: _ChildHomeState.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'تحدث مع من تحب\nعبر الصور والصوت',
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: _ChildHomeState.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: _ChildHomeState.primary,
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: Image.asset(
                    'assets/images/hero_child1.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) {
                      return const Icon(
                        Icons.chat_bubble_rounded,
                        size: 70,
                        color: _ChildHomeState.primary,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String imagePath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _ChildHomeState.card,
      borderRadius: BorderRadius.circular(28),
      elevation: 2,
      shadowColor: _ChildHomeState.primary.withValues(alpha: 0.10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 5,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) {
                    return const Icon(
                      Icons.image_not_supported_outlined,
                      color: _ChildHomeState.primary,
                      size: 42,
                    );
                  },
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _ChildHomeState.textPrimary,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(
                  color: _ChildHomeState.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerLeft,
                child: CircleAvatar(
                  radius: 19,
                  backgroundColor: _ChildHomeState.mint,
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: _ChildHomeState.primaryDark,
                    size: 23,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
