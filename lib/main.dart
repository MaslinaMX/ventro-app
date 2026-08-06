import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/core/config/env.dart';
import 'package:ventro_app/core/network/api_client.dart';
import 'package:ventro_app/features/account/controllers/account_controller.dart';
import 'package:ventro_app/features/account/screens/account_screen.dart';
import 'package:ventro_app/features/auth/screens/reset_password_screen.dart';
import 'package:ventro_app/features/auth/screens/activate_screen.dart';
import 'package:ventro_app/features/auth/screens/blocked_screen.dart';
import 'package:ventro_app/features/caja/controllers/caja_controller.dart';
import 'package:ventro_app/features/caja/controllers/sesion_caja_controller.dart';
import 'package:ventro_app/features/catalogo_publico/screens/catalogo_publico_screen.dart';
import 'package:ventro_app/features/clientes/controllers/clientes_controller.dart';
import 'package:ventro_app/features/dashboard/controllers/dashboard_controller.dart';
import 'package:ventro_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ventro_app/features/gastos/controllers/categoria_gasto_controller.dart';
import 'package:ventro_app/features/gastos/controllers/gasto_controller.dart';
import 'package:ventro_app/features/inventario/controllers/inventario_controller.dart';
import 'package:ventro_app/features/metodos_pago/controllers/metodo_pago_controller.dart';
import 'package:ventro_app/features/products/controllers/producto_controller.dart';
import 'package:ventro_app/features/settings/controllers/settings_controller.dart';
import 'package:ventro_app/features/settings/screens/my_profile_screen.dart';
import 'package:ventro_app/features/settings/screens/settings_screen.dart';
import 'package:ventro_app/features/tickets/controllers/configuracion_ticket_controller.dart';
import 'package:ventro_app/features/ventas/controllers/todas_ventas_controller.dart';
import 'package:ventro_app/features/ventas/controllers/venta_controller.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/screens/welcome_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/onboarding_screen.dart';
import 'features/auth/screens/lookup_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  usePathUrlStrategy();
  debugPrint('baseUrl: ${Env.baseUrl}');
  ApiClient.onTenantBlocked = (reason, message) {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => BlockedScreen(reason: reason, message: message),
      ),
      (_) => false,
    );
  };

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('🔴 FlutterError: ${details.exceptionAsString()}');
    debugPrint('🔴 Stack: ${details.stack}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('🔴 PlatformDispatcher error: $error');
    debugPrint('🔴 Stack: $stack');
    return true;
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
        ChangeNotifierProvider(create: (_) => ProductoController()),
        ChangeNotifierProvider(create: (_) => InventarioController()),
        ChangeNotifierProvider(create: (_) => CajaController()),
        ChangeNotifierProvider(create: (_) => MetodoPagoController()),
        ChangeNotifierProvider(create: (_) => SesionCajaController()),
        ChangeNotifierProvider(create: (_) => VentaController()),
        ChangeNotifierProvider(create: (_) => GastoController()),
        ChangeNotifierProvider(create: (_) => CategoriaGastoController()),
        ChangeNotifierProvider(create: (_) => ConfiguracionTicketController()),
        ChangeNotifierProvider(create: (_) => DashboardController()),
        ChangeNotifierProvider(create: (_) => TodasVentasController()),
        ChangeNotifierProvider(create: (_) => ClientesController()),
      ],
      child: // En main.dart — reemplaza el routes por onGenerateRoute
          MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Ventro POS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Inter',
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(fontFamily: 'Inter', brightness: Brightness.dark),
        themeMode: ThemeMode.system,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          final uri = Uri.parse(settings.name ?? '/');
          final path = uri.path;
          final token = uri.queryParameters['token'];

          Widget screen = switch (path) {
            '/' => const WelcomeScreen(),
            '/catalogo' => const CatalogoPublicoScreen(),
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
