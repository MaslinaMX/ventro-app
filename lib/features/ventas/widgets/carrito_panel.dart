import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/ventas/controllers/venta_controller.dart';
import 'package:ventro_app/features/ventas/models/carrito_item_model.dart';
import 'package:ventro_app/design_system/helpers/vntl_category_style.dart';
import 'package:ventro_app/features/ventas/widgets/cobro_sheet.dart';
import 'package:ventro_app/features/ventas/widgets/descuento_sheet.dart';

class CarritoPanel extends StatelessWidget {
  final ScrollController? scrollController;
  final bool isFullWidth;

  const CarritoPanel({
    super.key,
    this.scrollController,
    this.isFullWidth = false,
  });

  Future<void> _abrirCobro(BuildContext context) async {
    final venta = await VntlModal.show<Map<String, dynamic>>(
      context,
      title: 'Cobrar',
      width: 420,
      content: const CobroSheet(),
    );
    if (venta != null && context.mounted) {
      VntlToast.show(context, message: 'Venta registrada con éxito', type: VntlToastType.success);
    }
  }

  Future<void> _abrirDescuento(BuildContext context) async {
    await VntlModal.show(
      context,
      title: 'Descuento',
      width: 380,
      content: const DescuentoSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ctrl = context.watch<VentaController>();

    return Container(
      width: isFullWidth ? double.infinity : 360,
      decoration: BoxDecoration(
        color: colors.surface,
        border: isFullWidth ? null : Border(left: BorderSide(color: colors.border, width: 0.5)),
      ),
      child: Column(
        children: [
          if (isFullWidth) ...[
            const SizedBox(height: VntlSpacing.sm),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: VntlRadius.smBorderRadius,
                ),
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.all(VntlSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Carrito', style: VntlText.h4),
                if (ctrl.carrito.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => _abrirDescuento(context),
                        child: Text(
                          'Descuento',
                          style: VntlText.caption.copyWith(color: colors.info),
                        ),
                      ),
                      const SizedBox(width: VntlSpacing.md),
                      GestureDetector(
                        onTap: ctrl.vaciarCarrito,
                        child: Text(
                          'Vaciar',
                          style: VntlText.caption.copyWith(color: colors.error),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Divider(color: colors.border, height: 0.5),
          Expanded(
            child: ctrl.carrito.isEmpty
                ? _CarritoVacio()
                : RepaintBoundary(
                      key: ValueKey('carrito-${ctrl.carrito.length}-${ctrl.totalCarrito}'),
                      child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.all(VntlSpacing.md),
                    itemCount: ctrl.carrito.length,
                    separatorBuilder: (_, __) => const SizedBox(height: VntlSpacing.sm),
                    itemBuilder: (context, index) {
                      final item = ctrl.carrito[index];
                      return _CarritoItemTile(item: item);
                    },
                  ),
          )
          ),
          if (ctrl.carrito.isNotEmpty) ...[
            Divider(color: colors.border, height: 0.5),
            Padding(
              padding: const EdgeInsets.all(VntlSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (ctrl.descuentoActivo) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Subtotal',
                            style: VntlText.caption.copyWith(color: colors.textTertiary)),
                        Text(
                          '\$${ctrl.subtotalCarrito.toStringAsFixed(2)}',
                          style: VntlText.caption.copyWith(color: colors.textTertiary),
                        ),
                      ],
                    ),
                    const SizedBox(height: VntlSpacing.xs),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Descuento', style: VntlText.caption.copyWith(color: colors.info)),
                        Text(
                          '-\$${ctrl.descuentoMonto.toStringAsFixed(2)}',
                          style: VntlText.caption.copyWith(color: colors.info),
                        ),
                      ],
                    ),
                    const SizedBox(height: VntlSpacing.sm),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: VntlText.h4),
                      Text(
                        '\$${ctrl.totalCarrito.toStringAsFixed(2)}',
                        style: VntlText.h2.copyWith(color: colors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: VntlSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: VntlButton(
                      label: 'Cobrar',
                      icon: Icons.payments_rounded,
                      onPressed: () => _abrirCobro(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CarritoVacio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 40, color: colors.textTertiary),
          const SizedBox(height: VntlSpacing.md),
          Text(
            'Carrito vacío',
            style: VntlText.body.copyWith(color: colors.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _CarritoItemTile extends StatelessWidget {
  final CarritoItemModel item;
  const _CarritoItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ctrl = context.read<VentaController>();

    final categoriaColor = VntlCategoryStyle.forCategoria(
      context,
      item.productoPadre.categoriaId,
      iconoKey: item.productoPadre.categoria?.icono,
      colorHex: item.productoPadre.categoria?.color,
    ).foreground;

    return Container(
      padding: const EdgeInsets.all(VntlSpacing.sm),
      decoration: BoxDecoration(
        color: colors.glassSurface,
        borderRadius: VntlRadius.smBorderRadius,
        border: Border.all(color: colors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.variante.nombre,
                  style: VntlText.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item.productoPadre.nombre,
                  style: VntlText.caption.copyWith(color: categoriaColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: VntlSpacing.xs),
                Text(
                  '\$${item.variante.precioFinal.toStringAsFixed(2)} c/u',
                  style: VntlText.caption.copyWith(color: colors.textTertiary),
                ),
              ],
            ),
          ),
          const SizedBox(width: VntlSpacing.sm),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MiniStepperButton(
                icon: Icons.remove_rounded,
                onTap: () => ctrl.decrementar(item.variante.id),
              ),
              SizedBox(
                width: 28,
                child: Text(
                  '${item.cantidad}',
                  textAlign: TextAlign.center,
                  style: VntlText.label,
                ),
              ),
              _MiniStepperButton(
                icon: Icons.add_rounded,
                onTap: () => ctrl.incrementar(item.variante.id),
              ),
            ],
          ),
          const SizedBox(width: VntlSpacing.sm),
          SizedBox(
            width: 64,
            child: Text(
              '\$${item.subtotal.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: VntlText.label,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MiniStepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: colors.surfaceSecondary,
          borderRadius: VntlRadius.smBorderRadius,
        ),
        child: Icon(icon, size: 14, color: colors.textSecondary),
      ),
    );
  }
}
