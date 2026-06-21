// lib/features/perfil/widgets/change_password_dialog.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ventro_app/core/network/api_client.dart';
import 'package:ventro_app/design_system/vntl.dart';

class ChangePasswordDialog extends StatefulWidget {
  final VoidCallback? onChanged;
  final bool dismissible;

  const ChangePasswordDialog({
    this.onChanged,
    this.dismissible = true,
  });

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();

  bool _loading = false;
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final dio = ApiClient.instance;
      await dio.patch('/usuarios/me/password', data: {
        'current_password': _current.text,
        'password': _new.text,
        'password_confirmation': _confirm.text,
      });
      if (!mounted) return;
      Navigator.pop(context);
      widget.onChanged?.call();
    } on DioException catch (e) {
      final msg = e.response?.data?['message'];
      setState(() {
        _error = msg ?? 'Error al cambiar la contraseña. Intenta de nuevo.';
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Error al cambiar la contraseña. Intenta de nuevo.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PopScope(
      canPop: widget.dismissible,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: VntlRadius.lgBorderRadius,
            border: Border.all(color: colors.border, width: 0.5),
          ),
          padding: const EdgeInsets.all(VntlSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.dismissible)
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: Icon(Icons.close_rounded, color: colors.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                Icon(Icons.lock_outline_rounded, color: colors.primary, size: 32),
                const SizedBox(height: VntlSpacing.md),
                Text('Cambiar contraseña', style: VntlText.h4),
                const SizedBox(height: VntlSpacing.sm),
                Text(
                  'Ingresa tu contraseña actual y luego la nueva.',
                  style: VntlText.body.copyWith(color: colors.textSecondary),
                ),
                const SizedBox(height: VntlSpacing.xl),
                VntlInput(
                  label: 'Contraseña actual',
                  hint: '••••••••',
                  controller: _current,
                  obscureText: !_showCurrent,
                  prefixIcon: Icons.lock_rounded,
                  suffix: IconButton(
                    icon: Icon(
                      _showCurrent ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: colors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _showCurrent = !_showCurrent),
                  ),
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Requerido';
                    return null;
                  },
                ),
                const SizedBox(height: VntlSpacing.lg),
                VntlInput(
                  label: 'Nueva contraseña',
                  hint: '••••••••',
                  controller: _new,
                  obscureText: !_showNew,
                  prefixIcon: Icons.lock_rounded,
                  suffix: IconButton(
                    icon: Icon(
                      _showNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: colors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _showNew = !_showNew),
                  ),
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Requerido';
                    return null;
                  },
                ),
                const SizedBox(height: VntlSpacing.lg),
                VntlInput(
                  label: 'Confirmar nueva contraseña',
                  hint: '••••••••',
                  controller: _confirm,
                  obscureText: !_showConfirm,
                  prefixIcon: Icons.lock_rounded,
                  suffix: IconButton(
                    icon: Icon(
                      _showConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: colors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _showConfirm = !_showConfirm),
                  ),
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Requerido';
                    return null;
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: VntlSpacing.md),
                  Text(_error!, style: VntlText.body.copyWith(color: colors.error)),
                ],
                const SizedBox(height: VntlSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: VntlButton(
                    label: 'Cambiar contraseña',
                    loading: _loading,
                    onPressed: _loading ? null : _submit,
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
