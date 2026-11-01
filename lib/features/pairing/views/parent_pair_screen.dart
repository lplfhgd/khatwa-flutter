import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/k_colors.dart';
import '../../../shared/widgets/k_button.dart';
import '../../children/controllers/selected_child_controller.dart';
import '../controllers/pairing_controller.dart';

class ParentPairScreen extends StatelessWidget {
  const ParentPairScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pairingController = Get.find<PairingController>();
    final selectedChildController = Get.find<SelectedChildController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ربط جهاز الطفل'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Obx(() {
            final pairing = pairingController.activePairing.value;
            final selectedChildId =
                selectedChildController.selectedChildId.value;
            final childName = selectedChildController.childName.value;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.phonelink_setup,
                  size: 100,
                  color: KColors.primary,
                ),
                const SizedBox(height: 20),
                const Text(
                  'ربط جهاز الطفل',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                if (selectedChildId == null) ...[
                  const Text(
                    'يجب اختيار ملف طفل قبل إنشاء رمز الربط.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  KButton(
                    label: 'رجوع',
                    onPressed: () => Navigator.pop(context),
                  ),
                ] else ...[
                  Text(
                    'الطفل المحدد: $childName',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (pairing != null && !pairing.isExpired) ...[
                    const Text(
                      'رمز الربط',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SelectableText(
                      pairing.code,
                      style: const TextStyle(
                        fontSize: 46,
                        letterSpacing: 8,
                        fontWeight: FontWeight.bold,
                        color: KColors.primary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'هذا الرمز صالح لمدة 10 دقائق ومخصص لربط جهاز الطفل المحدد.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 26),
                  ] else ...[
                    const Text(
                      'أنشئ رمزًا مؤقتًا ثم أدخله على جهاز الطفل.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 26),
                  ],
                  if (pairingController.errorMessage.value != null) ...[
                    Text(
                      pairingController.errorMessage.value!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  KButton(
                    label: pairingController.isCreating.value
                        ? 'جاري إنشاء الرمز...'
                        : pairing == null || pairing.isExpired
                            ? 'إنشاء رمز ربط'
                            : 'إنشاء رمز جديد',
                    onPressed: pairingController.isCreating.value
                        ? null
                        : pairingController.createCode,
                  ),
                ],
              ],
            );
          }),
        ),
      ),
    );
  }
}
