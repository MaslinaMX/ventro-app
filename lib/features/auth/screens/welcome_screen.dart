import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/auth/controllers/auth_controller.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  AuthController? _authController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      debugPrint('URI BASE: ${Uri.base}');
      debugPrint('FRAGMENT: ${Uri.base.fragment}');

      if (Uri.base.fragment.startsWith('/activar')) return;

      final auth = context.read<AuthController>();
      _authController = auth;
      if (auth.user != null) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        auth.addListener(_onAuthChanged);
      }
    });
  }

  void _onAuthChanged() {
    if (Uri.base.fragment.startsWith('/activar')) return;
    final auth = _authController;
    if (auth != null && auth.user != null && mounted) {
      auth.removeListener(_onAuthChanged);
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  @override
  void dispose() {
    _authController?.removeListener(_onAuthChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: context.backgroundGradient),
        child: Center(
          child: SizedBox(
            width: 420,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: context.backgroundGradient,
                    borderRadius: VntlRadius.lgBorderRadius,
                  ),
                  child: const Icon(Icons.point_of_sale_rounded, color: Colors.white, size: 36),
                ),
                const SizedBox(height: VntlSpacing.xl2),
                const Text('Ventro', style: VntlText.h1),
                const SizedBox(height: VntlSpacing.sm),
                Text(
                  'El punto de venta para tu negocio',
                  style: VntlText.body.copyWith(color: colors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: VntlSpacing.xl6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: VntlSpacing.md),
                  child: VntlCard(
                    child: Column(
                      children: [
                        VntlButton(
                          label: 'Crear mi negocio',
                          fullWidth: true,
                          size: VntlButtonSize.lg,
                          onPressed: () => Navigator.pushNamed(context, '/register'),
                        ),
                        const SizedBox(height: VntlSpacing.md),
                        VntlButton(
                          label: 'Ya tengo una cuenta',
                          fullWidth: true,
                          size: VntlButtonSize.lg,
                          variant: VntlButtonVariant.ghost,
                          onPressed: () => Navigator.pushNamed(context, '/lookup'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
