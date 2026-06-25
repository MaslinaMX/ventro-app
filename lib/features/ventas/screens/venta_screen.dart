import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/auth/controllers/auth_controller.dart';
import 'package:ventro_app/features/ventas/controllers/venta_controller.dart';
import 'package:ventro_app/features/ventas/widgets/cantidad_selector_sheet.dart';
import 'package:ventro_app/features/ventas/widgets/carrito_panel.dart';
import 'package:ventro_app/features/products/models/categoria_model.dart';
import 'package:ventro_app/features/ventas/widgets/producto_grid_card.dart';
import 'package:ventro_app/features/ventas/widgets/selector_caja_venta.dart';
import 'package:ventro_app/features/ventas/widgets/verificar_empleado_venta.dart';

class VentaScreen extends StatefulWidget {
  const VentaScreen({super.key});

  @override
  State<VentaScreen> createState() => _VentaScreenState();
}

class _VentaScreenState extends State<VentaScreen> {
  bool _loaded = false;
  bool _catalogoCargado = false;
  final _busquedaCtrl = TextEditingController();
  static const double _collapseBreakpoint = 900.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      final sucursalId = context.read<AuthController>().user?.sucursalId;
      if (sucursalId != null) {
        context.read<VentaController>().cargarDatos(sucursalId: sucursalId);
      }
    }
  }

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarCatalogoSiHaceFalta(BuildContext context) async {
    if (_catalogoCargado) return;
    _catalogoCargado = true;
    final sucursalId = context.read<AuthController>().user?.sucursalId;
    if (sucursalId != null) {
      await context.read<VentaController>().cargarDatos(sucursalId: sucursalId);
    }
  }

  Future<void> _onTapProducto(BuildContext context, dynamic item) async {
    final ctrl = context.read<VentaController>();
    final cantidad = await VntlModal.show<int>(
      context,
      title: 'Agregar al carrito',
      width: 360,
      content: CantidadSelectorSheet(variante: item.variante, producto: item.producto),
    );
    if (cantidad != null) {
      ctrl.agregarAlCarrito(item.variante, item.producto, cantidad: cantidad);
    }
  }

  void _abrirCarritoMovil(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.92,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: CarritoPanel(scrollController: scrollController, isFullWidth: true),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ctrl = context.watch<VentaController>();
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < _collapseBreakpoint;

    // ─── Paso 1: seleccionar caja con sesión abierta ─────────────────────────
    if (ctrl.cajaId == null) {
      return const SelectorCajaVenta();
    }

    // ─── Paso 2: verificar número de empleado + PIN ──────────────────────────
    if (!ctrl.empleadoVerificado) {
      return const VerificarEmpleadoVenta();
    }

    // ─── Paso 3: catálogo + carrito ───────────────────────────────────────────
    _cargarCatalogoSiHaceFalta(context);

    if (ctrl.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final grid = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(VntlSpacing.lg, VntlSpacing.lg, VntlSpacing.lg, 0),
          child: Row(
            children: [
              Icon(Icons.badge_rounded, size: 16, color: colors.textTertiary),
              const SizedBox(width: VntlSpacing.xs),
              Text(
                'Vendiendo como ${ctrl.empleadoNombreVerificado}',
                style: VntlText.caption.copyWith(color: colors.textTertiary),
              ),
              const Spacer(),
              GestureDetector(
                onTap: ctrl.cambiarCaja,
                child: Text(
                  'Cambiar caja',
                  style: VntlText.caption.copyWith(color: colors.primary),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(VntlSpacing.lg),
          child: VntlInput(
            hint: 'Buscar producto o SKU...',
            controller: _busquedaCtrl,
            prefixIcon: Icons.search_rounded,
            onChanged: ctrl.buscar,
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: VntlSpacing.lg),
            children: [
              _CategoriaChip(
                label: 'Todas',
                selected: ctrl.categoriaSeleccionadaId == null,
                onTap: () => ctrl.filtrarPorCategoria(null),
              ),
              const SizedBox(width: VntlSpacing.sm),
              ...ctrl.categorias.map((cat) => Padding(
                    padding: const EdgeInsets.only(right: VntlSpacing.sm),
                    child: _CategoriaChip(
                      label: cat.nombre,
                      selected: ctrl.categoriaSeleccionadaId == cat.id,
                      onTap: () => ctrl.filtrarPorCategoria(cat.id),
                      categoria: cat,
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: VntlSpacing.md),
        Expanded(
          child: ctrl.variantesVisibles.isEmpty
              ? Center(
                  child: Text(
                    'Sin productos para mostrar',
                    style: VntlText.body.copyWith(color: colors.textTertiary),
                  ),
                )
              : GridView.builder(
                  padding: EdgeInsets.fromLTRB(
                    VntlSpacing.lg,
                    0,
                    VntlSpacing.lg,
                    isMobile ? 96 : VntlSpacing.lg, // espacio para el FAB
                  ),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: isMobile ? 140 : 160,
                    mainAxisSpacing: VntlSpacing.md,
                    crossAxisSpacing: VntlSpacing.md,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: ctrl.variantesVisibles.length,
                  itemBuilder: (context, index) {
                    final item = ctrl.variantesVisibles[index];
                    return ProductoGridCard(
                      variante: item.variante,
                      producto: item.producto,
                      onTap: () => _onTapProducto(context, item),
                    );
                  },
                ),
        ),
      ],
    );

    if (isMobile) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: grid,
        floatingActionButton: ctrl.carrito.isEmpty
            ? null
            : _CarritoFab(
                cantidad: ctrl.cantidadItemsCarrito,
                total: ctrl.totalCarrito,
                onTap: () => _abrirCarritoMovil(context),
              ),
      );
    }
    return Row(
      children: [
        Expanded(child: grid),
        const CarritoPanel(),
      ],
    );
  }
}

class _CategoriaChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final CategoriaModel? categoria;

  const _CategoriaChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.categoria,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // "Todas" no tiene categoría real, usa el color primario del tema.
    final Color colorBase = categoria != null
        ? VntlCategoryStyle.forCategoria(
            context,
            categoria!.id,
            iconoKey: categoria!.icono,
            colorHex: categoria!.color,
          ).foreground
        : colors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: VntlSpacing.md, vertical: VntlSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? colorBase.withValues(alpha: 0.18) : colors.glassSurface,
          borderRadius: VntlRadius.mdBorderRadius,
          border: Border.all(
            color: selected ? colorBase : colors.border,
            width: selected ? 1.5 : 0.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: VntlText.label.copyWith(
            color: selected ? colorBase : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _CarritoFab extends StatelessWidget {
  final int cantidad;
  final double total;
  final VoidCallback onTap;

  const _CarritoFab({
    required this.cantidad,
    required this.total,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: VntlSpacing.lg, vertical: VntlSpacing.md),
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: VntlRadius.lgBorderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(
                '$cantidad',
                style: VntlText.labelSmall
                    .copyWith(color: colors.primary, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: VntlSpacing.sm),
            Text(
              'Ver carrito',
              style: VntlText.label.copyWith(color: Colors.white),
            ),
            const SizedBox(width: VntlSpacing.sm),
            Text(
              '\$${total.toStringAsFixed(2)}',
              style: VntlText.label.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
