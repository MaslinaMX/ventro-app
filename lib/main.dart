import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/core/config/env.dart';
import 'package:ventro_app/core/network/api_client.dart';
import 'package:ventro_app/features/account/controllers/account_controller.dart';
import 'package:ventro_app/features/account/screens/account_screen.dart';
import 'package:ventro_app/features/auth/screens/ResetPasswordScreen.dart';
import 'package:ventro_app/features/auth/screens/activate_screen.dart';
import 'package:ventro_app/features/auth/screens/blocked_screen.dart';
import 'package:ventro_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ventro_app/features/products/controllers/producto_controller.dart';
import 'package:ventro_app/features/settings/controllers/settings_controller.dart';
import 'package:ventro_app/features/settings/screens/my_profile_screen.dart';
import 'package:ventro_app/features/settings/screens/settings_screen.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/screens/welcome_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/onboarding_screen.dart';
import 'features/auth/screens/lookup_screen.dart';
import 'features/auth/screens/login_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  debugPrint('baseUrl: ${Env.baseUrl}');
  ApiClient.onTenantBlocked = (reason, message) {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => BlockedScreen(reason: reason, message: message),
      ),
      (_) => false,
    );
  };
  runApp(const VentroApp());
}

class VentroApp extends StatelessWidget {
  const VentroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => SettingsController()),
        ChangeNotifierProvider(create: (_) => AccountController()),
        ChangeNotifierProvider(create: (_) => ProductoController())
      ],
      child: // En main.dart — reemplaza el routes por onGenerateRoute
          MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Ventro POS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Inter', brightness: Brightness.light),
        darkTheme: ThemeData(fontFamily: 'Inter', brightness: Brightness.dark),
        themeMode: ThemeMode.system,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          final uri = Uri.parse(settings.name ?? '/');
          final path = uri.path;
          final token = uri.queryParameters['token'];

          Widget screen = switch (path) {
            '/' => const WelcomeScreen(),
            '/dashboard' => const DashboardScreen(),
            '/register' => const RegisterScreen(),
            '/onboarding' => const OnboardingScreen(),
            '/lookup' => const LookupScreen(),
            '/login' => const LoginScreen(),
            '/preferencias' => const SettingsScreen(),
            '/cuenta' => const AccountScreen(),
            '/mi-perfil' => const MyProfileScreen(),
            '/activar' => ActivateScreen(
                token: token,
                tenantId: uri.queryParameters['tenant'],
              ),
            '/reset-password' => ResetPasswordScreen(
                token: uri.queryParameters['token'],
                email: uri.queryParameters['email'],
                tenantId: uri.queryParameters['tenant'],
              ),
            _ => const WelcomeScreen(),
          };

          return MaterialPageRoute(builder: (_) => screen, settings: settings);
        },
      ),
    );
  }
}
