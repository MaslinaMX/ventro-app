import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/caja/widgets/verificar_empleado_fields.dart';
import 'package:ventro_app/features/ventas/controllers/venta_controller.dart';

class VerificarEmpleadoVenta extends StatefulWidget {
  const VerificarEmpleadoVenta({super.key});

  @override
  State<VerificarEmpleadoVenta> createState() => _VerificarEmpleadoVentaState();
}

class _VerificarEmpleadoVentaState extends State<VerificarEmpleadoVenta> {
  final _formKey = GlobalKey<FormState>();
  final _employeeNumberCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();

  @override
  void dispose() {
    _employeeNumberCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ctrl = context.read<VentaController>();
    final ok = await ctrl.verificarEmpleado(
      _employeeNumberCtrl.text.trim(),
      _pinCtrl.text.trim(),
    );
    if (!ok && mounted) {
      VntlToast.show(
        context,
        message: ctrl.errorMessage ?? 'No se pudo verificar al empleado',
        type: VntlToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ctrl = context.watch<VentaController>();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(VntlSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.badge_rounded, size: 40, color: colors.primary),
                const SizedBox(height: VntlSpacing.lg),
                Text('¿Quién está vendiendo?', style: VntlText.h3),
                const SizedBox(height: VntlSpacing.xs),
                Text(
                  'Verifica tu identidad para empezar a cobrar.',
                  style: VntlText.body.copyWith(color: colors.textSecondary),
                ),
                const SizedBox(height: VntlSpacing.xl),
                VerificarEmpleadoFields(
                  employeeNumberCtrl: _employeeNumberCtrl,
                  pinCtrl: _pinCtrl,
                ),
                const SizedBox(height: VntlSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: VntlButton(
                        label: 'Cambiar de caja',
                        variant: VntlButtonVariant.ghost,
                        onPressed: ctrl.cambiarCaja,
                      ),
                    ),
                    const SizedBox(width: VntlSpacing.sm),
                    Expanded(
                      child: VntlButton(
                        label: 'Continuar',
                        loading: ctrl.verificandoEmpleado,
                        onPressed: ctrl.verificandoEmpleado ? null : _submit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
