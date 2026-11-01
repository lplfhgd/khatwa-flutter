import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/k_colors.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../children/controllers/children_controller.dart';
import '../../../shared/widgets/k_button.dart';
import '../../../shared/widgets/k_card.dart';

class ParentSettings extends StatelessWidget {
  const ParentSettings({
    super.key,
    required this.onManageChildren,
    required this.onManageDevices,
  });

  final VoidCallback onManageChildren;
  final VoidCallback onManageDevices;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'الإعدادات',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        _SettingsShortcut(
          icon: Icons.child_care_outlined,
          title: 'إدارة ملفات الأطفال',
          onTap: onManageChildren,
        ),
        _SettingsShortcut(
          icon: Icons.devices_other_outlined,
          title: 'الأجهزة المرتبطة (عرض توضيحي)',
          onTap: onManageDevices,
        ),
        const KCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الخصوصية',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'تسجيل ولي الأمر وملفات الأطفال مرتبطة بـFirebase. '
                'بطاقات AAC والروتين لا تزال تجريبية ومحلية، وربط جهاز الطفل '
                'غير مؤمّن بعد. استخدم بيانات أطفال وهمية خلال التطوير.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        KButton(
          label: 'تسجيل خروج ولي الأمر',
          outlined: true,
          onPressed: () async {
            final authController = Get.find<AuthController>();
            final succeeded = await authController.signOut();

            if (succeeded) {
              Get.find<ChildrenController>().clearSession();
            } else if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    authController.errorMessage.value ??
                        'تعذّر تسجيل الخروج. حاول مجددًا.',
                  ),
                ),
              );
            }
          },
        ),
        const SizedBox(height: 10),
        const KCard(
          child: Text(
            'تفضيلات الطفل الحسية، إدارة الأجهزة الحقيقية والإشعارات '
            'ستُفعّل في المراحل التالية.',
          ),
        ),
      ],
    );
  }
}

class _SettingsShortcut extends StatelessWidget {
  const _SettingsShortcut({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: KCard(
        child: ListTile(
          leading: Icon(
            icon,
            color: KColors.primary,
            size: 29,
          ),
          title: Text(title),
          trailing: const Icon(Icons.chevron_left),
          onTap: onTap,
        ),
      ),
    );
  }
}
