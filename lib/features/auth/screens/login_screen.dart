import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/auth/controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Datos pasados desde LookupScreen
  late String _email;
  late String _tenantId;
  late String _empresa;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _email = args?['email'] ?? '';
      _tenantId = args?['tenant_id'] ?? '';
      _empresa = args?['empresa'] ?? '';
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = context.read<AuthController>();

    final success = await controller.login(
      email: _email,
      password: _passwordController.text,
      tenantId: _tenantId,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? 'Contraseña incorrecta'),
          backgroundColor: VntlColors.error,
        ),
      );
      controller.resetStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthController>().isLoading;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: VntlColors.backgroundGradient,
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(VntlSpacing.xl2),
            child: SizedBox(
              width: 420,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_back_rounded,
                              color: VntlColors.textSecondary, size: 20),
                          const SizedBox(width: VntlSpacing.sm),
                          Text('Regresar',
                              style: VntlText.body.copyWith(color: VntlColors.textSecondary)),
                        ],
                      ),
                    ),
                    const SizedBox(height: VntlSpacing.xl3),
                    const Text('Ingresa a tu cuenta', style: VntlText.h2),
                    const SizedBox(height: VntlSpacing.sm),
                    Text(
                      _empresa.isNotEmpty ? _empresa : 'Bienvenido de vuelta',
                      style: VntlText.body.copyWith(color: VntlColors.textSecondary),
                    ),
                    const SizedBox(height: VntlSpacing.xl3),
                    VntlCard(
                      child: Column(
                        children: [
                          // Email (solo lectura)
                          VntlInput(
                            label: 'Correo electrónico',
                            hint: _email,
                            controller: TextEditingController(text: _email),
                            prefixIcon: Icons.email_outlined,
                            enabled: false,
                          ),
                          const SizedBox(height: VntlSpacing.lg),
                          VntlInput(
                            label: 'Contraseña',
                            hint: '••••••••',
                            controller: _passwordController,
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _submit(),
                            suffix: GestureDetector(
                              onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                              child: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: VntlColors.textTertiary,
                                size: 18,
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Ingresa tu contraseña';
                              }
                              if (v.length < 8) return 'Mínimo 8 caracteres';
                              return null;
                            },
                          ),
                          const SizedBox(height: VntlSpacing.xl2),
                          VntlButton(
                            label: 'Entrar',
                            fullWidth: true,
                            size: VntlButtonSize.lg,
                            loading: isLoading,
                            onPressed: isLoading ? null : _submit,
                          ),
                        ],
                      ),
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
