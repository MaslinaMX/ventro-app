import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/features/dashboard/screens/dashboard_screen.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/screens/welcome_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/onboarding_screen.dart';
import 'features/auth/screens/lookup_screen.dart';
import 'features/auth/screens/login_screen.dart';

void main() {
  runApp(const VentroApp());
}

class VentroApp extends StatelessWidget {
  const VentroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
      ],
      child: MaterialApp(
        title: 'Ventro POS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: const ColorScheme.dark(),
          fontFamily: 'Inter',
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const WelcomeScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/register': (context) => const RegisterScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/lookup': (context) => const LookupScreen(),
          '/login': (context) => const LoginScreen(),
        },
      ),
    );
  }
}
