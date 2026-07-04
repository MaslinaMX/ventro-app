import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/metodos_pago/controllers/metodo_pago_controller.dart';
import 'package:ventro_app/features/metodos_pago/models/metodo_pago_model.dart';
import 'package:ventro_app/features/ventas/controllers/venta_controller.dart';
import 'package:ventro_app/features/ventas/models/pago_form_model.dart';
import 'package:ventro_app/features/ventas/widgets/venta_confirmada_sheet.dart';

class CobroSheet extends StatefulWidget {
  const CobroSheet({super.key});

  @override
  State<CobroSheet> createState() => _CobroSheetState();
}

class _CobroSheetState extends State<CobroSheet> {
  bool _metodosLoaded = false;
  final List<PagoFormModel> _pagos = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_metodosLoaded) {
      _metodosLoaded = true;
      context.read<MetodoPagoController>().loadMetodosPago();
    }
  }

  @override
  void dispose() {
    for (final pago in _pagos) {
      pago.dispose();
    }
    super.dispose();
  }

  double get _total => context.read<VentaController>().totalCarrito;
  double get _totalPagado => _pagos.fold(0, (sum, p) => sum + p.monto);
  double get _saldoPendiente => (_total - _totalPagado).clamp(0, double.infinity);
  bool get _completo => _saldoPendiente <= 0.001 && _pagos.isNotEmpty;

  void _agregarMetodo(MetodoPagoModel metodo) {
    setState(() {
      final montoSugerido = _saldoPendiente > 0 ? _saldoPendiente : _total;
      _pagos.add(PagoFormModel(metodoPago: metodo, monto: montoSugerido));
    });
  }

  void _quitarPago(int index) {
    setState(() {
      _pagos[index].dispose();
      _pagos.removeAt(index);
    });
  }

  void _actualizarMonto(int index, double monto) {
    setState(() => _pagos[index].monto = monto);
  }

  /// Para Efectivo: el cliente puede entregar más de lo necesario.
  /// El monto que se manda al backend siempre queda topado al saldo
  /// disponible para este pago; el excedente es cambio, informativo.
  void _actualizarRecibido(int index, double recibido) {
    final pago = _pagos[index];
    final saldoSinEstePago = (_total - (_totalPagado - pago.monto)).clamp(0.0, double.infinity);
    final montoReal = recibido > saldoSinEstePago ? saldoSinEstePago : recibido;
    setState(() => pago.monto = montoReal.toDouble());
  }

  void _actualizarReferencia(int index, String referencia) {
    setState(() => _pagos[index].referencia = referencia);
  }

  Future<void> _confirmar() async {
    // Validar referencias requeridas antes de mandar al backend
    for (final pago in _pagos) {
      if (pago.metodoPago.requiereReferencia && pago.referencia.trim().isEmpty) {
        VntlToast.show(
          context,
          message: 'El método "${pago.metodoPago.nombre}" requiere una referencia.',
          type: VntlToastType.error,
        );
        return;
      }
    }

    final ctrl = context.read<VentaController>();
    final venta = await ctrl.cobrar(_pagos.map((p) => p.toPayload()).toList());

    if (!mounted) return;
    if (venta != null) {
      Navigator.pop(context); // cierra el modal de cobro
      final numeroTicket = venta['numero_ticket_completo']?.toString() ?? '';
      if (context.mounted) {
        await VntlModal.show(
          context,
          title: '',
          showClose: false,
          width: 380,
          content: VentaConfirmadaSheet(
            ventaId: venta['id'],
            numeroTicket: numeroTicket,
            total: double.parse(venta['total'].toString()),
          ),
        );
      }
    } else {
      VntlToast.show(
        context,
        message: ctrl.errorMessage ?? 'No se pudo completar la venta',
        type: VntlToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final metodosCtrl = context.watch<MetodoPagoController>();
    final ventaCtrl = context.watch<VentaController>();

    final metodosDisponibles = metodosCtrl.metodosPago
        .where((m) => m.activo)
        .where((m) => !_pagos.any((p) => p.metodoPago.id == m.id))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(VntlSpacing.md),
          decoration: BoxDecoration(
            color: colors.surfaceSecondary,
            borderRadius: VntlRadius.smBorderRadius,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total a pagar', style: VntlText.label.copyWith(color: colors.textSecondary)),
              Text('\$${_total.toStringAsFixed(2)}', style: VntlText.h3),
            ],
          ),
        ),
        const SizedBox(height: VntlSpacing.lg),
        if (_pagos.isNotEmpty) ...[
          ..._pagos.asMap().entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: VntlSpacing.sm),
                child: _PagoLineaCard(
                  pago: entry.value,
                  onMontoChanged: (v) => _actualizarMonto(entry.key, v),
                  onRecibidoChanged: (v) => _actualizarRecibido(entry.key, v),
                  onReferenciaChanged: (v) => _actualizarReferencia(entry.key, v),
                  onQuitar: () => _quitarPago(entry.key),
                ),
              )),
          const SizedBox(height: VntlSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Saldo pendiente', style: VntlText.body.copyWith(color: colors.textSecondary)),
              Text(
                '\$${_saldoPendiente.toStringAsFixed(2)}',
                style: VntlText.label.copyWith(
                  color: _saldoPendiente > 0 ? colors.warning : colors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: VntlSpacing.lg),
        ],
        if (_saldoPendiente > 0 || _pagos.isEmpty) ...[
          Text(
            _pagos.isEmpty ? 'Selecciona método de pago' : 'Agregar otro método',
            style: VntlText.label.copyWith(color: colors.textTertiary),
          ),
          const SizedBox(height: VntlSpacing.sm),
          Wrap(
            spacing: VntlSpacing.sm,
            runSpacing: VntlSpacing.sm,
            children: metodosDisponibles.map((m) {
              final style =
                  VntlPaymentStyle.forMetodo(context, m.id, iconoKey: m.icono, colorHex: m.color);
              return GestureDetector(
                onTap: () => _agregarMetodo(m),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: VntlSpacing.md, vertical: VntlSpacing.sm),
                  decoration: BoxDecoration(
                    color: colors.glassSurface,
                    borderRadius: VntlRadius.mdBorderRadius,
                    border: Border.all(color: colors.border, width: 0.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(style.icon, size: 16, color: style.foreground),
                      const SizedBox(width: VntlSpacing.sm),
                      Text(m.nombre, style: VntlText.label),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: VntlSpacing.xl),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            VntlButton(
              label: 'Cancelar',
              variant: VntlButtonVariant.ghost,
              onPressed: ventaCtrl.cobrando ? null : () => Navigator.pop(context),
            ),
            const SizedBox(width: VntlSpacing.sm),
            VntlButton(
              label: ventaCtrl.cobrando ? 'Procesando...' : 'Confirmar venta',
              icon: Icons.check_circle_rounded,
              loading: ventaCtrl.cobrando,
              onPressed: (!_completo || ventaCtrl.cobrando) ? null : _confirmar,
            ),
          ],
        ),
      ],
    );
  }
}

class _PagoLineaCard extends StatelessWidget {
  final PagoFormModel pago;
  final ValueChanged<double> onMontoChanged;
  final ValueChanged<String> onReferenciaChanged;
  final VoidCallback onQuitar;
  final ValueChanged<double> onRecibidoChanged;

  const _PagoLineaCard({
    required this.pago,
    required this.onMontoChanged,
    required this.onRecibidoChanged,
    required this.onReferenciaChanged,
    required this.onQuitar,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = VntlPaymentStyle.forMetodo(
      context,
      pago.metodoPago.id,
      iconoKey: pago.metodoPago.icono,
      colorHex: pago.metodoPago.color,
    );

    final cambio = pago.esEfectivo
        ? (double.tryParse(pago.recibidoCtrl.text) ?? pago.monto) - pago.monto
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(VntlSpacing.md),
      decoration: BoxDecoration(
        color: colors.glassSurface,
        borderRadius: VntlRadius.smBorderRadius,
        border: Border.all(color: colors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(style.icon, size: 16, color: style.foreground),
              const SizedBox(width: VntlSpacing.sm),
              Expanded(child: Text(pago.metodoPago.nombre, style: VntlText.label)),
              GestureDetector(
                onTap: onQuitar,
                child: Icon(Icons.close_rounded, size: 16, color: colors.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: VntlSpacing.sm),
          if (pago.esEfectivo) ...[
            VntlInput(
              label: 'Recibido',
              hint: '0.00',
              controller: pago.recibidoCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) => onRecibidoChanged(double.tryParse(v) ?? 0),
            ),
            const SizedBox(height: VntlSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Aplicado a la venta',
                  style: VntlText.caption.copyWith(color: colors.textTertiary),
                ),
                Text(
                  '\$${pago.monto.toStringAsFixed(2)}',
                  style: VntlText.caption.copyWith(color: colors.textTertiary),
                ),
              ],
            ),
            if (cambio > 0.001) ...[
              const SizedBox(height: VntlSpacing.xs),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Cambio', style: VntlText.label.copyWith(color: colors.success)),
                  Text(
                    '\$${cambio.toStringAsFixed(2)}',
                    style: VntlText.h4.copyWith(color: colors.success),
                  ),
                ],
              ),
            ],
          ] else
            VntlInput(
              label: 'Monto',
              hint: '0.00',
              controller: pago.montoCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) => onMontoChanged(double.tryParse(v) ?? 0),
            ),
          if (pago.metodoPago.requiereReferencia) ...[
            const SizedBox(height: VntlSpacing.sm),
            VntlInput(
              label: 'Referencia / Folio',
              hint: 'Número de autorización',
              controller: pago.referenciaCtrl,
              onChanged: onReferenciaChanged,
            ),
          ],
        ],
      ),
    );
  }
}
