import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/bindings/app_binding.dart';
import 'features/startup/views/app_start_screen.dart';
import 'core/theme/k_colors.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const KhatwaApp());
}

class KhatwaApp extends StatefulWidget {
  const KhatwaApp({super.key});
  @override
  State<KhatwaApp> createState() => _KhatwaAppState();
}

class _KhatwaAppState extends State<KhatwaApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: AppBinding(),
      debugShowCheckedModeBanner: false,
      title: 'خطوة | Khatwa',
      locale: const Locale('ar'),
      theme: ThemeData(
        useMaterial3: true,
        fontFamily:
            'IBM Plex Sans Arabic', // Requires user-installed font assets for exact production rendering.
        scaffoldBackgroundColor: KColors.background,
        colorScheme: ColorScheme.fromSeed(
            seedColor: KColors.primary,
            primary: KColors.primary,
            surface: KColors.background),
        appBarTheme: const AppBarTheme(
            backgroundColor: KColors.background,
            foregroundColor: KColors.text,
            centerTitle: true),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: KColors.soft,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
      ),
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
      home: const AppStartScreen(),
    );
  }
}

/// Requires a signed-in parent before allowing access to parent tools.
