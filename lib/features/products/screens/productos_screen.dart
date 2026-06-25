import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/products/controllers/producto_controller.dart';
import 'package:ventro_app/features/products/models/producto_model.dart';
import 'package:ventro_app/features/products/models/producto_variante_model.dart';
import 'package:ventro_app/features/products/screens/productos_form_screen.dart';
import 'package:ventro_app/features/products/screens/variantes_inactivas_screen.dart';
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
    final resultado = await abrirEditorVariante(
      context,
      productoId: producto.id,
      variante: variante,
      guardarInmediato: true,
      totalVariantesExistentes: producto.variantes.length,
    );
    if (resultado.eliminada && mounted) {
      await context.read<ProductoController>().cargarProductos();
    }
  }

  Widget _buildBuscadorRapido(dynamic colors, List<ProductoModel> productos) {
    return GestureDetector(
      onTap: () => _abrirBusquedaRapida(productos),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: VntlSpacing.md, vertical: VntlSpacing.sm + 2),
        decoration: BoxDecoration(
          color: colors.glassSurface,
          borderRadius: VntlRadius.mdBorderRadius,
          border: Border.all(color: colors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, size: 16, color: colors.textSecondary),
            const SizedBox(width: VntlSpacing.sm),
            Expanded(
              child: Text(
                'Buscar producto o variante...',
                style: VntlText.body.copyWith(color: colors.textTertiary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _abrirBusquedaRapida(List<ProductoModel> productos) async {
    final seleccion = await showDialog<_ProductoBusquedaResultado>(
      context: context,
      builder: (dialogContext) => Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 80),
          child: VntlModal(
            title: 'Buscar producto',
            content: _ProductoSearchList(productos: productos),
          ),
        ),
      ),
    );

    if (seleccion != null) {
      await _editarVarianteDesdeListado(seleccion.producto, seleccion.variante);
    }
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Productos', style: VntlText.h2),
                      const SizedBox(height: VntlSpacing.xs),
                      Text(
                        'Productos y variantes',
                        style: VntlText.body.copyWith(color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
                VntlButton(
                  label: 'Nuevo',
                  icon: Icons.add,
                  fullWidth: false,
                  size: VntlButtonSize.sm,
                  onPressed: () => _abrirFormulario(),
                ),
              ],
            ),
            const SizedBox(height: VntlSpacing.lg),
            if (ctrl.productos.isNotEmpty) ...[
              _buildBuscadorRapido(colors, ctrl.productos),
              const SizedBox(height: VntlSpacing.lg),
            ],
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
            const SizedBox(height: VntlSpacing.xl),
            Center(
              child: TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VariantesInactivasScreen()),
                ),
                icon: Icon(Icons.visibility_off_outlined, size: 16, color: colors.textTertiary),
                label: Text(
                  'Ver inactivos',
                  style: VntlText.caption.copyWith(color: colors.textTertiary),
                ),
              ),
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

class _ProductoBusquedaResultado {
  const _ProductoBusquedaResultado({required this.producto, required this.variante});

  final ProductoModel producto;
  final ProductoVarianteModel variante;
}

class _ProductoSearchList extends StatefulWidget {
  final List<ProductoModel> productos;

  const _ProductoSearchList({required this.productos});

  @override
  State<_ProductoSearchList> createState() => _ProductoSearchListState();
}

class _ProductoSearchListState extends State<_ProductoSearchList> {
  final _searchController = TextEditingController();
  late List<_ProductoBusquedaResultado> _todos;
  late List<_ProductoBusquedaResultado> _filtrados;

  @override
  void initState() {
    super.initState();
    _todos = [
      for (final producto in widget.productos)
        for (final variante in producto.variantes)
          _ProductoBusquedaResultado(producto: producto, variante: variante),
    ];
    _filtrados = _todos;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _normalizar(String texto) {
    const conAcento = 'áàäâãéèëêíìïîóòöôõúùüûñç';
    const sinAcento = 'aaaaaeeeeiiiiooooouuuunc';
    var resultado = texto.toLowerCase();
    for (var i = 0; i < conAcento.length; i++) {
      resultado = resultado.replaceAll(conAcento[i], sinAcento[i]);
    }
    return resultado;
  }

  void _filtrar(String query) {
    final q = _normalizar(query);
    setState(() {
      _filtrados = _todos
          .where((r) =>
              _normalizar(r.producto.nombre).contains(q) ||
              _normalizar(r.variante.nombre).contains(q))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VntlInput(
          hint: 'Buscar producto o variante...',
          autofocus: true,
          controller: _searchController,
          prefixIcon: Icons.search,
          onChanged: _filtrar,
        ),
        const SizedBox(height: VntlSpacing.md),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 320, minWidth: 360),
          child: _filtrados.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(VntlSpacing.lg),
                  child: Text(
                    'Sin resultados',
                    style: VntlText.body.copyWith(color: colors.textTertiary),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filtrados.length,
                  itemBuilder: (_, i) {
                    final resultado = _filtrados[i];
                    final mostrarNombreVariante =
                        resultado.variante.nombre != resultado.producto.nombre;

                    return ListTile(
                      title: Text(resultado.producto.nombre, style: VntlText.body),
                      subtitle: mostrarNombreVariante
                          ? Text(
                              resultado.variante.nombre,
                              style: VntlText.caption.copyWith(color: colors.textTertiary),
                            )
                          : null,
                      trailing: Text(
                        '\$${resultado.variante.precioFinal.toStringAsFixed(2)}',
                        style: VntlText.caption.copyWith(color: colors.primary),
                      ),
                      onTap: () => Navigator.pop(context, resultado),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
