import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/products/models/producto_model.dart';
import 'package:ventro_app/features/products/models/producto_variante_model.dart';
import 'package:ventro_app/features/ventas/controllers/venta_controller.dart';

class ProductoGridCard extends StatelessWidget {
  final ProductoVarianteModel variante;
  final ProductoModel producto;
  final VoidCallback onTap;

  const ProductoGridCard({
    super.key,
    required this.variante,
    required this.producto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final imagen = variante.imagenPrincipal;
    final ctrl = context.watch<VentaController>();
    final stock = ctrl.stockDisponible(variante.id);
    final agotado = stock <= 0;

    return GestureDetector(
      onTap: agotado ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.glassSurface,
          borderRadius: VntlRadius.lgBorderRadius,
          border: Border.all(color: colors.border, width: 0.5),
        ),
        child: Opacity(
          opacity: agotado ? 0.4 : 1.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Container(
                    width: double.infinity,
                    color: colors.surfaceSecondary,
                    child: imagen != null
                        ? Image.network(imagen.path, fit: BoxFit.cover)
                        : Icon(Icons.inventory_2_rounded, size: 32, color: colors.textTertiary),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(VntlSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.nombre,
                      style: VntlText.labelSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      variante.nombre,
                      style: VntlText.caption.copyWith(color: colors.textTertiary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: VntlSpacing.xs),
                    agotado
                        ? Text('Agotado', style: VntlText.label.copyWith(color: colors.error))
                        : Text(
                            '\$${variante.precioFinal.toStringAsFixed(2)}',
                            style: VntlText.label.copyWith(color: colors.primary),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
