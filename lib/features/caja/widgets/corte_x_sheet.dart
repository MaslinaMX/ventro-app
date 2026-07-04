import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/caja/controllers/sesion_caja_controller.dart';
import 'package:ventro_app/features/caja/widgets/verificar_empleado_fields.dart';

class CorteXSheet extends StatefulWidget {
  const CorteXSheet({super.key});

  @override
  State<CorteXSheet> createState() => _CorteXSheetState();
}

class _CorteXSheetState extends State<CorteXSheet> {
  final _formKey = GlobalKey<FormState>();
  final _employeeNumberCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  bool _verificado = false;
  bool _cargando = false;

  @override
  void dispose() {
    _employeeNumberCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _verificarYCargar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);

    final ctrl = context.read<SesionCajaController>();
    final ok = await ctrl.cargarCorteX(
      employeeNumber: _employeeNumberCtrl.text.trim(),
      pin: _pinCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() {
      _cargando = false;
      _verificado = ok;
    });

    if (!ok) {
      VntlToast.show(
        context,
        message: ctrl.errorMessage ?? 'No se pudo generar el corte',
        type: VntlToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ctrl = context.watch<SesionCajaController>();

    if (!_verificado) {
      return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            VerificarEmpleadoFields(
              employeeNumberCtrl: _employeeNumberCtrl,
              pinCtrl: _pinCtrl,
            ),
            const SizedBox(height: VntlSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: VntlButton(
                label: _cargando ? 'Generando...' : 'Ver corte X',
                loading: _cargando,
                onPressed: _cargando ? null : _verificarYCargar,
              ),
            ),
          ],
        ),
      );
    }

    final corte = ctrl.corteX;
    if (corte == null) {
      return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(VntlSpacing.lg),
          decoration: BoxDecoration(
            color: colors.success.withValues(alpha: 0.1),
            borderRadius: VntlRadius.lgBorderRadius,
            border: Border.all(color: colors.success.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Efectivo esperado en caja',
                style: VntlText.label.copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: VntlSpacing.xs),
              Text(
                '\$${corte.efectivoEsperado.toStringAsFixed(2)}',
                style: VntlText.h1.copyWith(color: colors.success),
              ),
            ],
          ),
        ),
        const SizedBox(height: VntlSpacing.lg),
        _filaResumen('Monto inicial', corte.montoInicial, colors),
        _filaResumen('Ventas en efectivo', corte.efectivoVentas, colors),
        const SizedBox(height: VntlSpacing.lg),
        Text('Totales por método de pago',
            style: VntlText.label.copyWith(color: colors.textTertiary)),
        const SizedBox(height: VntlSpacing.sm),
        ...corte.totalesPorMetodo.map((m) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(m.metodo, style: VntlText.body),
                  Text('\$${m.total.toStringAsFixed(2)}', style: VntlText.label),
                ],
              ),
            )),
        const SizedBox(height: VntlSpacing.lg),
        Divider(color: colors.border, height: 0.5),
        const SizedBox(height: VntlSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total vendido', style: VntlText.h4),
            Text('\$${corte.totalVentas.toStringAsFixed(2)}', style: VntlText.h4),
          ],
        ),
        Text(
          '${corte.cantidadVentas} venta${corte.cantidadVentas == 1 ? '' : 's'}',
          style: VntlText.caption.copyWith(color: colors.textTertiary),
        ),
        if (corte.ventasCanceladas.isNotEmpty) ...[
          const SizedBox(height: VntlSpacing.lg),
          Text(
            'Ventas canceladas (no incluidas en el cálculo)',
            style: VntlText.caption.copyWith(color: colors.warning),
          ),
          const SizedBox(height: VntlSpacing.sm),
          ...corte.ventasCanceladas.map((v) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ticket #${v.numeroTicket}',
                      style: VntlText.caption.copyWith(color: colors.textTertiary),
                    ),
                    Text(
                      '\$${v.total.toStringAsFixed(2)}',
                      style: VntlText.caption.copyWith(color: colors.textTertiary),
                    ),
                  ],
                ),
              )),
        ],
        const SizedBox(height: VntlSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: VntlButton(
            label: 'Cerrar',
            variant: VntlButtonVariant.ghost,
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }

  Widget _filaResumen(String label, double valor, dynamic colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: VntlText.body.copyWith(color: colors.textSecondary)),
          Text('\$${valor.toStringAsFixed(2)}', style: VntlText.label),
        ],
      ),
    );
  }
}
