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
  bool _loadedPreview = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadedPreview) {
      _loadedPreview = true;
      context.read<SesionCajaController>().cargarPreviewCierre();
    }
  }

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
    final ok = await ctrl.generarCorteZ(
      employeeNumber: _employeeNumberCtrl.text.trim(),
      pin: _pinCtrl.text.trim(),
      montoFinalContado: monto,
    );

    if (!mounted) return;
    if (ok) {
      final corte = ctrl.corteZ;
      Navigator.pop(context);

      final status = corte?.status;
      VntlToast.show(
        context,
        message: status == 'exacto'
            ? 'Caja cerrada sin diferencias'
            : 'Caja cerrada. Diferencia: \$${corte?.diferencia?.toStringAsFixed(2) ?? '0.00'}',
        type: status == 'exacto' ? VntlToastType.info : VntlToastType.warning,
      );

      if (corte?.corteId != null) {
        await ctrl.abrirCortePdf(corte!.corteId!);
      }
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

    final efectivoInicial = ctrl.previewEfectivoInicial ?? sesion?.montoInicial;
    final efectivoEsperado = ctrl.previewEfectivoEsperado;
    final totalVentas = ctrl.previewTotalVentas;
    final cantidadVentas = ctrl.previewCantidadVentas;

    final montoContado = double.tryParse(_montoCtrl.text.trim());
    final diferencia =
        (efectivoEsperado != null && montoContado != null) ? montoContado - efectivoEsperado : null;

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
          if (ctrl.cargandoPreview)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: VntlSpacing.md),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            Container(
              padding: const EdgeInsets.all(VntlSpacing.md),
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                borderRadius: VntlRadius.smBorderRadius,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FilaResumen(
                    label: 'Efectivo inicial',
                    valor: efectivoInicial,
                    colors: colors,
                  ),
                  if (efectivoEsperado != null)
                    _FilaResumen(
                      label: 'Efectivo esperado',
                      valor: efectivoEsperado,
                      colors: colors,
                    ),
                  if (totalVentas != null)
                    _FilaResumen(
                      label: 'Total vendido (${cantidadVentas ?? 0} ventas)',
                      valor: totalVentas,
                      colors: colors,
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
            onChanged: (_) => setState(() {}),
            validator: (v) {
              final n = double.tryParse(v ?? '');
              if (n == null || n < 0) return 'Ingresa un monto válido';
              return null;
            },
          ),
          if (diferencia != null) ...[
            const SizedBox(height: VntlSpacing.md),
            _BadgeDiferencia(diferencia: diferencia, colors: colors),
          ],
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

class _FilaResumen extends StatelessWidget {
  final String label;
  final double? valor;
  final dynamic colors;

  const _FilaResumen({required this.label, required this.valor, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: VntlText.caption.copyWith(color: colors.textSecondary)),
          Text(
            '\$${(valor ?? 0).toStringAsFixed(2)}',
            style: VntlText.label,
          ),
        ],
      ),
    );
  }
}

class _BadgeDiferencia extends StatelessWidget {
  final double diferencia;
  final dynamic colors;

  const _BadgeDiferencia({required this.diferencia, required this.colors});

  @override
  Widget build(BuildContext context) {
    final esExacto = diferencia.abs() < 0.01;
    final esSobrante = diferencia > 0;

    final color = esExacto ? colors.success : (esSobrante ? colors.info : colors.error);
    final label = esExacto
        ? 'Exacto'
        : esSobrante
            ? 'Sobrante: \$${diferencia.toStringAsFixed(2)}'
            : 'Faltante: \$${diferencia.abs().toStringAsFixed(2)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: VntlSpacing.md, vertical: VntlSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: VntlRadius.smBorderRadius,
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            esExacto
                ? Icons.check_circle_rounded
                : (esSobrante ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded),
            size: 16,
            color: color,
          ),
          const SizedBox(width: VntlSpacing.sm),
          Text(label, style: VntlText.label.copyWith(color: color)),
        ],
      ),
    );
  }
}
