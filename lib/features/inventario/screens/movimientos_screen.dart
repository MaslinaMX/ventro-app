import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/auth/controllers/auth_controller.dart';
import 'package:ventro_app/features/auth/models/user_model.dart';
import 'package:ventro_app/features/inventario/controllers/inventario_controller.dart';
import 'package:ventro_app/features/inventario/models/movimiento_inventario_model.dart';
import 'package:ventro_app/features/products/controllers/producto_controller.dart';
import 'package:ventro_app/features/products/models/producto_model.dart';
import 'package:ventro_app/features/products/models/producto_variante_model.dart';
import 'package:ventro_app/features/settings/models/sucursal_model.dart';
import 'package:ventro_app/features/settings/services/settings_service.dart';

class MovimientosScreen extends StatefulWidget {
  const MovimientosScreen({super.key});

  @override
  State<MovimientosScreen> createState() => _MovimientosScreenState();
}

class _MovimientosScreenState extends State<MovimientosScreen> {
  final SettingsService _settingsService = SettingsService();

  bool _esAdmin = false;
  bool _cargandoInicial = true;

  List<SucursalModel> _sucursales = [];
  int? _sucursalSeleccionadaId; // null = todas las sucursales

  ProductoVarianteModel? _varianteSeleccionada;
  String? _productoNombreSeleccionado;

  List<MovimientoInventarioModel> _movimientos = [];
  bool _cargandoMovimientos = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    final user = context.read<AuthController>().user;
    _esAdmin = user?.role.isAdmin ?? false;

    if (_esAdmin) {
      try {
        _sucursales = await _settingsService.getSucursales();
      } catch (_) {
        _sucursales = [];
      }
    }

    final productoCtrl = context.read<ProductoController>();
    if (productoCtrl.productos.isEmpty) {
      await productoCtrl.cargarProductos();
    }

    if (mounted) setState(() => _cargandoInicial = false);
  }

  Future<void> _abrirSelectorProducto() async {
    final productoCtrl = context.read<ProductoController>();

    final seleccion = await showDialog<ProductoVarianteModel>(
      context: context,
      builder: (dialogContext) => Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 80),
          child: VntlModal(
            title: 'Seleccionar producto',
            content: _ProductoSearchList(productos: productoCtrl.productos),
          ),
        ),
      ),
    );

    if (seleccion != null) {
      final producto = productoCtrl.productos.firstWhere(
        (p) => p.variantes.any((v) => v.id == seleccion.id),
      );
      setState(() {
        _varianteSeleccionada = seleccion;
        _productoNombreSeleccionado = producto.nombre;
      });
      await _cargarMovimientos();
    }
  }

  Future<void> _abrirSelectorSucursal() async {
    final seleccion = await showDialog<int?>(
      context: context,
      builder: (dialogContext) => Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 80),
          child: VntlModal(
            title: 'Seleccionar sucursal',
            content: _SucursalSearchListConTodas(sucursales: _sucursales),
          ),
        ),
      ),
    );

    // showDialog regresa null tanto si cancelas como si eliges "Todas".
    // Usamos un sentinel: -1 significa "Todas las sucursales".
    if (seleccion == -1) {
      setState(() => _sucursalSeleccionadaId = null);
      await _cargarMovimientos();
    } else if (seleccion != null) {
      setState(() => _sucursalSeleccionadaId = seleccion);
      await _cargarMovimientos();
    }
  }

  Future<void> _cargarMovimientos() async {
    if (_varianteSeleccionada == null) return;

    setState(() {
      _cargandoMovimientos = true;
      _error = null;
    });

    try {
      final inventarioCtrl = context.read<InventarioController>();
      _movimientos = await inventarioCtrl.obtenerMovimientosPorVariante(
        _varianteSeleccionada!.id,
        sucursalId: _sucursalSeleccionadaId,
      );
    } catch (e) {
      _error = 'No se pudieron cargar los movimientos.';
    } finally {
      if (mounted) setState(() => _cargandoMovimientos = false);
    }
  }

  String _formatFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final hora = fecha.hour.toString().padLeft(2, '0');
    final min = fecha.minute.toString().padLeft(2, '0');
    return '$dia/$mes/${fecha.year} $hora:$min';
  }

  String _formatNum(double valor) {
    return valor % 1 == 0 ? valor.toInt().toString() : valor.toString();
  }

  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: _cargandoInicial
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(VntlSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child:
                              Icon(Icons.arrow_back_rounded, color: colors.textSecondary, size: 20),
                        ),
                        const SizedBox(width: VntlSpacing.md),
                        Text('Movimientos de inventario', style: VntlText.h2),
                      ],
                    ),
                    const SizedBox(height: VntlSpacing.xl),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = constraints.maxWidth < 600;

                        if (isMobile) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSelectorProducto(colors),
                              if (_esAdmin) ...[
                                const SizedBox(height: VntlSpacing.lg),
                                _buildSelectorSucursal(colors),
                              ],
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 2, child: _buildSelectorProducto(colors)),
                            if (_esAdmin) ...[
                              const SizedBox(width: VntlSpacing.lg),
                              Expanded(child: _buildSelectorSucursal(colors)),
                            ],
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: VntlSpacing.xl),
                    if (_varianteSeleccionada == null)
                      _buildEstadoVacio(colors)
                    else
                      _buildTablaMovimientos(colors),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSelectorProducto(dynamic colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Producto', style: VntlText.labelSmall.copyWith(color: colors.textSecondary)),
        const SizedBox(height: VntlSpacing.xs),
        GestureDetector(
          onTap: _abrirSelectorProducto,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: VntlSpacing.lg, vertical: VntlSpacing.md),
            decoration: BoxDecoration(
              color: colors.glassSurface,
              borderRadius: VntlRadius.mdBorderRadius,
              border: Border.all(color: colors.border, width: 0.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _varianteSeleccionada == null
                        ? 'Selecciona un producto'
                        : '$_productoNombreSeleccionado — ${_varianteSeleccionada!.nombre}',
                    style: VntlText.body.copyWith(
                      color:
                          _varianteSeleccionada == null ? colors.textTertiary : colors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.search_rounded, color: colors.textSecondary, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectorSucursal(dynamic colors) {
    final nombreActual = _sucursalSeleccionadaId == null
        ? 'Todas las sucursales'
        : _sucursales
            .firstWhere(
              (s) => s.id == _sucursalSeleccionadaId,
              orElse: () => _sucursales.first,
            )
            .nombre;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sucursal', style: VntlText.labelSmall.copyWith(color: colors.textSecondary)),
        const SizedBox(height: VntlSpacing.xs),
        GestureDetector(
          onTap: _abrirSelectorSucursal,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: VntlSpacing.lg, vertical: VntlSpacing.md),
            decoration: BoxDecoration(
              color: colors.glassSurface,
              borderRadius: VntlRadius.mdBorderRadius,
              border: Border.all(color: colors.border, width: 0.5),
            ),
            child: Row(
              children: [
                Expanded(child: Text(nombreActual, style: VntlText.body)),
                Icon(Icons.arrow_drop_down, color: colors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEstadoVacio(dynamic colors) {
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
          Icon(Icons.search_rounded, size: 48, color: colors.textTertiary),
          const SizedBox(height: VntlSpacing.lg),
          Text(
            'Selecciona un producto para ver su historial',
            style: VntlText.h4,
          ),
        ],
      ),
    );
  }

  Widget _buildTablaMovimientos(dynamic colors) {
    if (_error != null) {
      return Text(_error!, style: VntlText.body.copyWith(color: colors.error));
    }

    return VntlTable<MovimientoInventarioModel>(
      isLoading: _cargandoMovimientos,
      items: _movimientos,
      emptyLabel: 'Sin movimientos registrados para este producto',
      columns: [
        VntlTableColumn(
          label: 'Fecha',
          flex: 2,
          sortValue: (m) => m.createdAt,
          cellBuilder: (m) => Text(
            _formatFecha(m.createdAt),
            style: VntlText.body.copyWith(color: colors.textSecondary),
          ),
        ),
        VntlTableColumn(
          label: 'Sucursal',
          flex: 2,
          sortValue: (m) => m.sucursalNombre ?? '',
          cellBuilder: (m) => Text(
            m.sucursalNombre ?? '—',
            style: VntlText.body.copyWith(color: colors.textSecondary),
          ),
        ),
        VntlTableColumn(
          label: 'Tipo',
          flex: 2,
          cellBuilder: (m) => VntlBadge(
            label: m.type == MovimientoType.in_
                ? '${m.reason.label} +${_formatNum(m.cantidad)}'
                : '${m.reason.label} -${_formatNum(m.cantidad)}',
            variant:
                m.type == MovimientoType.in_ ? VntlBadgeVariant.success : VntlBadgeVariant.error,
          ),
        ),
        VntlTableColumn(
          label: 'Usuario',
          flex: 2,
          sortValue: (m) => m.userNombre ?? '',
          cellBuilder: (m) => Text(
            m.userNombre ?? '—',
            style: VntlText.body.copyWith(color: colors.textSecondary),
          ),
        ),
        VntlTableColumn(
          label: 'Motivo',
          flex: 3,
          cellBuilder: (m) => Text(
            m.notas ?? '—',
            style: VntlText.body.copyWith(color: colors.textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ProductoSearchList extends StatefulWidget {
  const _ProductoSearchList({required this.productos});

  final List<ProductoModel> productos;

  @override
  State<_ProductoSearchList> createState() => _ProductoSearchListState();
}

class _ProductoSearchListState extends State<_ProductoSearchList> {
  final _searchController = TextEditingController();
  late List<ProductoModel> _filtrados;

  @override
  void initState() {
    super.initState();
    _filtrados = widget.productos;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filtrar(String query) {
    setState(() {
      final q = query.toLowerCase();
      _filtrados = widget.productos.where((p) {
        if (p.nombre.toLowerCase().contains(q)) return true;
        return p.variantes.any((v) => v.nombre.toLowerCase().contains(q));
      }).toList();
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
          hint: 'Buscar producto...',
          autofocus: true,
          controller: _searchController,
          prefixIcon: Icons.search,
          onChanged: _filtrar,
        ),
        const SizedBox(height: VntlSpacing.md),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 360),
          child: _filtrados.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(VntlSpacing.lg),
                  child: Text('Sin resultados',
                      style: VntlText.body.copyWith(color: colors.textTertiary)),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filtrados.length,
                  itemBuilder: (_, i) {
                    final producto = _filtrados[i];
                    if (producto.variantes.length == 1) {
                      return ListTile(
                        title: Text(producto.nombre, style: VntlText.body),
                        onTap: () => Navigator.pop(context, producto.variantes.first),
                      );
                    }
                    return ExpansionTile(
                      title: Text(producto.nombre, style: VntlText.body),
                      children: [
                        for (final variante in producto.variantes)
                          ListTile(
                            contentPadding:
                                const EdgeInsets.only(left: VntlSpacing.xl, right: VntlSpacing.lg),
                            title: Text(variante.nombre, style: VntlText.bodySmall),
                            onTap: () => Navigator.pop(context, variante),
                          ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _SucursalSearchListConTodas extends StatefulWidget {
  const _SucursalSearchListConTodas({required this.sucursales});

  final List<SucursalModel> sucursales;

  @override
  State<_SucursalSearchListConTodas> createState() => _SucursalSearchListConTodasState();
}

class _SucursalSearchListConTodasState extends State<_SucursalSearchListConTodas> {
  final _searchController = TextEditingController();
  late List<SucursalModel> _filtradas;

  @override
  void initState() {
    super.initState();
    _filtradas = widget.sucursales;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filtrar(String query) {
    setState(() {
      _filtradas = widget.sucursales
          .where((s) => s.nombre.toLowerCase().contains(query.toLowerCase()))
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
          hint: 'Buscar sucursal...',
          autofocus: true,
          controller: _searchController,
          prefixIcon: Icons.search,
          onChanged: _filtrar,
        ),
        const SizedBox(height: VntlSpacing.md),
        ListTile(
          leading: Icon(Icons.apps_rounded, color: colors.textSecondary),
          title: Text('Todas las sucursales', style: VntlText.body),
          onTap: () => Navigator.pop(context, -1),
        ),
        Divider(color: colors.border, height: 0.5),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 280),
          child: _filtradas.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(VntlSpacing.lg),
                  child: Text('Sin resultados',
                      style: VntlText.body.copyWith(color: colors.textTertiary)),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filtradas.length,
                  itemBuilder: (_, i) {
                    final item = _filtradas[i];
                    return ListTile(
                      title: Text(item.nombre, style: VntlText.body),
                      onTap: () => Navigator.pop(context, item.id),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
