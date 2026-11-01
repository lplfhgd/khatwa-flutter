import 'package:flutter/material.dart';

import '../../../core/theme/k_colors.dart';
import '../../../shared/widgets/k_button.dart';

class ParentPairScreen extends StatelessWidget {
  const ParentPairScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ربط جهاز الطفل'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.phonelink_setup,
              size: 100,
              color: KColors.primary,
            ),
            const SizedBox(height: 20),
            const Text(
              'رمز الربط التجريبي',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '482916',
              style: TextStyle(
                fontSize: 48,
                letterSpacing: 9,
                fontWeight: FontWeight.bold,
                color: KColors.primary,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'الرمز للعرض فقط، وليس رمز أمان صالحًا أو نظام ربط حقيقيًا.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            KButton(
              label: 'فهمت',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
