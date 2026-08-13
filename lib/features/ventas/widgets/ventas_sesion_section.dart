import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/auth/controllers/auth_controller.dart';
import 'package:ventro_app/features/auth/models/user_model.dart';
import 'package:ventro_app/features/ventas/controllers/venta_controller.dart';
import 'package:ventro_app/features/ventas/models/venta_dia_model.dart';
import 'package:ventro_app/features/ventas/screens/venta_detalle_screen.dart';

class VentasSesionSection extends StatelessWidget {
  const VentasSesionSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ctrl = context.watch<VentaController>();

    if (ctrl.cargandoVentasDeLaSesion) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: VntlSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (ctrl.ventasDeLaSesion.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: VntlSpacing.xl),
        Divider(color: colors.border, height: 0.5),
        const SizedBox(height: VntlSpacing.xl),
        Text('Ventas de la sesión', style: VntlText.h4),
        const SizedBox(height: VntlSpacing.lg),
        ...ctrl.ventasDeLaSesion.map((caja) => Padding(
              padding: const EdgeInsets.only(bottom: VntlSpacing.lg),
              child: _CajaVentasSesionCard(caja: caja),
            )),
      ],
    );
  }
}

class _CajaVentasSesionCard extends StatelessWidget {
  final CajaVentasSesionModel caja;
  const _CajaVentasSesionCard({required this.caja});

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
                    Text('Total de la sesión',
                        style: VntlText.caption.copyWith(color: colors.textTertiary)),
                    Text(
                      '\$${caja.totalSesion.toStringAsFixed(2)}',
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
              emptyLabel: 'Sin ventas en esta sesión.',
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
                  label: 'Estatus',
                  flex: 2,
                  sortValue: (v) => v.estado,
                  cellBuilder: (v) => Text(
                    v.estado.toUpperCase(),
                    style: VntlText.body.copyWith(
                      color: v.estado == 'cancelada' ? colors.error : colors.success,
                      fontWeight: FontWeight.w600,
                    ),
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
                  label: 'Cliente',
                  flex: 2,
                  sortValue: (v) => v.cliente,
                  cellBuilder: (v) => Text(
                    v.cliente,
                    style: VntlText.body.copyWith(color: colors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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
                  cellBuilder: (v) {
                    final user = context.watch<AuthController>().user;
                    final esAdmin = user?.role.isAdmin ?? false;

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Tooltip(
                          message: esAdmin
                              ? 'Reimprimir ticket'
                              : 'Solo un administrador puede reimprimir',
                          child: VntlButton(
                            label: null,
                            variant: VntlButtonVariant.primary,
                            size: VntlButtonSize.sm,
                            icon: Icons.print_rounded,
                            onPressed: esAdmin
                                ? () => context.read<VentaController>().reimprimirTicket(v.id)
                                : null,
                          ),
                        ),
                        const SizedBox(width: VntlSpacing.sm),
                        VntlButton(
                          label: null,
                          variant: VntlButtonVariant.secondary,
                          size: VntlButtonSize.sm,
                          icon: Icons.visibility_rounded,
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VentaDetalleScreen(ventaId: v.id),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
