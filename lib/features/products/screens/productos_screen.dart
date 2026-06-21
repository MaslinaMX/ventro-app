import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/products/controllers/producto_controller.dart';
import 'package:ventro_app/features/products/models/producto_model.dart';
import 'package:ventro_app/features/products/models/producto_variante_model.dart';
import 'package:ventro_app/features/products/screens/productos_form_screen.dart';
import 'package:ventro_app/features/products/widgets/variante_editor_modal.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  bool _loaded = false;
  int? _productoExpandidoId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      context.read<ProductoController>().cargarProductos();
      context.read<ProductoController>().cargarCategorias();
    }
  }

  void _abrirFormulario({ProductoModel? producto}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductoFormScreen(productoExistente: producto)),
    );
  }

  void _toggleExpandido(int productoId) {
    setState(() {
      _productoExpandidoId = _productoExpandidoId == productoId ? null : productoId;
    });
  }

  Future<void> _editarVarianteDesdeListado(
      ProductoModel producto, ProductoVarianteModel variante) async {
    await abrirEditorVariante(
      context,
      productoId: producto.id,
      variante: variante,
      guardarInmediato: true,
      totalVariantesExistentes: producto.variantes.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ProductoController>();
    final colors = context.colors;

    if (ctrl.isLoadingProductos && ctrl.productos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (ctrl.errorMessage != null && ctrl.productos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: colors.error),
            const SizedBox(height: VntlSpacing.lg),
            Text(ctrl.errorMessage!, style: VntlText.body.copyWith(color: colors.textSecondary)),
            const SizedBox(height: VntlSpacing.lg),
            Center(
              child: IntrinsicWidth(
                child: VntlButton(
                  label: 'Reintentar',
                  fullWidth: false,
                  onPressed: () => context.read<ProductoController>().cargarProductos(),
                ),
              ),
            )
          ],
        ),
      );
    }

    return Align(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(VntlSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                VntlButton(
                  label: 'Agregar producto',
                  icon: Icons.add_rounded,
                  fullWidth: false,
                  onPressed: () => _abrirFormulario(),
                ),
              ],
            ),
            const SizedBox(height: VntlSpacing.lg),
            if (ctrl.productos.isEmpty)
              _EstadoVacio(onAgregar: () => _abrirFormulario())
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  const anchoMinimo = 260.0;
                  final columnas = (constraints.maxWidth / anchoMinimo).floor().clamp(1, 6);

                  return Wrap(
                    spacing: VntlSpacing.md,
                    runSpacing: VntlSpacing.md,
                    children: [
                      for (final producto in ctrl.productos)
                        SizedBox(
                          width:
                              (constraints.maxWidth - (VntlSpacing.md * (columnas - 1))) / columnas,
                          child: _ProductoCardExpandible(
                            producto: producto,
                            expandido: _productoExpandidoId == producto.id,
                            onTap: () => _toggleExpandido(producto.id),
                            onEditarProducto: () => _abrirFormulario(producto: producto),
                            onEditarVariante: (v) => _editarVarianteDesdeListado(producto, v),
                          ),
                        ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _EstadoVacio extends StatelessWidget {
  const _EstadoVacio({required this.onAgregar});

  final VoidCallback onAgregar;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(VntlSpacing.xl * 1.5),
      decoration: BoxDecoration(
        color: colors.glassSurface,
        borderRadius: VntlRadius.lgBorderRadius,
        border: Border.all(color: colors.border, width: 0.5),
      ),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 48, color: colors.textTertiary),
          const SizedBox(height: VntlSpacing.lg),
          Text('Aún no tienes productos', style: VntlText.h4),
          const SizedBox(height: VntlSpacing.sm),
          Text(
            'Agrega tu primer producto para empezar a vender',
            style: VntlText.body.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: VntlSpacing.xl),
          Center(
            child: IntrinsicWidth(
              child: VntlButton(
                label: 'Agregar producto',
                icon: Icons.add_rounded,
                fullWidth: false,
                onPressed: onAgregar,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _ProductoCardExpandible extends StatelessWidget {
  const _ProductoCardExpandible({
    required this.producto,
    required this.expandido,
    required this.onTap,
    required this.onEditarProducto,
    required this.onEditarVariante,
  });

  final ProductoModel producto;
  final bool expandido;
  final VoidCallback onTap;
  final VoidCallback onEditarProducto;
  final ValueChanged<ProductoVarianteModel> onEditarVariante;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = VntlCategoryStyle.forCategoria(
      context,
      producto.categoriaId,
      iconoKey: producto.categoria?.icono,
      colorHex: producto.categoria?.color,
    );
    final tieneVariantes = producto.tieneMultiplesVariantes;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 220,
      decoration: BoxDecoration(
        color: colors.glassSurface,
        borderRadius: VntlRadius.lgBorderRadius,
        border: Border.all(color: colors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            borderRadius: VntlRadius.lgBorderRadius,
            child: InkWell(
              borderRadius: VntlRadius.lgBorderRadius,
              onTap: onTap,
              onLongPress: onEditarProducto,
              child: Padding(
                padding: const EdgeInsets.all(VntlSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: VntlRadius.mdBorderRadius,
                          child: Container(
                            width: 44,
                            height: 44,
                            color: style.background,
                            child: Icon(style.icon, color: style.foreground, size: 22),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          expandido ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                          color: colors.textTertiary,
                          size: 20,
                        ),
                      ],
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
                          padding:
                              const EdgeInsets.symmetric(horizontal: VntlSpacing.sm, vertical: 2),
                          decoration: BoxDecoration(
                            color: style.background,
                            borderRadius: VntlRadius.smBorderRadius,
                          ),
                          child: Text(
                            producto.categoria?.nombre ?? 'Sin categoría',
                            style: VntlText.caption.copyWith(
                              color: style.foreground,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (tieneVariantes) ...[
                          const SizedBox(width: VntlSpacing.sm),
                          Expanded(
                            child: Text(
                              '${producto.variantes.length} variantes',
                              style: VntlText.caption.copyWith(color: colors.textTertiary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (expandido) ...[
            Divider(color: colors.border, height: 0.5),
            Padding(
              padding: const EdgeInsets.all(VntlSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final variante in producto.variantes)
                    Padding(
                      padding: const EdgeInsets.only(bottom: VntlSpacing.sm),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: VntlRadius.smBorderRadius,
                        child: InkWell(
                          borderRadius: VntlRadius.smBorderRadius,
                          onTap: () => onEditarVariante(variante),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: VntlSpacing.sm,
                              vertical: VntlSpacing.xs,
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: VntlRadius.smBorderRadius,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    color: colors.surfaceSecondary,
                                    child: variante.imagenPrincipal != null
                                        ? Image.network(
                                            variante.imagenPrincipal!.path,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Icon(
                                              Icons.image_outlined,
                                              size: 16,
                                              color: colors.textTertiary,
                                            ),
                                          )
                                        : Icon(Icons.image_outlined,
                                            size: 16, color: colors.textTertiary),
                                  ),
                                ),
                                const SizedBox(width: VntlSpacing.sm),
                                Expanded(
                                  child: Text(
                                    variante.nombre,
                                    style: VntlText.bodySmall.copyWith(color: colors.textPrimary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '\$${variante.precioFinal.toStringAsFixed(2)}',
                                  style: VntlText.caption.copyWith(color: colors.primary),
                                ),
                              ],
                            ),
                          ),
                        ),
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
