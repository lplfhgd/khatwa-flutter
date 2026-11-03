import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/k_colors.dart';
import '../../../shared/widgets/k_button.dart';
import '../../children/controllers/selected_child_controller.dart';
import '../controllers/pairing_controller.dart';
import '../services/linked_device_service.dart';
import 'dart:async';

class ParentPairScreen extends StatefulWidget {
  const ParentPairScreen({super.key});

  @override
  State<ParentPairScreen> createState() => _ParentPairScreenState();
}

class _ParentPairScreenState extends State<ParentPairScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();

    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pairingController = Get.find<PairingController>();
    final selectedChildController = Get.find<SelectedChildController>();
    final linkedDeviceService = Get.find<LinkedDeviceService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ربط جهاز الطفل'),
      ),
      body: SafeArea(
        child: Obx(() {
          final pairing = pairingController.activePairing.value;
          final selectedChildId = selectedChildController.selectedChildId.value;
          final childName = selectedChildController.childName.value;

          if (selectedChildId == null) {
            return Padding(
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
                    'ربط جهاز الطفل',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'يجب اختيار ملف طفل قبل إنشاء رمز الربط.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  KButton(
                    label: 'رجوع',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 12),
              const Icon(
                Icons.phonelink_setup,
                size: 90,
                color: KColors.primary,
              ),
              const SizedBox(height: 18),
              const Text(
                'ربط جهاز الطفل',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'الطفل المحدد: $childName',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),

              // =========================
              // Pairing code
              // =========================

              if (pairing != null && !pairing.isExpired) ...[
                const Text(
                  'رمز الربط',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                SelectableText(
                  pairing.code,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 46,
                    letterSpacing: 8,
                    fontWeight: FontWeight.bold,
                    color: KColors.primary,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'هذا الرمز صالح لمدة 9 دقائق ويُستخدم مرة واحدة فقط لربط جهاز الطفل المحدد.',
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

              const SizedBox(height: 40),
              const Divider(),
              const SizedBox(height: 24),

              // =========================
              // Linked devices
              // =========================

              const Text(
                'الأجهزة المرتبطة',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'الأجهزة المرتبطة بحساب $childName',
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 18),

              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: linkedDeviceService.watchLinkedDevices(
                  selectedChildId,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'تعذر تحميل الأجهزة المرتبطة.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    );
                  }

                  final devices = snapshot.data?.docs ?? [];

                  final activeDevices = devices.where((device) {
                    return device.data()['active'] == true;
                  }).toList();

                  final revokedDevicesCount =
                      devices.length - activeDevices.length;

                  if (activeDevices.isEmpty) {
                    return Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.devices_other_outlined,
                                size: 42,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'لا توجد أجهزة نشطة مرتبطة بهذا الطفل.',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        if (revokedDevicesCount > 0) ...[
                          const SizedBox(height: 12),
                          Text(
                            'أجهزة سابقة تم إلغاء ربطها: $revokedDevicesCount',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    );
                  }

                  return Column(
                    children: [
                      ...activeDevices.map((device) {
                        final data = device.data();
                        final lastSeenAt = data['lastSeenAt'];

                        final lastSeenText = _formatLastSeen(
                          lastSeenAt is Timestamp ? lastSeenAt : null,
                        );

                        return Card(
                          margin: const EdgeInsets.only(
                            bottom: 12,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: KColors.primary.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.smartphone,
                                    color: KColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'جهاز الطفل',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        lastSeenText,
                                        style: TextStyle(
                                          color: KColors.primary,
                                          fontWeight: lastSeenText == 'نشط الآن'
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      if (lastSeenText != 'نشط الآن') ...[
                                        const SizedBox(height: 3),
                                        const Text(
                                          'مرتبط',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => _confirmRevoke(
                                    context: context,
                                    service: linkedDeviceService,
                                    childId: selectedChildId,
                                    deviceId: device.id,
                                  ),
                                  child: const Text(
                                    'إلغاء الربط',
                                    style: TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      if (revokedDevicesCount > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'أجهزة سابقة تم إلغاء ربطها: $revokedDevicesCount',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),
            ],
          );
        }),
      ),
    );
  }

  String _formatLastSeen(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'آخر نشاط غير معروف';
    }

    final now = DateTime.now();
    final lastSeen = timestamp.toDate();
    final difference = now.difference(lastSeen);

    if (difference.isNegative || difference < const Duration(minutes: 5)) {
      return 'نشط الآن';
    }

    if (difference.inMinutes < 60) {
      return 'آخر نشاط منذ ${difference.inMinutes} دقائق';
    }

    if (difference.inHours < 2) {
      return 'آخر نشاط منذ ساعة';
    }

    if (difference.inHours < 24) {
      return 'آخر نشاط منذ ${difference.inHours} ساعات';
    }

    if (difference.inDays < 2) {
      return 'آخر نشاط منذ يوم';
    }

    if (difference.inDays < 7) {
      return 'آخر نشاط منذ ${difference.inDays} أيام';
    }

    return 'آخر نشاط: '
        '${lastSeen.day}/${lastSeen.month}/${lastSeen.year}';
  }

  Future<void> _confirmRevoke({
    required BuildContext context,
    required LinkedDeviceService service,
    required String childId,
    required String deviceId,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('إلغاء ربط الجهاز؟'),
          content: const Text(
            'سيتم فصل هذا الجهاز عن حساب الطفل ولن يتمكن من الاستمرار في استخدامه.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('تراجع'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                'إلغاء الربط',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await service.revokeDevice(
        childId: childId,
        deviceId: deviceId,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم إلغاء ربط الجهاز بنجاح.',
          ),
        ),
      );
    } on StateError catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message.toString(),
          ),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تعذر إلغاء ربط الجهاز. حاول مجددًا.',
          ),
        ),
      );
    }
  }
}
