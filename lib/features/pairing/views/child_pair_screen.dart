import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../services/linked_child_storage.dart';
import '../../../core/theme/k_colors.dart';
import '../../../shared/widgets/k_button.dart';
import '../../child/views/child_shell.dart';
import '../services/pairing_service.dart';

class ChildPairScreen extends StatefulWidget {
  const ChildPairScreen({super.key});

  @override
  State<ChildPairScreen> createState() => _ChildPairScreenState();
}

class _ChildPairScreenState extends State<ChildPairScreen> {
  final codeController = TextEditingController();

  final PairingService pairingService = Get.find<PairingService>();
  final LinkedChildStorage linkedChildStorage = Get.find<LinkedChildStorage>();

  String? error;
  bool isLoading = false;

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  Future<void> _submitCode() async {
    if (isLoading) return;

    final code = codeController.text.trim();

    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      setState(() {
        error = 'أدخل رمز ربط صحيحًا مكوّنًا من 6 أرقام.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final linkedChild = await pairingService.consumePairingCode(code);

      await linkedChildStorage.save(linkedChild);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ChildShell(),
        ),
      );
    } on StateError catch (exception) {
      if (!mounted) return;

      setState(() {
        error = exception.message.toString();
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        error = 'تعذر إتمام الربط. حاول مجددًا.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
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
                const Text(
                  'اطلب رمز الربط من ولي الأمر',
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: codeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  enabled: !isLoading,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  style: const TextStyle(
                    fontSize: 27,
                    letterSpacing: 9,
                  ),
                  decoration: const InputDecoration(
                    hintText: '••••••',
                    counterText: '',
                  ),
                  onSubmitted: (_) => _submitCode(),
                ),
                if (error != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                KButton(
                  label: isLoading ? 'جارٍ التحقق...' : 'متابعة',
                  large: true,
                  onPressed: isLoading ? null : _submitCode,
                ),
                const SizedBox(height: 10),
                const Text(
                  'رمز الربط مؤقت ويُستخدم مرة واحدة فقط.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
}
