import 'package:flutter/material.dart';

import '../../../core/theme/k_colors.dart';
import '../../../shared/widgets/k_button.dart';
import '../../child/views/child_shell.dart';

class ChildPairScreen extends StatefulWidget {
  const ChildPairScreen({super.key});

  @override
  State<ChildPairScreen> createState() => _ChildPairScreenState();
}

class _ChildPairScreenState extends State<ChildPairScreen> {
  final code = TextEditingController();
  String? error;

  @override
  void dispose() {
    code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('ربط جهاز الطفل'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.phonelink_ring_outlined,
                  size: 100,
                  color: KColors.primary,
                ),
                const SizedBox(height: 18),
                const Text(
                  'أدخل رمز الربط',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('اطلب الرمز من ولي الأمر'),
                const SizedBox(height: 18),
                TextField(
                  controller: code,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 27,
                    letterSpacing: 9,
                  ),
                  decoration: const InputDecoration(
                    hintText: '••••••',
                    counterText: '',
                  ),
                ),
                if (error != null)
                  Text(
                    error!,
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  ),
                const SizedBox(height: 18),
                KButton(
                  label: 'متابعة',
                  large: true,
                  onPressed: () {
                    if (code.text == '482916') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChildShell(),
                        ),
                      );
                    } else {
                      setState(() {
                        error = 'للتجربة استخدم الرمز 482916';
                      });
                    }
                  },
                ),
                const SizedBox(height: 10),
                const Text(
                  'محاكاة محلية؛ في الإصدار الحقيقي يلزم تأكيد ولي الأمر.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
}
