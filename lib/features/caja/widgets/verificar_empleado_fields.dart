import 'package:flutter/material.dart';
import 'package:ventro_app/design_system/vntl.dart';

/// Par de campos para verificar identidad de un empleado por número + PIN.
/// Se usa en acciones sensibles de caja (abrir, cerrar, corte X) donde
/// la terminal puede estar compartida entre varios cajeros.
class VerificarEmpleadoFields extends StatelessWidget {
  final TextEditingController employeeNumberCtrl;
  final TextEditingController pinCtrl;

  const VerificarEmpleadoFields({
    super.key,
    required this.employeeNumberCtrl,
    required this.pinCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Verifica tu identidad', style: VntlText.label.copyWith(color: colors.textTertiary)),
        const SizedBox(height: VntlSpacing.md),
        VntlInput(
          label: 'Número de empleado',
          hint: 'EMP-0001',
          controller: employeeNumberCtrl,
          prefixIcon: Icons.badge_rounded,
          validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
        ),
        const SizedBox(height: VntlSpacing.lg),
        VntlInput(
          label: 'PIN',
          hint: '4 dígitos',
          controller: pinCtrl,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          prefixIcon: Icons.lock_rounded,
          validator: (v) {
            if (v?.isEmpty ?? true) return 'Requerido';
            if (v!.length != 4) return '4 dígitos exactos';
            return null;
          },
        ),
      ],
    );
  }
}
