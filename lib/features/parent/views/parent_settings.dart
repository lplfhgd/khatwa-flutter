import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/playful_colors.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../children/controllers/children_controller.dart';
import '../../settings/controllers/theme_controller.dart';
import '../../settings/services/notification_service.dart';
import '../../settings/controllers/notification_preferences_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart'
    show AuthorizationStatus;
import '../../settings/services/notification_device_service.dart';
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
    final palette = Theme.of(context).extension<PlayfulColors>()!;
    final user = FirebaseAuth.instance.currentUser;
    final themeController = Get.find<ThemeController>();

    final email = user?.email ?? '';
    final displayName = user?.displayName?.trim();

    final userName = displayName != null && displayName.isNotEmpty
        ? displayName
        : 'ولي الأمر';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        _ProfileCard(
          name: userName,
          email: email,
          palette: palette,
        ),
        const SizedBox(height: 22),
        _Group(
          title: '👤 الحساب',
          rows: [
            _Row(
              emoji: '🧾',
              title: 'معلومات الحساب',
              color: palette.blue,
              onTap: () {
                _showAccountInfo(
                  context,
                  name: userName,
                  email: email,
                );
              },
            ),
            _Row(
              emoji: '🔐',
              title: 'تغيير كلمة المرور',
              color: palette.blue,
              onTap: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  showDragHandle: true,
                  builder: (_) => const _ChangePasswordSheet(),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 22),
        _Group(
          title: '🎨 النظام',
          rows: [
            Obx(
              () => _Row(
                emoji: '🌓',
                title: 'المظهر',
                color: palette.green,
                trailing: _Pill(
                  text: themeController.currentLabel,
                ),
                onTap: () {
                  _showThemeSheet(
                    context,
                    themeController,
                  );
                },
              ),
            ),
            _Row(
              emoji: '🔔',
              title: 'الإشعارات والتنبيهات',
              color: palette.green,
              onTap: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  showDragHandle: true,
                  builder: (_) => const _NotificationSettingsSheet(),
                );
              },
            ),
            _Row(
              emoji: '🛡️',
              title: 'الخصوصية',
              color: palette.green,
              onTap: () {
                _showPrivacy(context);
              },
            ),
          ],
        ),
        const SizedBox(height: 22),
        _Group(
          title: '👧 الأطفال والأجهزة',
          rows: [
            _Row(
              emoji: '👧',
              title: 'إدارة الأطفال',
              color: palette.pink,
              onTap: onManageChildren,
            ),
            _Row(
              emoji: '🔗',
              title: 'الأجهزة المرتبطة',
              color: palette.pink,
              onTap: onManageDevices,
            ),
          ],
        ),
        const SizedBox(height: 26),
        _PillButton(
          emoji: '🚪',
          label: 'تسجيل الخروج',
          color: palette.orange,
          textColor: palette.onPastel,
          onTap: () => _logout(context),
        ),
      ],
    );
  }

  Future<void> _logout(BuildContext context) async {
    final authController = Get.find<AuthController>();

    final succeeded = await authController.signOut();

    if (succeeded) {
      Get.find<ChildrenController>().clearSession();
      return;
    }

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          authController.errorMessage.value ??
              'تعذّر تسجيل الخروج. حاول مجددًا.',
        ),
      ),
    );
  }

  void _showAccountInfo(
    BuildContext context, {
    required String name,
    required String email,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'معلومات الحساب',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 18),
                _InfoRow(
                  icon: Icons.person_outline_rounded,
                  label: 'الاسم',
                  value: name,
                ),
                _InfoRow(
                  icon: Icons.mail_outline_rounded,
                  label: 'البريد الإلكتروني',
                  value: email,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPrivacy(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'الخصوصية',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  'تُستخدم بيانات الطفل لتقديم وظائف التطبيق ومتابعة '
                  'التقدم، وتُحفظ بيانات ولي الأمر والطفل ضمن الحساب '
                  'المرتبط به. لا ينبغي مشاركة رمز ربط جهاز الطفل مع '
                  'أي شخص غير مخوّل.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.7,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showThemeSheet(
    BuildContext context,
    ThemeController themeController,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return _ThemeSheet(
          controller: themeController,
        );
      },
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.name,
    required this.email,
    required this.palette,
  });

  final String name;
  final String email;
  final PlayfulColors palette;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.yellow,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
            child: const Text(
              '🧑',
              style: TextStyle(fontSize: 34),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: palette.onPastel,
                  ),
                ),
                const SizedBox(height: 4),
                const _Pill(text: '🛡️ ولي الأمر'),
                const SizedBox(height: 4),
                Text(
                  email.isEmpty ? '—' : email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodySmall?.copyWith(
                    color: palette.onPastel,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
            child: const Text(
              '✏️',
              style: TextStyle(fontSize: 22),
            ),
          ),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({
    required this.title,
    required this.rows,
  });

  final String title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final children = <Widget>[];

    for (var i = 0; i < rows.length; i++) {
      if (i > 0) {
        children.add(
          Divider(
            height: 1,
            indent: 66,
            color: scheme.outlineVariant,
          ),
        );
      }

      children.add(rows[i]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(
            start: 6,
            bottom: 8,
          ),
          child: Text(
            title,
            style: text.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: scheme.outlineVariant,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.emoji,
    required this.title,
    required this.color,
    required this.onTap,
    this.trailing,
  });

  final String emoji;
  final String title;
  final Color color;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: text.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              if (trailing != null) ...[
                trailing!,
                const SizedBox(width: 8),
              ],
              Text(
                '◀',
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: scheme.outlineVariant,
          ),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.emoji,
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(999);

    return Material(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: text.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: scheme.primary,
      ),
      title: Text(label),
      subtitle: Text(
        value.isEmpty ? '—' : value,
      ),
    );
  }
}

class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSaving = false;
  bool _hideCurrentPassword = true;
  bool _hideNewPassword = true;
  bool _hideConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _requiredPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }

    return null;
  }

  String? _newPasswordValidator(String? value) {
    final requiredError = _requiredPassword(value);

    if (requiredError != null) {
      return requiredError;
    }

    if (value!.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }

    if (value == _currentPasswordController.text) {
      return 'اختر كلمة مرور جديدة مختلفة عن الحالية';
    }

    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    final requiredError = _requiredPassword(value);

    if (requiredError != null) {
      return requiredError;
    }

    if (value != _newPasswordController.text) {
      return 'كلمتا المرور غير متطابقتين';
    }

    return null;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final authController = Get.find<AuthController>();

    final succeeded = await authController.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (succeeded) {
      Navigator.of(context).pop();

      Get.snackbar(
        'تم الحفظ',
        'تم تغيير كلمة المرور بنجاح.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return;
    }

    final message = authController.errorMessage.value ??
        'تعذر تغيير كلمة المرور. حاول مجددًا.';

    Get.snackbar(
      'تعذر تغيير كلمة المرور',
      message.contains('البريد الإلكتروني أو كلمة المرور غير صحيحة')
          ? 'كلمة المرور الحالية غير صحيحة.'
          : message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          4,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'تغيير كلمة المرور',
                textAlign: TextAlign.center,
                style: text.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _currentPasswordController,
                obscureText: _hideCurrentPassword,
                textInputAction: TextInputAction.next,
                validator: _requiredPassword,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور الحالية',
                  prefixIcon: const Icon(
                    Icons.lock_outline_rounded,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _hideCurrentPassword = !_hideCurrentPassword;
                      });
                    },
                    icon: Icon(
                      _hideCurrentPassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                obscureText: _hideNewPassword,
                textInputAction: TextInputAction.next,
                validator: _newPasswordValidator,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور الجديدة',
                  prefixIcon: const Icon(
                    Icons.lock_reset_rounded,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _hideNewPassword = !_hideNewPassword;
                      });
                    },
                    icon: Icon(
                      _hideNewPassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _hideConfirmPassword,
                textInputAction: TextInputAction.done,
                validator: _confirmPasswordValidator,
                onFieldSubmitted: (_) {
                  if (!_isSaving) {
                    _save();
                  }
                },
                decoration: InputDecoration(
                  labelText: 'تأكيد كلمة المرور الجديدة',
                  prefixIcon: const Icon(
                    Icons.lock_reset_rounded,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _hideConfirmPassword = !_hideConfirmPassword;
                      });
                    },
                    icon: Icon(
                      _hideConfirmPassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isSaving ? null : _save,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'حفظ كلمة المرور',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
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

class _ThemeSheet extends StatelessWidget {
  const _ThemeSheet({
    required this.controller,
  });

  final ThemeController controller;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'المظهر',
              textAlign: TextAlign.center,
              style: text.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'اختر مظهر التطبيق المناسب لك',
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            Obx(
              () => Column(
                children: [
                  _ThemeOption(
                    icon: Icons.brightness_auto_rounded,
                    title: 'حسب النظام',
                    subtitle: 'يتبع إعداد المظهر في جهازك',
                    selected: controller.themeMode.value == ThemeMode.system,
                    onTap: () {
                      controller.setThemeMode(ThemeMode.system);
                    },
                  ),
                  const SizedBox(height: 10),
                  _ThemeOption(
                    icon: Icons.light_mode_rounded,
                    title: 'فاتح',
                    subtitle: 'استخدام المظهر الفاتح دائمًا',
                    selected: controller.themeMode.value == ThemeMode.light,
                    onTap: () {
                      controller.setThemeMode(ThemeMode.light);
                    },
                  ),
                  const SizedBox(height: 10),
                  _ThemeOption(
                    icon: Icons.dark_mode_rounded,
                    title: 'داكن',
                    subtitle: 'استخدام المظهر الداكن دائمًا',
                    selected: controller.themeMode.value == ThemeMode.dark,
                    onTap: () {
                      controller.setThemeMode(ThemeMode.dark);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final borderColor = selected ? scheme.primary : scheme.outlineVariant;

    return Material(
      color: selected
          ? scheme.primaryContainer.withValues(alpha: 0.45)
          : scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: borderColor,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: text.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: selected
                    ? Icon(
                        Icons.check_circle_rounded,
                        key: const ValueKey(true),
                        color: scheme.primary,
                      )
                    : Icon(
                        Icons.circle_outlined,
                        key: const ValueKey(false),
                        color: scheme.outline,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationSettingsSheet extends StatelessWidget {
  const _NotificationSettingsSheet();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationPreferencesController>();
    final notificationService = Get.find<NotificationService>();
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'الإشعارات والتنبيهات',
              textAlign: TextAlign.center,
              style: text.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'اختر التنبيهات التي ترغب في استقبالها',
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            Obx(
              () {
                if (!controller.isReady.value) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                return Column(
                  children: [
                    _NotificationOption(
                      icon: Icons.notifications_active_rounded,
                      title: 'تفعيل الإشعارات',
                      subtitle: 'السماح لتطبيق خطوة بإرسال التنبيهات',
                      value: controller.enabled.value,
                      onChanged: (value) async {
                        if (value) {
                          await notificationService.initialize();

                          final settings =
                              await notificationService.requestPermission();

                          final allowed = settings.authorizationStatus ==
                                  AuthorizationStatus.authorized ||
                              settings.authorizationStatus ==
                                  AuthorizationStatus.provisional;

                          if (!allowed) {
                            await controller.setEnabled(false);

                            Get.snackbar(
                              'الإشعارات غير مفعلة',
                              'يجب السماح بالإشعارات من إعدادات الجهاز.',
                              snackPosition: SnackPosition.BOTTOM,
                            );

                            return;
                          }
                        }

                        await controller.setEnabled(value);
                        if (Get.isRegistered<NotificationDeviceService>()) {
  await Get.find<NotificationDeviceService>().updateEnabled(value);
}
                      },
                    ),
                    const SizedBox(height: 10),
                    _NotificationOption(
                      icon: Icons.event_repeat_rounded,
                      title: 'تذكيرات الروتين',
                      subtitle: 'تنبيهات مرتبطة بروتين الطفل ومهامه',
                      value: controller.routineEnabled.value,
                      enabled: controller.enabled.value,
                      onChanged: controller.setRoutineEnabled,
                    ),
                    const SizedBox(height: 10),
                    _NotificationOption(
                      icon: Icons.insights_rounded,
                      title: 'التقدم والتقارير',
                      subtitle: 'تنبيهات حول تقدم الطفل والتقارير',
                      value: controller.progressEnabled.value,
                      enabled: controller.enabled.value,
                      onChanged: controller.setProgressEnabled,
                    ),
                    const SizedBox(height: 10),
                    _NotificationOption(
                      icon: Icons.campaign_rounded,
                      title: 'التنبيهات العامة',
                      subtitle: 'إشعارات مهمة تتعلق بالتطبيق والحساب',
                      value: controller.generalEnabled.value,
                      enabled: controller.enabled.value,
                      onChanged: controller.setGeneralEnabled,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationOption extends StatelessWidget {
  const _NotificationOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: enabled ? 1 : 0.45,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: scheme.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: text.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Switch(
              value: value,
              onChanged: enabled ? onChanged : null,
            ),
          ],
        ),
      ),
    );
  }
}
