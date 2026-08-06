// V4

import 'package:flutter/material.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/products/models/producto_model.dart';
import 'package:ventro_app/features/products/models/producto_variante_model.dart';

/// Card de producto para el catálogo público — imagen cuadrada con
/// bordes redondeados, nombre, y variante debajo. Simple y proporcional,
/// sin precio ni carrito (aquí no se vende, solo se muestra). El tap
/// abre un modal con más información (vendrá en un paso siguiente).
class ProductoPublicoCard extends StatelessWidget {
  final ProductoVarianteModel variante;
  final ProductoModel producto;
  final VoidCallback onTap;

  const ProductoPublicoCard({
    super.key,
    required this.variante,
    required this.producto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final imagen = variante.imagenPrincipal;

    return GestureDetector(
      onTap: onTap,
      child: VntlCard(
        variant: VntlCardVariant.glass,
        padding: const EdgeInsets.fromLTRB(
            VntlSpacing.md, VntlSpacing.md, VntlSpacing.md, VntlSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: VntlRadius.mdBorderRadius,
              child: AspectRatio(
                aspectRatio: 1.1,
                child: imagen != null
                    ? Image.network(
                        imagen.path,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : Container(
                        color: colors.surfaceSecondary,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.inventory_2_rounded,
                          size: 36,
                          color: colors.textTertiary,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: VntlSpacing.sm),
            Text(
              producto.nombre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: VntlText.bodySmall.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (variante.nombre.trim().isNotEmpty) ...[
              const SizedBox(height: VntlSpacing.xs),
              Text(
                variante.nombre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: VntlText.labelSmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
