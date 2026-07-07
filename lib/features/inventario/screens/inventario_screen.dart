import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/design_system/widgets/vntl_mes_search_list.dart';
import 'package:ventro_app/design_system/widgets/vntl_sucursal_search_list.dart';
import 'package:ventro_app/features/auth/controllers/auth_controller.dart';
import 'package:ventro_app/features/auth/models/user_model.dart';
import 'package:ventro_app/features/inventario/controllers/inventario_controller.dart';
import 'package:ventro_app/features/inventario/models/inventario_stock_model.dart';
import 'package:ventro_app/features/inventario/models/movimiento_inventario_model.dart';
import 'package:ventro_app/features/inventario/screens/movimientos_screen.dart';
import 'package:ventro_app/features/inventario/widgets/ajuste_rapido_sheet.dart';
import 'package:ventro_app/features/inventario/widgets/detalle_stock_list.dart';
import 'package:ventro_app/features/inventario/widgets/movimiento_card.dart';
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
  final _buscarMovimientosCtrl = TextEditingController();

  List<SucursalModel> _sucursales = [];
  int? _sucursalSeleccionadaId;
  String? _sucursalNombreFijo;
  bool _esAdmin = false;
  bool _loadingSucursales = true;

  late final List<VntlMesOption> _meses;
  String? _mesSeleccionado;

  @override
  void initState() {
    super.initState();
    _meses = generarUltimosMeses();
    _inicializar();
  }

  @override
  void dispose() {
    _buscarMovimientosCtrl.dispose();
    super.dispose();
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
    await showDialog<bool>(
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
    // El controller ya se refresca internamente tras guardar.
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
            content: VntlSucursalSearchList(sucursales: _sucursales),
          ),
        ),
      ),
    );

    if (seleccion != null) {
      await _onSucursalChanged(seleccion);
    }
  }

  Future<void> _abrirSelectorMes() async {
    final seleccion = await showDialog<String?>(
      context: context,
      builder: (dialogContext) => Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 80),
          child: VntlModal(
            title: 'Seleccionar mes',
            content: VntlMesSearchList(meses: _meses),
          ),
        ),
      ),
    );

    if (seleccion == 'TODOS') {
      setState(() => _mesSeleccionado = null);
      await _controller.filtrarMovimientosPorMes(null);
    } else if (seleccion != null) {
      setState(() => _mesSeleccionado = seleccion);
      await _controller.filtrarMovimientosPorMes(seleccion);
    }
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
            content: DetalleStockList(items: items),
          ),
        ),
      ),
    );
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

  Widget _buildBuscadorMovimientos(dynamic colors, InventarioController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Buscar producto o SKU',
            style: VntlText.labelSmall.copyWith(color: colors.textSecondary)),
        const SizedBox(height: VntlSpacing.xs),
        VntlInput(
          hint: 'Nombre o SKU...',
          controller: _buscarMovimientosCtrl,
          prefixIcon: Icons.search_rounded,
          onChanged: (v) => controller.buscarMovimientos(v),
        ),
      ],
    );
  }

  Widget _buildSelectorMesMovimientos(dynamic colors) {
    final labelActual = _mesSeleccionado == null
        ? 'Todas las fechas'
        : _meses
            .firstWhere(
              (m) => m.value == _mesSeleccionado,
              orElse: () => _meses.first,
            )
            .label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mes', style: VntlText.labelSmall.copyWith(color: colors.textSecondary)),
        const SizedBox(height: VntlSpacing.xs),
        GestureDetector(
          onTap: _abrirSelectorMes,
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
                Expanded(child: Text(labelActual, style: VntlText.body)),
                Icon(Icons.calendar_month_rounded, color: colors.textSecondary, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFiltrosMovimientos(dynamic colors, InventarioController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        final campos = [
          _buildBuscadorMovimientos(colors, controller),
          _buildSelectorMesMovimientos(colors),
        ];

        if (isMobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < campos.length; i++) ...[
                if (i > 0) const SizedBox(height: VntlSpacing.md),
                campos[i],
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < campos.length; i++) ...[
              if (i > 0) const SizedBox(width: VntlSpacing.md),
              Expanded(flex: i == 0 ? 2 : 1, child: campos[i]),
            ],
          ],
        );
      },
    );
  }

  Widget _buildMovimientosTabla(dynamic colors, InventarioController controller,
      List<MovimientoInventarioModel> movimientosLimitados) {
    return LayoutBuilder(
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
            for (final m in movimientosLimitados) MovimientoCard(movimiento: m),
          ],
        );
      },
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
                    child: Text('Ver todos', style: VntlText.label.copyWith(color: colors.primary)),
                  ),
              ],
            ),
            const SizedBox(height: VntlSpacing.md),
            _buildFiltrosMovimientos(colors, controller),
            const SizedBox(height: VntlSpacing.md),
            if (controller.movimientosError != null)
              Text(
                controller.movimientosError!,
                style: VntlText.body.copyWith(color: colors.error),
              )
            else
              _buildMovimientosTabla(colors, controller, movimientosLimitados),
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
