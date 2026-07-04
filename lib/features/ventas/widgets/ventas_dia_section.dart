import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/ventas/controllers/venta_controller.dart';
import 'package:ventro_app/features/ventas/models/venta_dia_model.dart';

class VentasDiaSection extends StatelessWidget {
  const VentasDiaSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ctrl = context.watch<VentaController>();

    if (ctrl.cargandoVentasDelDia) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: VntlSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (ctrl.ventasDelDia.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: VntlSpacing.xl),
        Divider(color: colors.border, height: 0.5),
        const SizedBox(height: VntlSpacing.xl),
        Text('Ventas de hoy', style: VntlText.h4),
        const SizedBox(height: VntlSpacing.lg),
        ...ctrl.ventasDelDia.map((caja) => Padding(
              padding: const EdgeInsets.only(bottom: VntlSpacing.lg),
              child: _CajaVentasCard(caja: caja),
            )),
      ],
    );
  }
}

class _CajaVentasCard extends StatelessWidget {
  final CajaVentasDiaModel caja;
  const _CajaVentasCard({required this.caja});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.glassSurface,
        borderRadius: VntlRadius.lgBorderRadius,
        border: Border.all(color: colors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(VntlSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(caja.cajaNombre, style: VntlText.h4),
                    const SizedBox(height: VntlSpacing.xs),
                    Text(
                      'Abierta por ${caja.abiertaPor}',
                      style: VntlText.caption.copyWith(color: colors.textTertiary),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Total del día',
                        style: VntlText.caption.copyWith(color: colors.textTertiary)),
                    Text(
                      '\$${caja.totalDia.toStringAsFixed(2)}',
                      style: VntlText.h4.copyWith(color: colors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(VntlSpacing.lg, 0, VntlSpacing.lg, VntlSpacing.lg),
            child: VntlTable<VentaResumenModel>(
              isLoading: false,
              items: caja.ventas,
              emptyLabel: 'Sin ventas registradas hoy.',
              columns: [
                VntlTableColumn(
                  label: 'Ticket',
                  flex: 2,
                  sortValue: (v) => v.numeroTicketCompleto,
                  cellBuilder: (v) => Text(
                    v.numeroTicketCompleto,
                    style: VntlText.body.copyWith(color: colors.textSecondary),
                  ),
                ),
                VntlTableColumn(
                  label: 'Hora',
                  flex: 1,
                  sortValue: (v) => v.hora,
                  cellBuilder: (v) =>
                      Text(v.hora, style: VntlText.body.copyWith(color: colors.textSecondary)),
                ),
                VntlTableColumn(
                  label: 'Cajero',
                  flex: 2,
                  sortValue: (v) => v.cajero,
                  cellBuilder: (v) => Text(v.cajero, style: VntlText.body),
                ),
                VntlTableColumn(
                  label: 'Método',
                  flex: 2,
                  cellBuilder: (v) => Wrap(
                    spacing: VntlSpacing.xs,
                    runSpacing: 4,
                    children: v.metodosPago.map((m) {
                      final style = VntlPaymentStyle.forMetodo(
                        context,
                        m.id,
                        iconoKey: m.icono,
                        colorHex: m.color,
                      );
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: style.background,
                          borderRadius: VntlRadius.smBorderRadius,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(style.icon, size: 11, color: style.foreground),
                            const SizedBox(width: 4),
                            Text(
                              m.nombre,
                              style: VntlText.caption.copyWith(color: style.foreground),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                VntlTableColumn(
                  label: 'Total',
                  flex: 1,
                  sortValue: (v) => v.total,
                  cellBuilder: (v) => Text(
                    '\$${v.total.toStringAsFixed(2)}',
                    style: VntlText.label,
                  ),
                ),
                VntlTableColumn(
                  label: '',
                  flex: 2,
                  cellBuilder: (v) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      VntlButton(
                        label: null,
                        variant: VntlButtonVariant.primary,
                        size: VntlButtonSize.sm,
                        icon: Icons.print_rounded,
                        onPressed: () {
                          // TODO: reimprimir ticket
                        },
                      ),
                      const SizedBox(width: VntlSpacing.sm),
                      VntlButton(
                        label: null,
                        variant: VntlButtonVariant.secondary,
                        size: VntlButtonSize.sm,
                        icon: Icons.visibility_rounded,
                        onPressed: () {
                          // TODO: ver detalle de venta
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VentaRow extends StatelessWidget {
  final VentaResumenModel venta;
  const _VentaRow({required this.venta});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: VntlSpacing.lg, vertical: VntlSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(venta.hora, style: VntlText.caption.copyWith(color: colors.textTertiary)),
          ),
          Expanded(
            child: Text('#${venta.numeroTicketCompleto} · ${venta.cajero}', style: VntlText.label),
          ),
          Text(
            venta.metodosPago.join(', '),
            style: VntlText.caption.copyWith(color: colors.textTertiary),
          ),
          const SizedBox(width: VntlSpacing.md),
          SizedBox(
            width: 70,
            child: Text(
              '\$${venta.total.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: VntlText.label,
            ),
          ),
        ],
      ),
    );
  }
}
