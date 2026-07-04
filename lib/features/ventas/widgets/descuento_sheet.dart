import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/ventas/controllers/venta_controller.dart';
import 'package:ventro_app/features/ventas/models/tipo_descuento.dart';
// Ajusta este import al path real de VerificarEmpleadoFields
import 'package:ventro_app/features/caja/widgets/verificar_empleado_fields.dart';

class DescuentoSheet extends StatefulWidget {
  const DescuentoSheet({super.key});

  @override
  State<DescuentoSheet> createState() => _DescuentoSheetState();
}

class _DescuentoSheetState extends State<DescuentoSheet> {
  TipoDescuento _tipo = TipoDescuento.porcentaje;
  final _valorCtrl = TextEditingController();
  final _empleadoCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  bool _autorizando = false;
  String? _error;

  @override
  void dispose() {
    _valorCtrl.dispose();
    _empleadoCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  double get _valor => double.tryParse(_valorCtrl.text) ?? 0;

  Future<void> _confirmar() async {
    if (_valor <= 0) {
      setState(() => _error = 'Ingresa un valor de descuento válido.');
      return;
    }
    if (_tipo == TipoDescuento.porcentaje && _valor > 100) {
      setState(() => _error = 'El porcentaje no puede ser mayor a 100.');
      return;
    }
    if (_empleadoCtrl.text.isEmpty || _pinCtrl.text.length != 4) {
      setState(() => _error = 'Verifica el número de empleado y PIN.');
      return;
    }

    setState(() {
      _autorizando = true;
      _error = null;
    });

    final ctrl = context.read<VentaController>();
    final ok = await ctrl.aplicarDescuento(
      tipo: _tipo,
      valor: _valor,
      employeeNumber: _empleadoCtrl.text,
      pin: _pinCtrl.text,
    );

    if (!mounted) return;
    setState(() => _autorizando = false);

    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() => _error = ctrl.errorMessage ?? 'No se pudo autorizar el descuento.');
    }
  }

  void _quitar() {
    context.read<VentaController>().quitarDescuento();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ctrl = context.watch<VentaController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tipo de descuento', style: VntlText.label.copyWith(color: colors.textTertiary)),
        const SizedBox(height: VntlSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _TipoChip(
                label: 'Porcentaje (%)',
                seleccionado: _tipo == TipoDescuento.porcentaje,
                onTap: () => setState(() => _tipo = TipoDescuento.porcentaje),
              ),
            ),
            const SizedBox(width: VntlSpacing.sm),
            Expanded(
              child: _TipoChip(
                label: 'Monto (\$)',
                seleccionado: _tipo == TipoDescuento.fijo,
                onTap: () => setState(() => _tipo = TipoDescuento.fijo),
              ),
            ),
          ],
        ),
        const SizedBox(height: VntlSpacing.lg),
        VntlInput(
          label: _tipo == TipoDescuento.porcentaje ? 'Porcentaje' : 'Monto',
          hint: _tipo == TipoDescuento.porcentaje ? '0-100' : '0.00',
          controller: _valorCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: VntlSpacing.lg),
        VerificarEmpleadoFields(
          employeeNumberCtrl: _empleadoCtrl,
          pinCtrl: _pinCtrl,
        ),
        if (_error != null) ...[
          const SizedBox(height: VntlSpacing.sm),
          Text(_error!, style: VntlText.caption.copyWith(color: colors.error)),
        ],
        const SizedBox(height: VntlSpacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (ctrl.descuentoActivo) ...[
              VntlButton(
                label: 'Quitar descuento',
                variant: VntlButtonVariant.ghost,
                onPressed: _autorizando ? null : _quitar,
              ),
              const SizedBox(width: VntlSpacing.sm),
            ],
            VntlButton(
              label: _autorizando ? 'Autorizando...' : 'Aplicar',
              icon: Icons.local_offer_rounded,
              loading: _autorizando,
              onPressed: _autorizando ? null : _confirmar,
            ),
          ],
        ),
      ],
    );
  }
}

class _TipoChip extends StatelessWidget {
  final String label;
  final bool seleccionado;
  final VoidCallback onTap;

  const _TipoChip({required this.label, required this.seleccionado, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: VntlSpacing.sm),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: seleccionado ? colors.info.withOpacity(0.15) : colors.glassSurface,
          borderRadius: VntlRadius.smBorderRadius,
          border: Border.all(color: seleccionado ? colors.info : colors.border, width: 0.5),
        ),
        child: Text(
          label,
          style: VntlText.label.copyWith(color: seleccionado ? colors.info : colors.textSecondary),
        ),
      ),
    );
  }
}
