import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/auth/controllers/auth_controller.dart';
import 'package:ventro_app/features/auth/models/user_model.dart';
import 'package:ventro_app/features/ventas/controllers/venta_controller.dart';
import 'package:ventro_app/features/ventas/models/venta_detalle_model.dart';
import 'package:ventro_app/design_system/helpers/vntl_payment_style.dart';
import 'package:ventro_app/features/ventas/screens/cancelar_venta_sheet.dart';

class VentaDetalleScreen extends StatefulWidget {
  final int ventaId;
  const VentaDetalleScreen({super.key, required this.ventaId});

  @override
  State<VentaDetalleScreen> createState() => _VentaDetalleScreenState();
}

class _VentaDetalleScreenState extends State<VentaDetalleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VentaController>().cargarDetalle(widget.ventaId);
    });
  }

  Future<void> _confirmarCancelacion(BuildContext context) async {
    final venta = context.read<VentaController>().ventaDetalle;
    if (venta == null) return;

    final ok = await VntlModal.show<bool>(
      context,
      title: 'Cancelar Venta ${venta.numeroTicketCompleto}',
      subtitle: 'Esta acción no se puede deshacer',
      width: 520,
      content: CancelarVentaSheet(venta: venta),
    );

    if (ok == true && mounted) {
      VntlToast.show(
        context,
        message: 'Venta cancelada correctamente',
        type: VntlToastType.success,
      );
      // Recargar detalle para reflejar el nuevo estado
      await context.read<VentaController>().cargarDetalle(venta.id);
      // Refrescar lista de ventas de la sesión
      await context.read<VentaController>().cargarVentasDeLaSesion();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ctrl = context.watch<VentaController>();
    final esAdmin = context.watch<AuthController>().user?.role.isAdmin ?? false;

    if (ctrl.cargandoDetalle) {
      return Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(backgroundColor: colors.background),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final venta = ctrl.ventaDetalle;
    if (venta == null) {
      return Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(backgroundColor: colors.background),
        body: const Center(child: Text('No se pudo cargar la venta.')),
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        title: Text('Ticket ${venta.numeroTicketCompleto}', style: VntlText.h4),
        actions: [
          if (venta.estado == 'cancelada')
            Tooltip(
              message: 'Ver comprobante de cancelación',
              child: Padding(
                padding: const EdgeInsets.only(right: VntlSpacing.sm),
                child: VntlButton(
                  label: 'Comprobante de cancelación',
                  icon: Icons.receipt_long_rounded,
                  size: VntlButtonSize.sm,
                  variant: VntlButtonVariant.danger,
                  onPressed: () =>
                      context.read<VentaController>().imprimirTicketCancelacion(venta.id),
                ),
              ),
            )
          else ...[
            Tooltip(
              message: esAdmin ? 'Cancelar venta' : 'Solo un administrador puede cancelar',
              child: Padding(
                padding: const EdgeInsets.only(right: VntlSpacing.sm),
                child: VntlButton(
                  label: 'Cancelar venta',
                  icon: Icons.cancel_rounded,
                  size: VntlButtonSize.sm,
                  variant: VntlButtonVariant.danger,
                  onPressed: esAdmin ? () => _confirmarCancelacion(context) : null,
                ),
              ),
            ),
            Tooltip(
              message: esAdmin ? 'Reimprimir ticket' : 'Solo un administrador puede reimprimir',
              child: Padding(
                padding: const EdgeInsets.only(right: VntlSpacing.sm),
                child: VntlButton(
                  label: 'Reimprimir',
                  icon: Icons.print_rounded,
                  size: VntlButtonSize.sm,
                  variant: VntlButtonVariant.secondary,
                  onPressed: esAdmin
                      ? () => context.read<VentaController>().reimprimirTicket(venta.id)
                      : null,
                ),
              ),
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(VntlSpacing.xl),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Header info ───────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(VntlSpacing.lg),
                  decoration: BoxDecoration(
                    color: colors.glassSurface,
                    borderRadius: VntlRadius.lgBorderRadius,
                    border: Border.all(color: colors.border, width: 0.5),
                  ),
                  child: Column(
                    children: [
                      _FilaInfo(label: 'Fecha', valor: venta.fecha),
                      _FilaInfo(label: 'Cajero', valor: venta.cajero),
                      _FilaInfo(label: 'Caja', valor: venta.caja),
                      _FilaInfo(label: 'Sucursal', valor: venta.sucursal),
                      _FilaInfo(
                        label: 'Estado',
                        valor: venta.estado,
                        color: venta.estado == 'completada' ? colors.success : colors.error,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: VntlSpacing.xl),

                // ─── Items ────────────────────────────────────────────────
                Text('Productos', style: VntlText.h4),
                const SizedBox(height: VntlSpacing.md),
                Container(
                  decoration: BoxDecoration(
                    color: colors.glassSurface,
                    borderRadius: VntlRadius.lgBorderRadius,
                    border: Border.all(color: colors.border, width: 0.5),
                  ),
                  child: VntlTable<VentaDetalleItemModel>(
                    isLoading: false,
                    items: venta.items,
                    emptyLabel: 'Sin productos',
                    columns: [
                      VntlTableColumn(
                        label: 'Producto',
                        flex: 4,
                        cellBuilder: (i) => Text(i.nombreSnapshot, style: VntlText.body),
                      ),
                      VntlTableColumn(
                        label: 'Cant.',
                        flex: 1,
                        cellBuilder: (i) => Text('${i.cantidad}',
                            style: VntlText.body.copyWith(color: colors.textSecondary)),
                      ),
                      VntlTableColumn(
                        label: 'Precio',
                        flex: 2,
                        cellBuilder: (i) => Text(
                          '\$${i.precioUnitario.toStringAsFixed(2)}',
                          style: VntlText.body.copyWith(color: colors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: VntlSpacing.xl),

                // ─── Totales ──────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(VntlSpacing.lg),
                  decoration: BoxDecoration(
                    color: colors.glassSurface,
                    borderRadius: VntlRadius.lgBorderRadius,
                    border: Border.all(color: colors.border, width: 0.5),
                  ),
                  child: Column(
                    children: [
                      _FilaInfo(label: 'Subtotal', valor: '\$${venta.subtotal.toStringAsFixed(2)}'),
                      if (venta.descuento > 0)
                        _FilaInfo(
                            label: 'Descuento', valor: '-\$${venta.descuento.toStringAsFixed(2)}'),
                      if (venta.descuento > 0)
                        _FilaInfo(
                            label: 'Base gravable',
                            valor: '\$${venta.baseGravable.toStringAsFixed(2)}'),
                      if (venta.ivaTotal > 0)
                        _FilaInfo(label: 'IVA', valor: '\$${venta.ivaTotal.toStringAsFixed(2)}'),
                      if (venta.iepsTotal > 0)
                        _FilaInfo(label: 'IEPS', valor: '\$${venta.iepsTotal.toStringAsFixed(2)}'),
                      Divider(color: colors.border, height: VntlSpacing.lg),
                      _FilaInfo(
                        label: 'Total',
                        valor: '\$${venta.total.toStringAsFixed(2)}',
                        bold: true,
                        color: colors.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: VntlSpacing.xl),

                // ─── Pagos ────────────────────────────────────────────────
                Text('Pagos', style: VntlText.h4),
                const SizedBox(height: VntlSpacing.md),
                ...venta.pagos.map((p) {
                  final style = VntlPaymentStyle.forMetodo(
                    context,
                    p.id,
                    iconoKey: p.icono,
                    colorHex: p.color,
                  );
                  return Padding(
                    padding: const EdgeInsets.only(bottom: VntlSpacing.sm),
                    child: Container(
                      padding: const EdgeInsets.all(VntlSpacing.md),
                      decoration: BoxDecoration(
                        color: colors.glassSurface,
                        borderRadius: VntlRadius.mdBorderRadius,
                        border: Border.all(color: style.foreground, width: 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: style.background,
                              borderRadius: VntlRadius.smBorderRadius,
                            ),
                            child: Icon(style.icon, size: 16, color: style.foreground),
                          ),
                          const SizedBox(width: VntlSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.metodo, style: VntlText.label),
                                if (p.referencia != null)
                                  Text('Ref: ${p.referencia}',
                                      style: VntlText.caption.copyWith(color: colors.textTertiary)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('\$${p.monto.toStringAsFixed(2)}',
                                  style: VntlText.label.copyWith(color: style.foreground)),
                              if (p.recibido != null)
                                Text(
                                  'Recibido: \$${p.recibido!.toStringAsFixed(2)} · Cambio: \$${(p.cambio ?? 0).toStringAsFixed(2)}',
                                  style: VntlText.caption.copyWith(color: colors.textTertiary),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilaInfo extends StatelessWidget {
  final String label;
  final String valor;
  final bool bold;
  final Color? color;

  const _FilaInfo({
    required this.label,
    required this.valor,
    this.bold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: VntlText.caption.copyWith(color: colors.textSecondary)),
          Text(
            valor,
            style: bold
                ? VntlText.h4.copyWith(color: color ?? colors.textPrimary)
                : VntlText.label.copyWith(color: color ?? colors.textPrimary),
          ),
        ],
      ),
    );
  }
}
