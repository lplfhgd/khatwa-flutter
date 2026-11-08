import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

class ParentAuthScreen extends StatefulWidget {
  const ParentAuthScreen({super.key});

  @override
  State<ParentAuthScreen> createState() => _ParentAuthScreenState();
}

class _ParentAuthScreenState extends State<ParentAuthScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final AuthController authController = Get.find<AuthController>();

  bool _register = false;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  static const Color _primary = Color(0xFF168F8B);
  static const Color _secondary = Color(0xFF76C99C);
  static const Color _text = Color(0xFF263F43);
  static const Color _fieldBackground = Color(0xFFF3F7F6);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (authController.isLoading.value) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_register) {
      await authController.register(
        fullName: _nameController.text.trim(),
        email: email,
        password: password,
      );
    } else {
      await authController.signIn(
        email: email,
        password: password,
      );
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      authController.errorMessage.value =
          'اكتب بريدك الإلكتروني أولًا لإرسال رابط الاستعادة.';
      return;
    }

    final succeeded = await authController.resetPassword(email);

    if (succeeded && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'إذا كان البريد مرتبطًا بحساب، ستصلك رسالة استعادة كلمة المرور.',
          ),
        ),
      );
    }
  }

  void _switchMode() {
    authController.errorMessage.value = null;

    setState(() {
      _register = !_register;
      _hidePassword = true;
      _hideConfirmPassword = true;
      _passwordController.clear();
      _confirmPasswordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 26,
                vertical: 20,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 10),
                        Center(
                          child: Image.asset(
                            'assets/images/parent/logo.png',
                            height: 145,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _register ? 'إنشاء حساب جديد' : 'مرحبًا بعودتك',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: _text,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _register
                              ? 'أنشئ حسابك وابدأ رحلتك مع خطوة'
                              : 'سجّل الدخول لمتابعة رحلة طفلك',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _text.withValues(alpha: 0.62),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: _register ? 30 : 38),
                        if (_register) ...[
                          _AuthField(
                            controller: _nameController,
                            label: 'الاسم الكامل',
                            hint: 'أدخل اسمك الكامل',
                            icon: Icons.person_outline_rounded,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if ((value ?? '').trim().length < 2) {
                                return 'أدخل الاسم الكامل';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                        _AuthField(
                          controller: _emailController,
                          label: 'البريد الإلكتروني',
                          hint: 'example@email.com',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            final email = (value ?? '').trim();

                            if (!RegExp(
                              r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                            ).hasMatch(email)) {
                              return 'أدخل بريدًا إلكترونيًا صحيحًا';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _AuthField(
                          controller: _passwordController,
                          label: 'كلمة المرور',
                          hint: 'أدخل كلمة المرور',
                          icon: Icons.lock_outline_rounded,
                          obscureText: _hidePassword,
                          textInputAction: _register
                              ? TextInputAction.next
                              : TextInputAction.done,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _hidePassword = !_hidePassword;
                              });
                            },
                            icon: Icon(
                              _hidePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: _primary,
                            ),
                          ),
                          validator: (value) {
                            if ((value ?? '').length < 6) {
                              return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                            }

                            return null;
                          },
                          onFieldSubmitted: _register ? null : (_) => _submit(),
                        ),
                        if (_register) ...[
                          const SizedBox(height: 16),
                          _AuthField(
                            controller: _confirmPasswordController,
                            label: 'تأكيد كلمة المرور',
                            hint: 'أعد إدخال كلمة المرور',
                            icon: Icons.lock_reset_rounded,
                            obscureText: _hideConfirmPassword,
                            textInputAction: TextInputAction.done,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _hideConfirmPassword = !_hideConfirmPassword;
                                });
                              },
                              icon: Icon(
                                _hideConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: _primary,
                              ),
                            ),
                            validator: (value) {
                              if (value != _passwordController.text) {
                                return 'كلمتا المرور غير متطابقتين';
                              }

                              return null;
                            },
                            onFieldSubmitted: (_) => _submit(),
                          ),
                        ],
                        if (!_register) ...[
                          const SizedBox(height: 4),
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: Obx(
                              () => TextButton(
                                onPressed: authController.isLoading.value
                                    ? null
                                    : _resetPassword,
                                child: const Text(
                                  'نسيت كلمة المرور؟',
                                  style: TextStyle(
                                    color: _primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                        Obx(() {
                          final message = authController.errorMessage.value;

                          if (message == null) {
                            return const SizedBox.shrink();
                          }

                          return Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1F1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFFB3261E),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 22),
                        Obx(() {
                          final busy = authController.isLoading.value;

                          return SizedBox(
                            height: 56,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    _primary,
                                    _secondary,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: _primary.withValues(alpha: 0.20),
                                    blurRadius: 18,
                                    offset: const Offset(0, 7),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: busy ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  backgroundColor: Colors.transparent,
                                  disabledBackgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: busy
                                    ? const SizedBox(
                                        width: 23,
                                        height: 23,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        _register
                                            ? 'إنشاء الحساب'
                                            : 'تسجيل الدخول',
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _register
                                  ? 'لديك حساب بالفعل؟'
                                  : 'ليس لديك حساب؟',
                              style: TextStyle(
                                color: _text.withValues(alpha: 0.65),
                                fontSize: 14,
                              ),
                            ),
                            Obx(
                              () => TextButton(
                                onPressed: authController.isLoading.value
                                    ? null
                                    : _switchMode,
                                child: Text(
                                  _register ? 'تسجيل الدخول' : 'إنشاء حساب',
                                  style: const TextStyle(
                                    color: _primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 7),
          child: Text(
            label,
            style: const TextStyle(
              color: _ParentAuthScreenState._text,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          validator: validator,
          autocorrect: false,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: _ParentAuthScreenState._text.withValues(
                alpha: 0.38,
              ),
            ),
            filled: true,
            fillColor: _ParentAuthScreenState._fieldBackground,
            prefixIcon: Icon(
              icon,
              color: _ParentAuthScreenState._primary,
            ),
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 17,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFE2ECEA),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: _ParentAuthScreenState._primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFB3261E),
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFB3261E),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
