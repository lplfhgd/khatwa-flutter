import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import 'parent_auth_screen.dart';

class ParentAuthGate extends StatelessWidget {
  const ParentAuthGate({
    super.key,
    required this.authenticatedBuilder,
  });

  final WidgetBuilder authenticatedBuilder;

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return StreamBuilder<User?>(
      stream: authController.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('حساب ولي الأمر'),
            ),
            body: const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'تعذّر التحقق من جلسة الدخول. تحقق من الاتصال بالإنترنت وحاول مجددًا.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        if (snapshot.data == null) {
          return const ParentAuthScreen();
        }

        return authenticatedBuilder(context);
      },
    );
  }
}
