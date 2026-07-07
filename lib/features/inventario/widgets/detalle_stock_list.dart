import 'package:flutter/material.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/inventario/models/inventario_stock_model.dart';

class DetalleStockList extends StatelessWidget {
  const DetalleStockList({super.key, required this.items});

  final List<InventarioStockModel> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(VntlSpacing.xl),
        child: Center(
          child: Text(
            'No hay productos en esta categoría',
            style: VntlText.body.copyWith(color: colors.textTertiary),
          ),
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 420, minWidth: 360),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: items.length,
        separatorBuilder: (_, __) => Divider(color: colors.border, height: 0.5),
        itemBuilder: (context, index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: VntlSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.productoNombre, style: VntlText.label),
                      if (item.varianteNombre.isNotEmpty &&
                          item.varianteNombre != item.productoNombre) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.varianteNombre,
                          style: VntlText.caption.copyWith(color: colors.textTertiary),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  item.cantidad % 1 == 0
                      ? item.cantidad.toInt().toString()
                      : item.cantidad.toString(),
                  style: VntlText.label.copyWith(
                    color: item.cantidad <= 0 ? colors.error : colors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
