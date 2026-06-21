// ✅ Primero el StatefulWidget, luego su State
import 'package:flutter/material.dart';
import 'package:ventro_app/core/network/api_client.dart';
import 'package:ventro_app/design_system/vntl.dart';

class ChangePinDialog extends StatefulWidget {
  final VoidCallback onChanged;
  final bool dismissible;

  const ChangePinDialog({
    required this.onChanged,
    this.dismissible = false,
  });

  @override
  State<ChangePinDialog> createState() => ChangePinDialogState();
}

class ChangePinDialogState extends State<ChangePinDialog> {
  final _formKey = GlobalKey<FormState>();
  final _pin = TextEditingController();
  final _confirmPin = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _pin.dispose();
    _confirmPin.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    print('>>> loading: true');
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final dio = ApiClient.instance;
      await dio.patch('/usuarios/me/pin', data: {
        'security_pin': _pin.text,
      });
      if (!mounted) return;
      Navigator.pop(context);
      widget.onChanged();
    } catch (e) {
      setState(() {
        _error = 'Error al cambiar el PIN. Intenta de nuevo.';
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
                Icon(Icons.pin_rounded, color: colors.primary, size: 32),
                const SizedBox(height: VntlSpacing.md),
                Text('Crea tu PIN de seguridad', style: VntlText.h4),
                const SizedBox(height: VntlSpacing.sm),
                Text(
                  'Por seguridad, debes establecer un PIN personal antes de continuar.',
                  style: VntlText.body.copyWith(color: colors.textSecondary),
                ),
                const SizedBox(height: VntlSpacing.xl),
                VntlInput(
                  label: 'Nuevo PIN',
                  hint: '4 dígitos',
                  controller: _pin,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  prefixIcon: Icons.lock_rounded,
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Requerido';
                    if (v!.length != 4) return '4 dígitos exactos';
                    if (v == '1234') return 'Elige un PIN diferente';
                    return null;
                  },
                ),
                const SizedBox(height: VntlSpacing.lg),
                VntlInput(
                  label: 'Confirmar PIN',
                  hint: '4 dígitos',
                  controller: _confirmPin,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  prefixIcon: Icons.lock_rounded,
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Requerido';
                    if (v != _pin.text) return 'Los PINs no coinciden';
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
                    label: 'Establecer PIN',
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
