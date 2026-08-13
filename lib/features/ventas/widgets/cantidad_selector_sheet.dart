import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/products/models/producto_model.dart';
import 'package:ventro_app/features/products/models/producto_variante_model.dart';
import 'package:ventro_app/features/ventas/controllers/venta_controller.dart';

class CantidadSelectorSheet extends StatefulWidget {
  final ProductoVarianteModel variante;
  final ProductoModel producto;

  const CantidadSelectorSheet({
    super.key,
    required this.variante,
    required this.producto,
  });

  @override
  State<CantidadSelectorSheet> createState() => _CantidadSelectorSheetState();
}

class _CantidadSelectorSheetState extends State<CantidadSelectorSheet> {
  int _cantidad = 1;

  /// Cuánto más se puede agregar desde aquí, considerando lo que ya está
  /// en el carrito. Si la variante tiene allow_out_of_stock=true, no hay
  /// límite (se permite vender sin importar el stock real); si es false,
  /// el límite es siempre el stock disponible.
  int _limiteDisponible(VentaController ctrl) {
    if (widget.variante.allowOutOfStock) {
      return 999999; // sin restricción real cuando se permite vender sin stock
    }
    final stock = ctrl.stockDisponible(widget.variante.id);
    final yaEnCarrito = ctrl.cantidadEnCarrito(widget.variante.id);
    final restante = stock - yaEnCarrito;
    return restante < 0 ? 0 : restante.toInt();
  }

  void _incrementar(int limite) {
    if (_cantidad >= limite) return;
    setState(() => _cantidad++);
  }

  void _decrementar() {
    if (_cantidad > 1) setState(() => _cantidad--);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ctrl = context.watch<VentaController>();
    final limite = _limiteDisponible(ctrl);
    final subtotal = widget.variante.precioFinal * _cantidad;
    final alLimite = _cantidad >= limite;

    final categoriaColor = VntlCategoryStyle.forCategoria(
      context,
      widget.producto.categoriaId,
      iconoKey: widget.producto.categoria?.icono,
      colorHex: widget.producto.categoria?.color,
    ).foreground;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.variante.nombre,
          style: VntlText.h4,
        ),
        const SizedBox(height: VntlSpacing.xs),
        Text(
          widget.producto.nombre,
          style: VntlText.bodySmall.copyWith(color: categoriaColor),
        ),
        const SizedBox(height: VntlSpacing.xs),
        Text(
          '\$${widget.variante.precioFinal.toStringAsFixed(2)} c/u',
          style: VntlText.body.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: VntlSpacing.sm),
        Row(
          children: [
            Icon(Icons.inventory_2_outlined, size: 14, color: colors.textTertiary),
            const SizedBox(width: VntlSpacing.xs),
            Text(
              'Disponibles: $limite',
              style: VntlText.caption.copyWith(color: colors.textTertiary),
            ),
          ],
        ),
        const SizedBox(height: VntlSpacing.xl),
        Center(
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StepperButton(icon: Icons.remove_rounded, onTap: _decrementar),
                  SizedBox(
                    width: 64,
                    child: Text(
                      '$_cantidad',
                      textAlign: TextAlign.center,
                      style: VntlText.h2,
                    ),
                  ),
                  _StepperButton(
                    icon: Icons.add_rounded,
                    onTap: () => _incrementar(limite),
                    disabled: alLimite,
                  ),
                ],
              ),
              if (alLimite) ...[
                const SizedBox(height: VntlSpacing.xs),
                Text(
                  'Llegaste al máximo disponible',
                  style: VntlText.caption.copyWith(color: colors.warning),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: VntlSpacing.xl),
        Container(
          padding: const EdgeInsets.all(VntlSpacing.md),
          decoration: BoxDecoration(
            color: colors.surfaceSecondary,
            borderRadius: VntlRadius.smBorderRadius,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: VntlText.label.copyWith(color: colors.textSecondary)),
              Text('\$${subtotal.toStringAsFixed(2)}', style: VntlText.h4),
            ],
          ),
        ),
        const SizedBox(height: VntlSpacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            VntlButton(
              label: 'Cancelar',
              variant: VntlButtonVariant.ghost,
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: VntlSpacing.sm),
            VntlButton(
              label: 'Agregar',
              icon: Icons.add_shopping_cart_rounded,
              onPressed: limite <= 0 ? null : () => Navigator.pop(context, _cantidad),
            ),
          ],
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool disabled;

  const _StepperButton({
    required this.icon,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: disabled ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: disabled ? colors.surfaceSecondary : colors.primarySurface,
          borderRadius: VntlRadius.mdBorderRadius,
        ),
        child: Icon(icon, color: disabled ? colors.textTertiary : colors.primary, size: 20),
      ),
    );
  }
}
