// ✅ V2

import 'package:flutter/material.dart';
import 'package:ventro_app/core/storage/secure_storage.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/auth/services/activation_service.dart';

class ActivateScreen extends StatefulWidget {
  final String? token;
  final String? tenantId;
  const ActivateScreen({super.key, this.token, this.tenantId});

  @override
  State<ActivateScreen> createState() => _ActivateScreenState();
}

class _ActivateScreenState extends State<ActivateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  String? _token;
  String? _userName;
  bool _loading = true;
  bool _invalid = false;
  bool _submitting = false;
  bool _obscure = true;
  String? _error;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    // Limpia cualquier sesión activa para evitar que algo redirija
    // al dashboard mientras se valida el token de activación.
    await SecureStorage.clear();

    _token = widget.token;

    if (_token == null || _token!.isEmpty || widget.tenantId == null) {
      setState(() {
        _loading = false;
        _invalid = true;
      });
      return;
    }

    try {
      final result = await ActivationService().validateToken(_token!, widget.tenantId!);
      setState(() {
        _userName = result['name'];
        _userEmail = result['email'];
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _invalid = true;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await ActivationService().activate(
        token: _token!,
        password: _password.text,
        tenantId: widget.tenantId!,
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/lookup',
        (_) => false,
        arguments: {'email': _userEmail}, // ← pasar email
      );
    } catch (e) {
      setState(() {
        _error = 'Error al activar la cuenta. El enlace puede haber expirado.';
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(VntlSpacing.xl),
            child: _loading
                ? const CircularProgressIndicator()
                : _invalid
                    ? _InvalidState(colors: colors)
                    : _FormState(
                        userName: _userName ?? '',
                        formKey: _formKey,
                        password: _password,
                        confirm: _confirm,
                        obscure: _obscure,
                        onToggleObscure: () => setState(() => _obscure = !_obscure),
                        submitting: _submitting,
                        error: _error,
                        onSubmit: _submit,
                        colors: colors,
                      ),
          ),
        ),
      ),
    );
  }
}

class _InvalidState extends StatelessWidget {
  final VntlColorScheme colors;
  const _InvalidState({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.link_off_rounded, size: 48, color: colors.error),
        const SizedBox(height: VntlSpacing.lg),
        Text('Enlace inválido', style: VntlText.h3),
        const SizedBox(height: VntlSpacing.sm),
        Text(
          'Este enlace de activación es inválido o ha expirado.',
          style: VntlText.body.copyWith(color: colors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _FormState extends StatelessWidget {
  final String userName;
  final GlobalKey<FormState> formKey;
  final TextEditingController password;
  final TextEditingController confirm;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final bool submitting;
  final String? error;
  final VoidCallback onSubmit;
  final VntlColorScheme colors;

  const _FormState({
    required this.userName,
    required this.formKey,
    required this.password,
    required this.confirm,
    required this.obscure,
    required this.onToggleObscure,
    required this.submitting,
    required this.error,
    required this.onSubmit,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo / título
          Text('Ventro POS', style: VntlText.h3.copyWith(color: colors.primary)),
          const SizedBox(height: VntlSpacing.xl),

          Text('Bienvenido, $userName 👋', style: VntlText.h4),
          const SizedBox(height: VntlSpacing.sm),
          Text(
            'Establece una contraseña para activar tu cuenta.',
            style: VntlText.body.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: VntlSpacing.xl),

          VntlInput(
            label: 'Contraseña',
            controller: password,
            obscureText: obscure,
            suffix: GestureDetector(
              onTap: onToggleObscure,
              child: Icon(
                obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
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
            controller: confirm,
            obscureText: obscure,
            validator: (v) {
              if (v?.isEmpty ?? true) return 'Requerido';
              if (v != password.text) return 'Las contraseñas no coinciden';
              return null;
            },
          ),
          const SizedBox(height: VntlSpacing.xl),

          if (error != null) ...[
            Text(error!, style: VntlText.body.copyWith(color: colors.error)),
            const SizedBox(height: VntlSpacing.md),
          ],

          SizedBox(
            width: double.infinity,
            child: VntlButton(
              label: 'Activar cuenta',
              loading: submitting,
              onPressed: submitting ? null : onSubmit,
            ),
          ),
        ],
      ),
    );
  }
}
