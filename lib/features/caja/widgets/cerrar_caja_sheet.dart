import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/caja/controllers/sesion_caja_controller.dart';
import 'package:ventro_app/features/caja/widgets/verificar_empleado_fields.dart';

class CerrarCajaSheet extends StatefulWidget {
  const CerrarCajaSheet({super.key});

  @override
  State<CerrarCajaSheet> createState() => _CerrarCajaSheetState();
}

class _CerrarCajaSheetState extends State<CerrarCajaSheet> {
  final _formKey = GlobalKey<FormState>();
  final _montoCtrl = TextEditingController();
  final _employeeNumberCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();

  @override
  void dispose() {
    _montoCtrl.dispose();
    _employeeNumberCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final monto = double.tryParse(_montoCtrl.text.trim()) ?? 0;
    final ctrl = context.read<SesionCajaController>();
    final ok = await ctrl.cerrarCaja(
      employeeNumber: _employeeNumberCtrl.text.trim(),
      pin: _pinCtrl.text.trim(),
      montoFinalContado: monto,
    );

    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      final diferencia = ctrl.sesionActiva?.diferencia ?? 0;
      VntlToast.show(
        context,
        message: diferencia == 0
            ? 'Caja cerrada sin diferencias'
            : 'Caja cerrada. Diferencia: \$${diferencia.toStringAsFixed(2)}',
        type: diferencia == 0 ? VntlToastType.success : VntlToastType.warning,
      );
    } else {
      VntlToast.show(
        context,
        message: ctrl.errorMessage ?? 'Error al cerrar caja',
        type: VntlToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ctrl = context.watch<SesionCajaController>();
    final sesion = ctrl.sesionActiva;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VerificarEmpleadoFields(
            employeeNumberCtrl: _employeeNumberCtrl,
            pinCtrl: _pinCtrl,
          ),
          const SizedBox(height: VntlSpacing.lg),
          if (sesion != null) ...[
            Container(
              padding: const EdgeInsets.all(VntlSpacing.md),
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                borderRadius: VntlRadius.smBorderRadius,
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: colors.textTertiary),
                  const SizedBox(width: VntlSpacing.sm),
                  Expanded(
                    child: Text(
                      'Efectivo inicial: \$${sesion.montoInicial.toStringAsFixed(2)}',
                      style: VntlText.caption.copyWith(color: colors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: VntlSpacing.lg),
          ],
          VntlInput(
            label: 'Efectivo contado',
            hint: '0.00',
            controller: _montoCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: Icons.payments_rounded,
            validator: (v) {
              final n = double.tryParse(v ?? '');
              if (n == null || n < 0) return 'Ingresa un monto válido';
              return null;
            },
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
                label: ctrl.isSaving ? 'Cerrando...' : 'Cerrar Caja',
                loading: ctrl.isSaving,
                variant: VntlButtonVariant.danger,
                onPressed: ctrl.isSaving ? null : _submit,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
