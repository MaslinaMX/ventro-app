// lib/features/auth/screens/reset_password_screen.dart

import 'package:flutter/material.dart';
import 'package:ventro_app/core/network/api_client.dart';
import 'package:ventro_app/design_system/vntl.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? token;
  final String? email;
  final String? tenantId;

  const ResetPasswordScreen({
    super.key,
    this.token,
    this.email,
    this.tenantId,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _showPassword = false;
  bool _showConfirm = false;
  bool _loading = false;
  bool _success = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.token == null || widget.email == null || widget.tenantId == null) {
      setState(() => _error = 'Link inválido o expirado.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final dio = ApiClient.instanceForTenant(widget.tenantId!);
      await dio.post('/reset-password', data: {
        'token': widget.token,
        'email': widget.email,
        'password': _password.text,
        'password_confirmation': _confirm.text,
      });
      if (!mounted) return;
      setState(() => _success = true);
    } catch (e) {
      setState(() {
        _error = 'El link expiró o es inválido. Solicita uno nuevo.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(VntlSpacing.xl),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(VntlSpacing.xl),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: VntlRadius.lgBorderRadius,
              border: Border.all(color: colors.border, width: 0.5),
            ),
            child: _success
                ? _SuccessState(colors: colors)
                : _FormState(
                    formKey: _formKey,
                    password: _password,
                    confirm: _confirm,
                    showPassword: _showPassword,
                    showConfirm: _showConfirm,
                    loading: _loading,
                    error: _error,
                    colors: colors,
                    onTogglePassword: () => setState(() => _showPassword = !_showPassword),
                    onToggleConfirm: () => setState(() => _showConfirm = !_showConfirm),
                    onSubmit: _submit,
                  ),
          ),
        ),
      ),
    );
  }
}

// ─── Form ─────────────────────────────────────────────────────────────────────

class _FormState extends StatelessWidget {
  const _FormState({
    required this.formKey,
    required this.password,
    required this.confirm,
    required this.showPassword,
    required this.showConfirm,
    required this.loading,
    required this.error,
    required this.colors,
    required this.onTogglePassword,
    required this.onToggleConfirm,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController password;
  final TextEditingController confirm;
  final bool showPassword;
  final bool showConfirm;
  final bool loading;
  final String? error;
  final VntlColorScheme colors;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirm;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_reset_rounded, color: colors.primary, size: 32),
          const SizedBox(height: VntlSpacing.md),
          Text('Nueva contraseña', style: VntlText.h4),
          const SizedBox(height: VntlSpacing.sm),
          Text(
            'Elige una contraseña segura para tu cuenta.',
            style: VntlText.body.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: VntlSpacing.xl),
          VntlInput(
            label: 'Nueva contraseña',
            hint: '••••••••',
            controller: password,
            obscureText: !showPassword,
            prefixIcon: Icons.lock_rounded,
            suffix: GestureDetector(
              onTap: onTogglePassword,
              child: Icon(
                showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 18,
                color: colors.textTertiary,
              ),
            ),
            validator: (v) {
              if (v?.isEmpty ?? true) return 'Requerido';
              if (v!.length < 8) return 'Mínimo 8 caracteres';
              return null;
            },
          ),
          const SizedBox(height: VntlSpacing.lg),
          VntlInput(
            label: 'Confirmar contraseña',
            hint: '••••••••',
            controller: confirm,
            obscureText: !showConfirm,
            prefixIcon: Icons.lock_rounded,
            suffix: GestureDetector(
              onTap: onToggleConfirm,
              child: Icon(
                showConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 18,
                color: colors.textTertiary,
              ),
            ),
            validator: (v) {
              if (v?.isEmpty ?? true) return 'Requerido';
              if (v != password.text) return 'Las contraseñas no coinciden';
              return null;
            },
          ),
          if (error != null) ...[
            const SizedBox(height: VntlSpacing.md),
            Text(error!, style: VntlText.body.copyWith(color: colors.error)),
          ],
          const SizedBox(height: VntlSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: VntlButton(
              label: 'Restablecer contraseña',
              loading: loading,
              onPressed: loading ? null : onSubmit,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Success ──────────────────────────────────────────────────────────────────

class _SuccessState extends StatelessWidget {
  const _SuccessState({required this.colors});

  final VntlColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle_outline_rounded, color: colors.success, size: 48),
        const SizedBox(height: VntlSpacing.md),
        Text('¡Contraseña restablecida!', style: VntlText.h4),
        const SizedBox(height: VntlSpacing.sm),
        Text(
          'Ya puedes iniciar sesión con tu nueva contraseña.',
          style: VntlText.body.copyWith(color: colors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: VntlSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: VntlButton(
            label: 'Ir al login',
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/lookup',
              (_) => false,
            ),
          ),
        ),
      ],
    );
  }
}
