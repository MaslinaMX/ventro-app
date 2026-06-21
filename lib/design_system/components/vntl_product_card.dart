// lib/design_system/components/vntl_product_card.dart

import 'package:flutter/material.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/design_system/helpers/vntl_category_style.dart';
import 'package:ventro_app/features/products/models/producto_model.dart';

/// Card de producto compartida entre el panel de administración, el POS
/// y el catálogo de tienda en línea. El comportamiento (qué pasa al tocar
/// la card) lo decide quien la usa, vía [onTap].
class VntlProductCard extends StatelessWidget {
  const VntlProductCard({
    super.key,
    required this.producto,
    this.onTap,
    this.imagenUrl,
    this.mostrarVariantesBadge = true,
    this.precioDesde = false,
  });

  final ProductoModel producto;
  final VoidCallback? onTap;

  /// URL de imagen a mostrar en vez del ícono de categoría. Si es null,
  /// se usa el ícono automático según categoría.
  final String? imagenUrl;

  /// Si debe mostrar "N variantes" cuando el producto tiene más de una.
  final bool mostrarVariantesBadge;

  /// Si el precio debe mostrarse como "Desde $X" (catálogo) en vez del
  /// precio plano de la primera variante (usado en admin).
  final bool precioDesde;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = VntlCategoryStyle.forCategoria(context, producto.categoriaId);
    final tieneVariantes = producto.tieneMultiplesVariantes;

    final precio = precioDesde
        ? producto.precioDesde
        : (producto.variantes.isEmpty ? null : producto.variantes.first.precioFinal);

    return Material(
      color: Colors.transparent,
      borderRadius: VntlRadius.lgBorderRadius,
      child: InkWell(
        borderRadius: VntlRadius.lgBorderRadius,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(VntlSpacing.lg),
          decoration: BoxDecoration(
            color: colors.glassSurface,
            borderRadius: VntlRadius.lgBorderRadius,
            border: Border.all(color: colors.border, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: VntlRadius.mdBorderRadius,
                child: Container(
                  width: 44,
                  height: 44,
                  color: style.background,
                  child: imagenUrl != null
                      ? Image.network(
                          imagenUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Icon(style.icon, color: style.foreground, size: 22),
                        )
                      : Icon(style.icon, color: style.foreground, size: 22),
                ),
              ),
              const SizedBox(height: VntlSpacing.md),
              Text(
                producto.nombre,
                style: VntlText.label.copyWith(color: colors.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: VntlSpacing.xs),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: VntlSpacing.sm, vertical: 2),
                    decoration: BoxDecoration(
                      color: style.background,
                      borderRadius: VntlRadius.smBorderRadius,
                    ),
                    child: Text(
                      producto.categoria?.nombre ?? 'Sin categoría',
                      style: VntlText.caption
                          .copyWith(color: style.foreground, fontWeight: FontWeight.w500),
                    ),
                  ),
                  if (mostrarVariantesBadge && tieneVariantes) ...[
                    const SizedBox(width: VntlSpacing.sm),
                    Text(
                      '${producto.variantes.length} variantes',
                      style: VntlText.caption.copyWith(color: colors.textTertiary),
                    ),
                  ],
                ],
              ),
              const Spacer(),
              const SizedBox(height: VntlSpacing.sm),
              Text(
                precio != null
                    ? '${precioDesde ? "Desde " : ""}\$${precio.toStringAsFixed(2)}'
                    : '—',
                style: VntlText.h4.copyWith(color: colors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
