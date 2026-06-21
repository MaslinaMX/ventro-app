import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _empresaController = TextEditingController();
  final _slugController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _slugEdited = false;

  @override
  void initState() {
    super.initState();
    // Auto-generar slug desde el nombre del negocio
    _empresaController.addListener(_onEmpresaChanged);
  }

  void _onEmpresaChanged() {
    if (_slugEdited) return;
    final slug = _empresaController.text
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-');
    _slugController.text = slug;
  }

  @override
  void dispose() {
    _empresaController.dispose();
    _slugController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = context.read<AuthController>();
    final colors = context.colors;

    final success = await controller.register(
      empresa: _empresaController.text.trim(),
      slug: _slugController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _confirmController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? 'Error al crear el negocio'),
          backgroundColor: colors.error,
        ),
      );
      controller.resetStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthController>().isLoading;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: context.backgroundGradient),
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
                    // Header
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Row(
                        children: [
                          Icon(Icons.arrow_back_rounded, color: colors.textSecondary, size: 20),
                          const SizedBox(width: VntlSpacing.sm),
                          Text('Regresar',
                              style: VntlText.body.copyWith(color: colors.textSecondary)),
                        ],
                      ),
                    ),
                    const SizedBox(height: VntlSpacing.xl3),
                    const Text('Crea tu negocio', style: VntlText.h2),
                    const SizedBox(height: VntlSpacing.sm),
                    Text(
                      'Configura tu cuenta en segundos',
                      style: VntlText.body.copyWith(color: colors.textSecondary),
                    ),
                    const SizedBox(height: VntlSpacing.xl3),

                    // Form
                    VntlCard(
                      child: Column(
                        children: [
                          VntlInput(
                            label: 'Nombre del negocio',
                            hint: 'Ej. Repostería Roma',
                            controller: _empresaController,
                            prefixIcon: Icons.store_rounded,
                            textInputAction: TextInputAction.next,
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Ingresa el nombre de tu negocio' : null,
                          ),
                          const SizedBox(height: VntlSpacing.lg),
                          VntlInput(
                            label: 'URL de tu negocio',
                            hint: 'reposteria-roma',
                            controller: _slugController,
                            prefixIcon: Icons.link_rounded,
                            textInputAction: TextInputAction.next,
                            onChanged: (_) => _slugEdited = true,
                            suffix: Text(
                              '.ventro.com.mx',
                              style: VntlText.caption.copyWith(color: colors.textTertiary),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Ingresa una URL para tu negocio';
                              }
                              if (v.length < 3) {
                                return 'Mínimo 3 caracteres';
                              }
                              if (!RegExp(r'^[a-z0-9\-]+$').hasMatch(v)) {
                                return 'Solo letras minúsculas, números y guiones';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: VntlSpacing.lg),
                          VntlInput(
                            label: 'Correo electrónico',
                            hint: 'correo@negocio.com',
                            controller: _emailController,
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Ingresa tu correo';
                              }
                              if (!v.contains('@')) return 'Correo inválido';
                              return null;
                            },
                          ),
                          const SizedBox(height: VntlSpacing.lg),
                          VntlInput(
                            label: 'Contraseña',
                            hint: 'Mínimo 8 caracteres',
                            controller: _passwordController,
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
                            suffix: GestureDetector(
                              onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                              child: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: colors.textTertiary,
                                size: 18,
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Ingresa una contraseña';
                              }
                              if (v.length < 8) return 'Mínimo 8 caracteres';
                              return null;
                            },
                          ),
                          const SizedBox(height: VntlSpacing.lg),
                          VntlInput(
                            label: 'Confirmar contraseña',
                            hint: 'Repite tu contraseña',
                            controller: _confirmController,
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: _obscureConfirm,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _submit(),
                            suffix: GestureDetector(
                              onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                              child: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: colors.textTertiary,
                                size: 18,
                              ),
                            ),
                            validator: (v) {
                              if (v != _passwordController.text) {
                                return 'Las contraseñas no coinciden';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: VntlSpacing.xl2),
                          VntlButton(
                            label: 'Crear negocio',
                            fullWidth: true,
                            size: VntlButtonSize.lg,
                            loading: isLoading,
                            onPressed: isLoading ? null : _submit,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: VntlSpacing.lg),
                    Center(
                      child: Text(
                        'Al crear tu cuenta aceptas nuestros términos de servicio',
                        style: VntlText.caption,
                        textAlign: TextAlign.center,
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
