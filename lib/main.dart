import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:safeentry/constants/app_colors.dart';
import 'package:safeentry/screens/auth/login_screen.dart';
import 'package:safeentry/screens/concierge/home_concierge.dart';
// import 'package:safeentry/screens/auth/concierge_login_screen.dart'; // REMOVIDO
import 'package:safeentry/screens/resident/home_resident.dart';
import 'package:safeentry/screens/auth/register_screen.dart'; // Add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const SafeEntryApp());
}

class SafeEntryApp extends StatelessWidget {
  const SafeEntryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SAFEENTRY',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme(
          primary: AppColors.primary,
          primaryContainer: AppColors.primaryDark,
          secondary: AppColors.secondary,
          secondaryContainer: AppColors.secondary,
          surface: AppColors.surface,
          error: AppColors.error,
          onPrimary: AppColors.onPrimary,
          onSecondary: AppColors.onSecondary,
          onSurface: AppColors.onSurface,
          onError: AppColors.onError,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/': (context) => const LoginScreen(),
        '/login': (context) => const LoginScreen(),
        '/resident': (context) => const ResidentHomeScreen(),
        // REMOVIDO: '/concierge-login': (context) => ConciergeLoginScreen(),
        '/concierge': (context) => const ConciergeHomeScreen(),
        '/register': (context) => const RegisterScreen(), // Add the new route here
        // outras rotas futuras podem ser adicionadas aqui
      },
    );
  }
}