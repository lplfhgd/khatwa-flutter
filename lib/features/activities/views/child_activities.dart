import 'package:flutter/material.dart';

import '../../../core/theme/k_colors.dart';
import '../../../shared/widgets/k_button.dart';
import '../../../shared/widgets/k_card.dart';
import '../../child/views/child_home.dart';

class ChildActivities extends StatelessWidget {
  const ChildActivities({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'ألعابي',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        ChildEntry(
          title: 'الألوان والأشكال',
          icon: Icons.palette_outlined,
          color: const Color(0xFFFFF1D0),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ColorGameScreen(),
            ),
          ),
        ),
        ChildEntry(
          title: 'قصصي',
          icon: Icons.auto_stories_outlined,
          color: KColors.soft,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const StoryScreen(),
            ),
          ),
        ),
        const KCard(
          child: Text(
            'الألعاب الأخرى ستضاف تدريجيًا بعد تجربة هذا المسار الأساسي.',
          ),
        ),
      ],
    );
  }
}

class ColorGameScreen extends StatefulWidget {
  const ColorGameScreen({super.key});

  @override
  State<ColorGameScreen> createState() => _ColorGameScreenState();
}

class _ColorGameScreenState extends State<ColorGameScreen> {
  int? selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الألوان والأشكال'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'اختر الدائرة الحمراء',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 25),
            Wrap(
              spacing: 22,
              runSpacing: 22,
              children: [
                Colors.blue,
                Colors.red,
                Colors.green,
                Colors.orange,
              ].asMap().entries.map((entry) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      selected = entry.key;
                    });
                  },
                  child: Container(
                    width: 132,
                    height: 132,
                    decoration: BoxDecoration(
                      color: entry.value,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected == entry.key
                            ? KColors.text
                            : Colors.transparent,
                        width: 5,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const Spacer(),
            if (selected != null)
              Text(
                selected == 1
                    ? 'أحسنت! اخترت الدائرة الحمراء.'
                    : 'حاول مرة أخرى.',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 15),
            KButton(
              label: 'إنهاء النشاط',
              large: true,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class StoryScreen extends StatelessWidget {
  const StoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قصصي'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 20),
          const Icon(
            Icons.auto_stories,
            color: KColors.primary,
            size: 130,
          ),
          const SizedBox(height: 20),
          const Text(
            'قصة الذهاب إلى المدرسة',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const KCard(
            child: Text(
              'أرتدي حقيبتي، وأذهب إلى المدرسة. ألتقي بأصدقائي، وأتعلم أشياء جديدة.',
              style: TextStyle(
                fontSize: 22,
                height: 1.8,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 25),
          KButton(
            label: 'العودة إلى ألعابي',
            large: true,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
