import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/auth/controllers/auth_controller.dart';
import 'package:ventro_app/features/auth/models/auth_model.dart';
import 'package:ventro_app/features/inventario/controllers/inventario_controller.dart';
import 'package:ventro_app/features/inventario/models/movimiento_inventario_model.dart';
import 'package:ventro_app/features/inventario/widgets/ajuste_rapido_sheet.dart';
import 'package:ventro_app/features/settings/models/sucursal_model.dart';
import 'package:ventro_app/features/settings/services/settings_service.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key});

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
    _controller = InventarioController();
    _inicializar();
  }

  Future<void> _inicializar() async {
    final user = context.read<AuthController>().user;
    _esAdmin = user?.role == UserRole.admin;

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
            content: ChangeNotifierProvider.value(
              value: _controller,
              child: const AjusteRapidoSheet(),
            ),
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

    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: _loadingSucursales
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(VntlSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(colors),
                      const SizedBox(height: VntlSpacing.lg),
                      if (_esAdmin) _buildSucursalSelector(colors),
                      const SizedBox(height: VntlSpacing.xl),
                      _buildStatsCards(colors),
                      const SizedBox(height: VntlSpacing.xl),
                      _buildMovimientosTable(colors),
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
                'Gestión de existencias y movimientos de inventario.',
                style: VntlText.body.copyWith(color: colors.textSecondary),
              ),
            ],
          ),
        ),
        VntlButton(
          label: 'Ajuste rápido',
          icon: Icons.tune_rounded,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sucursal', style: VntlText.labelSmall.copyWith(color: colors.textSecondary)),
        const SizedBox(height: VntlSpacing.xs),
        GestureDetector(
          onTap: soloUnaSucursal ? null : _abrirSelectorSucursal,
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
                  child: Text(nombreActual, style: VntlText.body),
                ),
                if (!soloUnaSucursal) Icon(Icons.arrow_drop_down, color: colors.textSecondary),
              ],
            ),
          ),
        ),
      ],
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

        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 700;
            final cards = [
              _buildStatCard(
                colors,
                label: 'Productos Activos',
                value: '${controller.totalProductos}',
                icon: Icons.inventory_2_outlined,
                iconColor: colors.primary,
              ),
              _buildStatCard(
                colors,
                label: 'Valor del inventario',
                value: r'$0.00',
                icon: Icons.attach_money_rounded,
                iconColor: colors.success,
              ),
              _buildStatCard(
                colors,
                label: 'Alertas de Stock Bajo',
                value: '${controller.alertasStockBajo}',
                icon: Icons.warning_amber_rounded,
                iconColor: colors.warning,
              ),
              _buildStatCard(
                colors,
                label: 'Productos Agotados',
                value: '${controller.productosAgotados}',
                icon: Icons.block_rounded,
                iconColor: colors.error,
              ),
            ];

            if (isMobile) {
              return Column(
                children: cards
                    .map((c) =>
                        Padding(padding: const EdgeInsets.only(bottom: VntlSpacing.md), child: c))
                    .toList(),
              );
            }

            return Row(
              children: cards
                  .map((c) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: VntlSpacing.md),
                          child: c,
                        ),
                      ))
                  .toList(),
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(
    dynamic colors, {
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(VntlSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: VntlRadius.lgBorderRadius,
        border: Border.all(color: colors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: VntlText.labelSmall.copyWith(color: colors.textSecondary)),
          const SizedBox(height: VntlSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: VntlText.h2),
              Icon(icon, color: iconColor, size: 26),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMovimientosTable(dynamic colors) {
    return Consumer<InventarioController>(
      builder: (context, controller, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Historial de movimientos', style: VntlText.h4),
            const SizedBox(height: VntlSpacing.md),
            if (controller.movimientosError != null)
              Text(
                controller.movimientosError!,
                style: VntlText.body.copyWith(color: colors.error),
              )
            else
              VntlTable<MovimientoInventarioModel>(
                isLoading: controller.isLoadingMovimientos,
                items: controller.movimientos,
                emptyLabel: 'Sin movimientos registrados',
                columns: [
                  VntlTableColumn(
                    label: 'Fecha',
                    flex: 2,
                    cellBuilder: (m) => Text(
                      _formatFecha(m.createdAt),
                      style: VntlText.body.copyWith(color: colors.textSecondary),
                    ),
                  ),
                  VntlTableColumn(
                    label: 'Variante',
                    flex: 2,
                    cellBuilder: (m) => Text(m.varianteNombre ?? '—', style: VntlText.body),
                  ),
                  VntlTableColumn(
                    label: 'Sucursal',
                    flex: 2,
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
                      variant: m.type == MovimientoType.in_
                          ? VntlBadgeVariant.success
                          : VntlBadgeVariant.error,
                    ),
                  ),
                  VntlTableColumn(
                    label: 'Usuario',
                    flex: 2,
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
              ),
          ],
        );
      },
    );
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
