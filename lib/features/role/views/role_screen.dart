import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/k_colors.dart';
import '../../../shared/widgets/k_card.dart';
import '../../auth/views/parent_auth_gate.dart';
import '../../children/views/child_profiles_screen.dart';
import '../../children/views/child_profiles_section.dart';
import '../../pairing/views/child_pair_screen.dart';
import '../../pairing/views/parent_pair_screen.dart';
import '../../parent/views/parent_content.dart';
import '../../parent/views/parent_home.dart';
import '../../parent/views/parent_progress.dart';
import '../../parent/views/parent_settings.dart';
import '../../parent/views/parent_shell.dart';
import '../../routine/views/parent_routine_screen.dart';

class RoleScreen extends StatelessWidget {
  const RoleScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Image.asset(
                  'assets/images/khatwa_logo.png',
                  height: 195,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 14),
                const Text(
                  'من سيستخدم التطبيق؟',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    color: KColors.text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'اختر نوع الواجهة للمتابعة',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 28),

                // Parent
                _RoleTile(
                  title: 'ولي الأمر',
                  subtitle: 'إدارة الطفل والمحتوى والمتابعة',
                  icon: Icons.family_restroom,
                  onTap: () => Get.to(
                    () => ParentAuthGate(
                      authenticatedBuilder: (context) => ParentShell(
                        homeBuilder: (navigate) => ParentHome(
                          navigate: navigate,
                          childProfiles: const ChildProfilesSection(),
                          onOpenRoutine: () => Get.to(
                            () => const ParentRoutineScreen(),
                          ),
                          onOpenPairing: () => Get.to(
                            () => const ParentPairScreen(),
                          ),
                        ),
                        content: const ParentContent(),
                        progress: const ParentProgress(),
                        settings: ParentSettings(
                          onManageChildren: () => Get.to(
                            () => const ChildProfilesScreen(),
                          ),
                          onManageDevices: () => Get.to(
                            () => const ParentPairScreen(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Child
                _RoleTile(
                  title: 'الطفل',
                  subtitle: 'التواصل والتعلم والروتين',
                  icon: Icons.child_care,
                  onTap: () => Get.to(
                    () => const ChildPairScreen(),
                  ),
                ),

                const Spacer(),

                const Text(
                  'حساب ولي الأمر وملفات الأطفال تُحفظ عبر Firebase؛ ربط جهاز الطفل تجريبي حاليًا.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blueGrey,
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      );
}

class _RoleTile extends StatelessWidget {
  const _RoleTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: KCard(
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: KColors.soft,
                radius: 34,
                child: Icon(
                  icon,
                  color: KColors.primary,
                  size: 35,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left),
            ],
          ),
        ),
      );
}
