import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/auth/controllers/auth_controller.dart';
import 'package:ventro_app/features/auth/models/user_model.dart';
import 'package:ventro_app/features/inventario/controllers/inventario_controller.dart';
import 'package:ventro_app/features/inventario/models/inventario_stock_model.dart';
import 'package:ventro_app/features/inventario/models/movimiento_inventario_model.dart';
import 'package:ventro_app/features/inventario/screens/movimientos_screen.dart';
import 'package:ventro_app/features/inventario/widgets/ajuste_rapido_sheet.dart';
import 'package:ventro_app/features/settings/models/sucursal_model.dart';
import 'package:ventro_app/features/settings/services/settings_service.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key, this.onNavigateToProductos});

  final VoidCallback? onNavigateToProductos;

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  late InventarioController _controller;
  final SettingsService _settingsService = SettingsService();

  List<SucursalModel> _sucursales = [];
  int? _sucursalSeleccionadaId;
  String? _sucursalNombreFijo;
  bool _esAdmin = false;
  bool _loadingSucursales = true;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    _controller = context.read<InventarioController>();
    final user = context.read<AuthController>().user;
    _esAdmin = user?.role.isAdmin ?? false;

    if (_esAdmin) {
      try {
        _sucursales = await _settingsService.getSucursales();
      } catch (_) {
        _sucursales = [];
      }
      _sucursalSeleccionadaId = _sucursales.isNotEmpty ? _sucursales.first.id : null;
    } else {
      _sucursalSeleccionadaId = user?.sucursalId;
      _sucursalNombreFijo = user?.sucursal;
    }

    setState(() => _loadingSucursales = false);

    await _controller.cargarUmbralStockBajo();

    if (_sucursalSeleccionadaId != null) {
      await _controller.cargarStock(_sucursalSeleccionadaId!);
    }
  }

  Future<void> _onSucursalChanged(int? sucursalId) async {
    if (sucursalId == null) return;
    setState(() => _sucursalSeleccionadaId = sucursalId);
    await _controller.cargarStock(sucursalId);
  }

  Future<void> _abrirAjusteRapido() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 80),
          child: VntlModal(
            title: 'Ajuste Rápido de Inventario',
            content: const AjusteRapidoSheet(),
          ),
        ),
      ),
    );
    if (result == true) {
      // El controller ya se refresca internamente tras guardar.
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _loadingSucursales
              ? const Center(
                  key: ValueKey('loading'),
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  key: const ValueKey('contenido'),
                  padding: const EdgeInsets.all(VntlSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(colors),
                      const SizedBox(height: VntlSpacing.lg),
                      if (_esAdmin) _buildSucursalSelector(colors),
                      const SizedBox(height: VntlSpacing.lg),
                      _buildStatsCards(colors),
                      const SizedBox(height: VntlSpacing.xl),
                      _buildMovimientosList(colors),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader(dynamic colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Inventario', style: VntlText.h2),
              const SizedBox(height: VntlSpacing.xs),
              Text(
                'Existencias y movimientos',
                style: VntlText.body.copyWith(color: colors.textSecondary),
              ),
            ],
          ),
        ),
        VntlButton(
          label: 'Ajuste',
          icon: Icons.tune_rounded,
          fullWidth: false,
          size: VntlButtonSize.sm,
          onPressed: _abrirAjusteRapido,
        ),
      ],
    );
  }

  Widget _buildSucursalSelector(dynamic colors) {
    final soloUnaSucursal = !_esAdmin || _sucursales.length <= 1;
    final nombreActual = !_esAdmin
        ? (_sucursalNombreFijo ?? '—')
        : (_sucursales.isEmpty
            ? '—'
            : _sucursales
                .firstWhere(
                  (s) => s.id == _sucursalSeleccionadaId,
                  orElse: () => _sucursales.first,
                )
                .nombre);

    return GestureDetector(
      onTap: soloUnaSucursal ? null : _abrirSelectorSucursal,
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
            Icon(Icons.storefront_rounded, size: 16, color: colors.textSecondary),
            const SizedBox(width: VntlSpacing.sm),
            Expanded(child: Text(nombreActual, style: VntlText.body)),
            if (!soloUnaSucursal)
              Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: colors.textTertiary),
          ],
        ),
      ),
    );
  }

  Future<void> _abrirSelectorSucursal() async {
    final seleccion = await showDialog<int>(
      context: context,
      builder: (dialogContext) => Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 80),
          child: VntlModal(
            title: 'Seleccionar Sucursal',
            content: _SucursalSearchList(sucursales: _sucursales),
          ),
        ),
      ),
    );

    if (seleccion != null) {
      await _onSucursalChanged(seleccion);
    }
  }

  Widget _buildStatsCards(dynamic colors) {
    return Consumer<InventarioController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error != null) {
          return Text(controller.error!, style: VntlText.body.copyWith(color: colors.error));
        }

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                colors,
                label: 'Total productos',
                value: '${controller.totalProductos}',
                icon: Icons.inventory_2_outlined,
                tintBackground: true,
                tintColor: colors.info,
                tintSurface: colors.infoSurface,
                onTap: widget.onNavigateToProductos ?? () {},
              ),
            ),
            const SizedBox(width: VntlSpacing.sm),
            Expanded(
              child: _buildStatCard(
                colors,
                label: 'Stock bajo',
                value: '${controller.alertasStockBajo}',
                icon: Icons.warning_amber_rounded,
                tintBackground: true,
                tintColor: colors.warning,
                tintSurface: colors.warningSurface,
                onTap: () => _abrirDetalleStock(
                  titulo: 'Productos con stock bajo',
                  items: controller.productosStockBajo,
                ),
              ),
            ),
            const SizedBox(width: VntlSpacing.sm),
            Expanded(
              child: _buildStatCard(
                colors,
                label: 'Agotados',
                value: '${controller.productosAgotados}',
                icon: Icons.block_rounded,
                tintBackground: true,
                tintColor: colors.error,
                tintSurface: colors.errorSurface,
                onTap: () => _abrirDetalleStock(
                  titulo: 'Productos agotados',
                  items: controller.productosAgotadosLista,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    dynamic colors, {
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    bool tintBackground = false,
    Color? tintColor,
    Color? tintSurface,
  }) {
    final bg = tintBackground ? (tintSurface ?? colors.surface) : colors.surface;
    final iconColor = tintBackground ? (tintColor ?? colors.textSecondary) : colors.textSecondary;
    final valueColor = tintBackground ? (tintColor ?? colors.textPrimary) : colors.textPrimary;
    final labelColor = tintBackground ? (tintColor ?? colors.textSecondary) : colors.textSecondary;

    return Material(
      color: Colors.transparent,
      borderRadius: VntlRadius.mdBorderRadius,
      child: InkWell(
        borderRadius: VntlRadius.mdBorderRadius,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: VntlSpacing.sm, vertical: VntlSpacing.md),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: VntlRadius.mdBorderRadius,
            border: tintBackground ? null : Border.all(color: colors.border, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(height: VntlSpacing.xs),
              Text(value, style: VntlText.h3.copyWith(color: valueColor)),
              const SizedBox(height: 2),
              Text(
                label,
                style: VntlText.caption.copyWith(color: labelColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _abrirDetalleStock({
    required String titulo,
    required List<InventarioStockModel> items,
  }) async {
    await showDialog(
      context: context,
      builder: (dialogContext) => Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 80),
          child: VntlModal(
            title: titulo,
            content: _DetalleStockList(items: items),
          ),
        ),
      ),
    );
  }

  Widget _buildMovimientosList(dynamic colors) {
    return Consumer<InventarioController>(
      builder: (context, controller, _) {
        final movimientosLimitados = controller.movimientos.take(7).toList();
        final hayMas = controller.movimientos.length > 7;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Historial de movimientos', style: VntlText.h4),
                if (hayMas)
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MovimientosScreen()),
                    ),
                    child: Text(
                      'Ver todos',
                      style: VntlText.label.copyWith(color: colors.primary),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: VntlSpacing.md),
            if (controller.movimientosError != null)
              Text(
                controller.movimientosError!,
                style: VntlText.body.copyWith(color: colors.error),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final esTablet = constraints.maxWidth >= 700;

                  if (esTablet) {
                    return VntlTable<MovimientoInventarioModel>(
                      isLoading: controller.isLoadingMovimientos,
                      items: movimientosLimitados,
                      emptyLabel: 'Sin movimientos registrados',
                      columns: [
                        VntlTableColumn(
                          label: 'Fecha',
                          flex: 2,
                          sortValue: (m) => m.createdAt,
                          cellBuilder: (m) => Text(
                            _formatFechaCompleta(m.createdAt),
                            style: VntlText.body.copyWith(color: colors.textSecondary),
                          ),
                        ),
                        VntlTableColumn(
                          label: 'Producto',
                          flex: 2,
                          sortValue: (m) => m.productoNombre ?? '',
                          cellBuilder: (m) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(m.productoNombre ?? '—', style: VntlText.body),
                              if (m.varianteNombre != null && m.varianteNombre!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  m.varianteNombre!,
                                  style: VntlText.caption.copyWith(color: colors.textTertiary),
                                ),
                              ],
                            ],
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
                          label: 'Cantidad',
                          flex: 2,
                          cellBuilder: (m) => VntlBadge(
                            label: m.type == MovimientoType.in_
                                ? ' +${_formatNum(m.cantidad)}'
                                : ' -${_formatNum(m.cantidad)}',
                            variant: m.type == MovimientoType.in_
                                ? VntlBadgeVariant.success
                                : VntlBadgeVariant.error,
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
                            m.notas != null && m.notas!.isNotEmpty ? m.notas! : m.reason.label,
                            style: VntlText.body.copyWith(color: colors.textSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    );
                  }

                  if (controller.isLoadingMovimientos) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: VntlSpacing.xl2),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (movimientosLimitados.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: VntlSpacing.xl2),
                      child: Center(
                        child: Text(
                          'Sin movimientos registrados',
                          style: VntlText.body.copyWith(color: colors.textTertiary),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      for (final m in movimientosLimitados) _MovimientoCard(movimiento: m),
                    ],
                  );
                },
              ),
          ],
        );
      },
    );
  }

  String _formatFechaCompleta(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final hora = fecha.hour.toString().padLeft(2, '0');
    final min = fecha.minute.toString().padLeft(2, '0');
    return '$dia/$mes/${fecha.year} $hora:$min';
  }

  String _formatNum(double valor) {
    return valor % 1 == 0 ? valor.toInt().toString() : valor.toString();
  }
}

class _MovimientoCard extends StatelessWidget {
  const _MovimientoCard({required this.movimiento});

  final MovimientoInventarioModel movimiento;

  String _formatFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final hora = fecha.hour.toString().padLeft(2, '0');
    final min = fecha.minute.toString().padLeft(2, '0');
    return '$dia/$mes $hora:$min';
  }

  String _formatNum(double valor) {
    return valor % 1 == 0 ? valor.toInt().toString() : valor.toString();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final esEntrada = movimiento.type == MovimientoType.in_;

    return Container(
      margin: const EdgeInsets.only(bottom: VntlSpacing.sm),
      padding: const EdgeInsets.all(VntlSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: VntlRadius.lgBorderRadius,
        border: Border.all(color: colors.border, width: 0.5),
      ),
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
                    Text(
                      movimiento.productoNombre ?? '—',
                      style: VntlText.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (movimiento.varianteNombre != null &&
                        movimiento.varianteNombre!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        movimiento.varianteNombre!,
                        style: VntlText.caption.copyWith(color: colors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: VntlSpacing.sm),
              VntlBadge(
                label: esEntrada
                    ? '${movimiento.reason.label} +${_formatNum(movimiento.cantidad)}'
                    : '${movimiento.reason.label} -${_formatNum(movimiento.cantidad)}',
                variant: esEntrada ? VntlBadgeVariant.success : VntlBadgeVariant.error,
              ),
            ],
          ),
          const SizedBox(height: VntlSpacing.sm),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 12, color: colors.textTertiary),
              const SizedBox(width: 4),
              Text(
                _formatFecha(movimiento.createdAt),
                style: VntlText.caption.copyWith(color: colors.textTertiary),
              ),
              const SizedBox(width: VntlSpacing.md),
              Icon(Icons.storefront_rounded, size: 12, color: colors.textTertiary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  movimiento.sucursalNombre ?? '—',
                  style: VntlText.caption.copyWith(color: colors.textTertiary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SucursalSearchList extends StatefulWidget {
  final List<SucursalModel> sucursales;

  const _SucursalSearchList({required this.sucursales});

  @override
  State<_SucursalSearchList> createState() => _SucursalSearchListState();
}

class _SucursalSearchListState extends State<_SucursalSearchList> {
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
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 320),
          child: _filtradas.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(VntlSpacing.lg),
                  child: Text(
                    'Sin resultados',
                    style: VntlText.body.copyWith(color: colors.textTertiary),
                  ),
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

class _DetalleStockList extends StatelessWidget {
  const _DetalleStockList({required this.items});

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
