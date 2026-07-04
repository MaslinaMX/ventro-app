import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/caja/controllers/sesion_caja_controller.dart';
import 'package:ventro_app/features/caja/models/corte_caja_model.dart';
import 'package:ventro_app/features/caja/widgets/verificar_empleado_fields.dart';

class CorteXScreen extends StatefulWidget {
  const CorteXScreen({super.key});

  @override
  State<CorteXScreen> createState() => _CorteXScreenState();
}

class _CorteXScreenState extends State<CorteXScreen> {
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: context.backgroundGradient),
        child: Column(
          children: [
            VntlAppBar(
              title: 'Corte X',
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.arrow_back_rounded, color: colors.textSecondary, size: 20),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(VntlSpacing.xl),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: _verificado ? _buildReporte(context) : _buildVerificacion(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificacion(BuildContext context) {
    final colors = context.colors;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Verifica tu identidad', style: VntlText.h3),
          const SizedBox(height: VntlSpacing.xs),
          Text(
            'Genera un corte parcial sin cerrar la sesión de caja.',
            style: VntlText.body.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: VntlSpacing.xl),
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

  Widget _buildReporte(BuildContext context) {
    final colors = context.colors;
    final ctrl = context.watch<SesionCajaController>();
    final corte = ctrl.corteX;

    if (corte == null) {
      return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
              Text('Efectivo esperado en caja',
                  style: VntlText.label.copyWith(color: colors.textSecondary)),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ventas canceladas', style: VntlText.h4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: VntlSpacing.sm, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.error.withValues(alpha: 0.12),
                  borderRadius: VntlRadius.smBorderRadius,
                ),
                child: Text(
                  '${corte.ventasCanceladas.length}',
                  style: VntlText.label.copyWith(color: colors.error),
                ),
              ),
            ],
          ),
          const SizedBox(height: VntlSpacing.sm),
          ...corte.ventasCanceladas.map((v) => Padding(
                padding: const EdgeInsets.only(bottom: VntlSpacing.sm),
                child: _VentaCanceladaCorteTile(venta: v),
              )),
        ],
        const SizedBox(height: VntlSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: VntlButton(
            label: 'Descargar / Imprimir corte',
            icon: Icons.print_rounded,
            onPressed: () => _abrirPdf(corte.corteId),
          ),
        ),
      ],
    );
  }

  Future<void> _abrirPdf(int? corteId) async {
    if (corteId == null) return;

    try {
      final ctrl = context.read<SesionCajaController>();
      await ctrl.abrirCortePdf(corteId);
    } catch (e, stackTrace) {
      debugPrint('Error al abrir PDF: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir el PDF:\n$e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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

// ─── Ítem de venta cancelada del Corte X (distingue total vs. parcial) ────────
class _VentaCanceladaCorteTile extends StatelessWidget {
  final VentaCanceladaResumenModel venta;

  const _VentaCanceladaCorteTile({required this.venta});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dev = venta.devolucion;

    if (venta.esCancelacionTotal || dev == null) {
      return Container(
        padding: const EdgeInsets.all(VntlSpacing.md),
        decoration: BoxDecoration(
          color: colors.surfaceSecondary,
          borderRadius: VntlRadius.smBorderRadius,
          border: Border.all(color: colors.error.withValues(alpha: 0.2), width: 0.5),
        ),
        child: Row(
          children: [
            Icon(Icons.cancel_rounded, size: 16, color: colors.error),
            const SizedBox(width: VntlSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ticket #${venta.numeroTicket}',
                    style: VntlText.label.copyWith(
                      color: colors.error,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  if (dev != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Devuelto: \$${dev.montoDevuelto.toStringAsFixed(2)} en ${dev.metodo}',
                      style: VntlText.caption.copyWith(color: colors.textTertiary),
                    ),
                    if (dev.motivo != null)
                      Text(
                        'Motivo: ${dev.motivo!}',
                        style: VntlText.caption.copyWith(color: colors.textTertiary),
                      ),
                  ],
                ],
              ),
            ),
            Text(
              '\$${venta.total.toStringAsFixed(2)}',
              style: VntlText.label.copyWith(
                color: colors.error,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ],
        ),
      );
    }

    // Cancelación parcial: se desglosa vendido / devuelto / conservado.
    return Container(
      padding: const EdgeInsets.all(VntlSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: VntlRadius.smBorderRadius,
        border: Border.all(color: colors.warning.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.undo_rounded, size: 16, color: colors.warning),
              const SizedBox(width: VntlSpacing.sm),
              Expanded(
                child: Text(
                  'Ticket #${venta.numeroTicket}',
                  style: VntlText.label.copyWith(color: colors.warning),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: VntlSpacing.xs, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.warning.withValues(alpha: 0.12),
                  borderRadius: VntlRadius.smBorderRadius,
                ),
                child: Text(
                  'Devolución parcial',
                  style: VntlText.caption.copyWith(color: colors.warning),
                ),
              ),
            ],
          ),
          const SizedBox(height: VntlSpacing.sm),
          _filaMonto(context, 'Vendido', venta.total, colors.textSecondary),
          _filaMonto(context, 'Devuelto en ${dev.metodo}', -dev.montoDevuelto, colors.error),
          Divider(color: colors.border, height: VntlSpacing.md),
          _filaMonto(context, 'Conservado como venta', venta.montoConservado, colors.success,
              destacado: true),
          if (dev.motivo != null) ...[
            const SizedBox(height: VntlSpacing.xs),
            Text(
              'Motivo: ${dev.motivo!}',
              style: VntlText.caption.copyWith(color: colors.textTertiary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _filaMonto(BuildContext context, String label, double valor, Color color,
      {bool destacado = false}) {
    final colors = context.colors;
    final prefijo = valor < 0 ? '- ' : '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: VntlText.caption.copyWith(color: colors.textTertiary)),
          Text(
            '$prefijo\$${valor.abs().toStringAsFixed(2)}',
            style: (destacado ? VntlText.label : VntlText.caption).copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
