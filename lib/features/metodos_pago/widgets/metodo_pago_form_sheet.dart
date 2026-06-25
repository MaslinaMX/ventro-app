import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/metodos_pago/controllers/metodo_pago_controller.dart';
import 'package:ventro_app/features/metodos_pago/models/metodo_pago_model.dart';
import 'package:ventro_app/design_system/helpers/vntl_payment_style.dart';

class MetodoPagoFormSheet extends StatefulWidget {
  final MetodoPagoModel? metodoPago;
  const MetodoPagoFormSheet({super.key, this.metodoPago});

  @override
  State<MetodoPagoFormSheet> createState() => _MetodoPagoFormSheetState();
}

class _MetodoPagoFormSheetState extends State<MetodoPagoFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late bool _requiereReferencia;
  late String _iconoSeleccionado;
  late String _colorSeleccionado;

  bool get _isEditing => widget.metodoPago != null;

  @override
  void initState() {
    super.initState();
    final m = widget.metodoPago;
    _nombreCtrl = TextEditingController(text: m?.nombre ?? '');
    _requiereReferencia = m?.requiereReferencia ?? false;
    _iconoSeleccionado = m?.icono ?? VntlPaymentStyle.iconos.keys.first;
    _colorSeleccionado = m?.color ?? VntlPaymentStyle.colores.first;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ctrl = context.read<MetodoPagoController>();
    final data = {
      'nombre': _nombreCtrl.text.trim(),
      'requiere_referencia': _requiereReferencia,
      'icono': _iconoSeleccionado,
      'color': _colorSeleccionado,
    };

    final ok = _isEditing
        ? await ctrl.editMetodoPago(widget.metodoPago!.id, data)
        : await ctrl.createMetodoPago(data);

    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      VntlToast.show(
        context,
        message: _isEditing ? 'Método de pago actualizado' : 'Método de pago creado',
        type: VntlToastType.success,
      );
    } else {
      VntlToast.show(
        context,
        message: ctrl.errorMessage ?? 'Error al guardar',
        type: VntlToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ctrl = context.watch<MetodoPagoController>();

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Datos del Método de Pago',
              style: VntlText.label.copyWith(color: colors.textTertiary)),
          const SizedBox(height: VntlSpacing.md),
          VntlInput(
            label: 'Nombre',
            hint: 'Tarjeta de Crédito',
            controller: _nombreCtrl,
            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
          ),
          const SizedBox(height: VntlSpacing.lg),
          Text('Ícono', style: VntlText.labelSmall.copyWith(color: colors.textSecondary)),
          const SizedBox(height: VntlSpacing.sm),
          Wrap(
            spacing: VntlSpacing.sm,
            runSpacing: VntlSpacing.sm,
            children: [
              for (final entry in VntlPaymentStyle.iconos.entries)
                GestureDetector(
                  onTap: () => setState(() => _iconoSeleccionado = entry.key),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _iconoSeleccionado == entry.key
                          ? colors.primarySurface
                          : colors.surfaceSecondary,
                      borderRadius: VntlRadius.smBorderRadius,
                      border: Border.all(
                        color: _iconoSeleccionado == entry.key ? colors.primary : colors.border,
                        width: _iconoSeleccionado == entry.key ? 1.5 : 0.5,
                      ),
                    ),
                    child: Icon(
                      entry.value,
                      size: 18,
                      color:
                          _iconoSeleccionado == entry.key ? colors.primary : colors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: VntlSpacing.lg),
          Text('Color', style: VntlText.labelSmall.copyWith(color: colors.textSecondary)),
          const SizedBox(height: VntlSpacing.sm),
          Wrap(
            spacing: VntlSpacing.sm,
            runSpacing: VntlSpacing.sm,
            children: [
              for (final hex in VntlPaymentStyle.colores)
                GestureDetector(
                  onTap: () => setState(() => _colorSeleccionado = hex),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: VntlPaymentStyle.colorFromHex(hex),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _colorSeleccionado == hex ? colors.textPrimary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: _colorSeleccionado == hex
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                        : null,
                  ),
                ),
            ],
          ),
          const SizedBox(height: VntlSpacing.xl),
          VntlSwitch(
            value: _requiereReferencia,
            label: 'Requiere referencia o folio',
            tooltip: 'Activa esto si necesitas capturar un número de '
                'autorización o folio al cobrar con este método (común '
                'en tarjeta y transferencia). Para efectivo, déjalo apagado.',
            onChanged: (v) => setState(() => _requiereReferencia = v),
          ),
          const SizedBox(height: VntlSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              VntlButton(
                label: 'Cancelar',
                variant: VntlButtonVariant.ghost,
                onPressed: ctrl.isSaving ? null : () => Navigator.pop(context),
              ),
              const SizedBox(width: VntlSpacing.sm),
              VntlButton(
                label: ctrl.isSaving
                    ? 'Guardando...'
                    : (_isEditing ? 'Guardar cambios' : 'Crear Método'),
                loading: ctrl.isSaving,
                onPressed: ctrl.isSaving ? null : _submit,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
