import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../services/auth_service.dart';

class AuthController extends GetxController {
  AuthController(this._authService);

  final AuthService _authService;

  final isLoading = false.obs;
  final errorMessage = RxnString();

  Stream<User?> authStateChanges() {
    return _authService.authStateChanges();
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) {
    return _execute(
      () => _authService.signIn(
        email: email,
        password: password,
      ),
    );
  }

  Future<bool> register({
    required String email,
    required String password,
  }) {
    return _execute(
      () => _authService.register(
        email: email,
        password: password,
      ),
    );
  }

  Future<bool> resetPassword(String email) {
    return _execute(() => _authService.resetPassword(email));
  }

  Future<bool> signOut() {
    return _execute(_authService.signOut);
  }

  Future<bool> _execute(Future<void> Function() operation) async {
    if (isLoading.value) return false;

    isLoading.value = true;
    errorMessage.value = null;

    try {
      await operation();
      return true;
    } on FirebaseAuthException catch (error) {
      errorMessage.value = _authErrorMessage(error);
      return false;
    } on FirebaseException {
      errorMessage.value =
          'تعذر إكمال العملية عبر Firebase. تحقق من الاتصال وحاول مجددًا.';
      return false;
    } catch (_) {
      errorMessage.value = 'حدث خطأ غير متوقع. حاول مجددًا.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  String _authErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'هذا البريد مسجل بالفعل. جرّب تسجيل الدخول.';
      case 'invalid-email':
        return 'صيغة البريد الإلكتروني غير صحيحة.';
      case 'weak-password':
        return 'كلمة المرور ضعيفة؛ استخدم كلمة مرور أقوى.';
      case 'wrong-password':
      case 'user-not-found':
      case 'invalid-credential':
        return 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
      case 'too-many-requests':
        return 'محاولات كثيرة. حاول مجددًا لاحقًا.';
      case 'network-request-failed':
        return 'تعذر الاتصال بالإنترنت. حاول مجددًا.';
      case 'operation-not-allowed':
        return 'طريقة تسجيل الدخول غير مفعّلة في Firebase.';
      default:
        return 'تعذر إكمال العملية (${error.code}). حاول مجددًا.';
    }
  }
}
