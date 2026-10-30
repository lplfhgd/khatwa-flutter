import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../../../shared/widgets/k_button.dart';

class ParentAuthScreen extends StatefulWidget {
  const ParentAuthScreen({super.key});

  @override
  State<ParentAuthScreen> createState() => _ParentAuthScreenState();
}

class _ParentAuthScreenState extends State<ParentAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthController authController = Get.find<AuthController>();

  bool _register = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (authController.isLoading.value || !_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (_register) {
      await authController.register(email: email, password: password);
    } else {
      await authController.signIn(email: email, password: password);
    }
    // ParentAuthGate listens to auth changes and presents ParentShell.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_register ? 'إنشاء حساب ولي الأمر' : 'دخول ولي الأمر'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset('assets/images/khatwa_logo.png', height: 150),
                    const SizedBox(height: 16),
                    Text(
                      _register ? 'أنشئ حسابك في خطوة' : 'أهلًا بك في خطوة',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF263F43),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'حساب ولي الأمر فقط • لا يحتاج الطفل إلى بريد إلكتروني',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 26),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textDirection: TextDirection.ltr,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: 'البريد الإلكتروني',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) =>
                          RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                  .hasMatch((value ?? '').trim())
                              ? null
                              : 'أدخل بريدًا إلكترونيًا صحيحًا',
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _hidePassword,
                      textDirection: TextDirection.ltr,
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _hidePassword = !_hidePassword,
                          ),
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) => (value ?? '').length >= 6
                          ? null
                          : 'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    Obx(() {
                      final message = authController.errorMessage.value;
                      if (message == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          message,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                    Obx(() {
                      final busy = authController.isLoading.value;
                      return KButton(
                        label: busy
                            ? 'جارٍ المعالجة...'
                            : (_register ? 'إنشاء حساب' : 'تسجيل الدخول'),
                        onPressed: busy ? null : _submit,
                      );
                    }),
                    const SizedBox(height: 10),
                    Obx(() {
                      final busy = authController.isLoading.value;
                      return TextButton(
                        onPressed: busy
                            ? null
                            : () {
                                authController.errorMessage.value = null;
                                setState(() => _register = !_register);
                              },
                        child: Text(_register
                            ? 'لديك حساب بالفعل؟ تسجيل الدخول'
                            : 'ليس لديك حساب؟ إنشاء حساب جديد'),
                      );
                    }),
                    if (!_register)
                      Obx(() => TextButton(
                            onPressed: authController.isLoading.value
                                ? null
                                : _resetPassword,
                            child: const Text('نسيت كلمة المرور؟'),
                          )),
                    const SizedBox(height: 12),
                    const Text(
                      'هذه نسخة تطويرية. لا تُدخل معلومات شخصية حقيقية عن الأطفال قبل اكتمال حماية البيانات.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.blueGrey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
