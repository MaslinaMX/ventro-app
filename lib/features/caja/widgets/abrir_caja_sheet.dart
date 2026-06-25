import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/caja/controllers/sesion_caja_controller.dart';
import 'package:ventro_app/features/caja/models/caja_model.dart';
import 'package:ventro_app/features/caja/widgets/verificar_empleado_fields.dart';

class AbrirCajaSheet extends StatefulWidget {
  final CajaModel caja;
  const AbrirCajaSheet({super.key, required this.caja});

  @override
  State<AbrirCajaSheet> createState() => _AbrirCajaSheetState();
}

class _AbrirCajaSheetState extends State<AbrirCajaSheet> {
  final _formKey = GlobalKey<FormState>();
  final _montoCtrl = TextEditingController(text: '0');
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
    final ok = await ctrl.abrirCaja(
      cajaId: widget.caja.id,
      employeeNumber: _employeeNumberCtrl.text.trim(),
      pin: _pinCtrl.text.trim(),
      montoInicial: monto,
    );

    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      VntlToast.show(context, message: 'Caja abierta', type: VntlToastType.success);
    } else {
      VntlToast.show(
        context,
        message: ctrl.errorMessage ?? 'Error al abrir caja',
        type: VntlToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<SesionCajaController>();

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VerificarEmpleadoFields(
            employeeNumberCtrl: _employeeNumberCtrl,
            pinCtrl: _pinCtrl,
          ),
          const SizedBox(height: VntlSpacing.xl),
          VntlInput(
            label: 'Efectivo inicial',
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
                label: ctrl.isSaving ? 'Abriendo...' : 'Abrir Caja',
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
