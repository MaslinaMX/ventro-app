import 'package:flutter/material.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/inventario/models/movimiento_inventario_model.dart';

class MovimientoCard extends StatelessWidget {
  const MovimientoCard({super.key, required this.movimiento});

  final MovimientoInventarioModel movimiento;

  String _formatFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final hora = fecha.hour.toString().padLeft(2, '0');
    final min = fecha.minute.toString().padLeft(2, '0');
    return '$dia/$mes $hora:$min';
  }

  String _formatNum(double valor) {
    return valor % 1 == 0 ? valor.toInt().toString() : valor.toString();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final esEntrada = movimiento.type == MovimientoType.in_;

    return Container(
      margin: const EdgeInsets.only(bottom: VntlSpacing.sm),
      padding: const EdgeInsets.all(VntlSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: VntlRadius.lgBorderRadius,
        border: Border.all(color: colors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movimiento.productoNombre ?? '—',
                      style: VntlText.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (movimiento.varianteNombre != null &&
                        movimiento.varianteNombre!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        movimiento.varianteNombre!,
                        style: VntlText.caption.copyWith(color: colors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: VntlSpacing.sm),
              VntlBadge(
                label: esEntrada
                    ? '${movimiento.reason.label} +${_formatNum(movimiento.cantidad)}'
                    : '${movimiento.reason.label} -${_formatNum(movimiento.cantidad)}',
                variant: esEntrada ? VntlBadgeVariant.success : VntlBadgeVariant.error,
              ),
            ],
          ),
          const SizedBox(height: VntlSpacing.sm),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 12, color: colors.textTertiary),
              const SizedBox(width: 4),
              Text(
                _formatFecha(movimiento.createdAt),
                style: VntlText.caption.copyWith(color: colors.textTertiary),
              ),
              const SizedBox(width: VntlSpacing.md),
              Icon(Icons.storefront_rounded, size: 12, color: colors.textTertiary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  movimiento.sucursalNombre ?? '—',
                  style: VntlText.caption.copyWith(color: colors.textTertiary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
