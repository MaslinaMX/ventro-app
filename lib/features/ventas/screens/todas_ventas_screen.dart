import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/auth/controllers/auth_controller.dart';
import 'package:ventro_app/features/auth/models/user_model.dart';
import 'package:ventro_app/features/settings/models/sucursal_model.dart';
import 'package:ventro_app/features/settings/services/settings_service.dart';
import 'package:ventro_app/features/ventas/controllers/todas_ventas_controller.dart';
import 'package:ventro_app/features/ventas/models/resumen_ventas_admin_model.dart';
import 'package:ventro_app/features/ventas/models/venta_admin_model.dart';

class TodasVentasScreen extends StatefulWidget {
  const TodasVentasScreen({super.key});

  @override
  State<TodasVentasScreen> createState() => _TodasVentasScreenState();
}

class _TodasVentasScreenState extends State<TodasVentasScreen> {
  final SettingsService _settingsService = SettingsService();
  final _buscarCtrl = TextEditingController();

  bool _esAdminEmpresa = false;
  List<SucursalModel> _sucursales = [];
  int? _sucursalSeleccionadaId;

  late final List<_MesOption> _meses;
  String? _mesSeleccionado;

  @override
  void initState() {
    super.initState();
    _meses = _generarUltimosMeses();
    WidgetsBinding.instance.addPostFrameCallback((_) => _inicializar());
  }

  @override
  void dispose() {
    _buscarCtrl.dispose();
    super.dispose();
  }

  List<_MesOption> _generarUltimosMeses() {
    const nombres = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    final ahora = DateTime.now();
    return List.generate(12, (i) {
      final fecha = DateTime(ahora.year, ahora.month - i, 1);
      final valor = '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}';
      return _MesOption(value: valor, label: '${nombres[fecha.month - 1]} ${fecha.year}');
    });
  }

  Future<void> _inicializar() async {
    final user = context.read<AuthController>().user;
    _esAdminEmpresa = user?.role == UserRole.adminEmpresa;

    if (_esAdminEmpresa) {
      try {
        _sucursales = await _settingsService.getSucursales();
      } catch (_) {
        _sucursales = [];
      }
      if (mounted) setState(() {});
    }

    await context.read<TodasVentasController>().cargarVentas();
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

    if (seleccion == -1) {
      setState(() => _sucursalSeleccionadaId = null);
      await context.read<TodasVentasController>().filtrarPorSucursal(null);
    } else if (seleccion != null) {
      setState(() => _sucursalSeleccionadaId = seleccion);
      await context.read<TodasVentasController>().filtrarPorSucursal(seleccion);
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
            content: _MesSearchListConTodos(meses: _meses),
          ),
        ),
      ),
    );

    if (seleccion == 'TODOS') {
      setState(() => _mesSeleccionado = null);
      await context.read<TodasVentasController>().filtrarPorMes(null);
    } else if (seleccion != null) {
      setState(() => _mesSeleccionado = seleccion);
      await context.read<TodasVentasController>().filtrarPorMes(seleccion);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ctrl = context.watch<TodasVentasController>();

    return Padding(
      padding: const EdgeInsets.all(VntlSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResumenRow(colors, ctrl.resumen),
          const SizedBox(height: VntlSpacing.xl),
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 700;
              final buscador = _buildBuscadorTicket(colors, ctrl);
              final selectorSucursal = _esAdminEmpresa ? _buildSelectorSucursal(colors) : null;
              final selectorMes = _buildSelectorMes(colors);

              final campos = [
                buscador,
                if (selectorSucursal != null) selectorSucursal,
                selectorMes,
              ];

              if (isMobile) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < campos.length; i++) ...[
                      if (i > 0) const SizedBox(height: VntlSpacing.lg),
                      campos[i],
                    ],
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < campos.length; i++) ...[
                    if (i > 0) const SizedBox(width: VntlSpacing.lg),
                    Expanded(
                      flex: i == 0 ? 2 : 1,
                      child: campos[i],
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: VntlSpacing.xl),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colors.glassSurface,
                borderRadius: VntlRadius.lgBorderRadius,
                border: Border.all(color: colors.border, width: 0.5),
              ),
              child: SingleChildScrollView(
                child: VntlTable<VentaAdminModel>(
                  isLoading: ctrl.cargando,
                  items: ctrl.ventas,
                  emptyLabel: ctrl.errorMessage ?? 'Sin ventas registradas',
                  columns: [
                    VntlTableColumn(
                      label: 'Ticket',
                      flex: 2,
                      sortValue: (v) => v.numeroTicketCompleto,
                      cellBuilder: (v) => Text(v.numeroTicketCompleto, style: VntlText.body),
                    ),
                    VntlTableColumn(
                      label: 'Fecha',
                      flex: 2,
                      sortValue: (v) => v.id,
                      cellBuilder: (v) =>
                          Text(v.fecha, style: VntlText.body.copyWith(color: colors.textSecondary)),
                    ),
                    VntlTableColumn(
                      label: 'Sucursal',
                      flex: 2,
                      cellBuilder: (v) => Text(v.sucursal,
                          style: VntlText.body.copyWith(color: colors.textSecondary)),
                    ),
                    VntlTableColumn(
                      label: 'Cajero',
                      flex: 2,
                      sortValue: (v) => v.cajero,
                      cellBuilder: (v) => Text(v.cajero,
                          style: VntlText.body.copyWith(color: colors.textSecondary)),
                    ),
                    VntlTableColumn(
                      label: 'Estado',
                      flex: 1,
                      sortValue: (v) => v.estado,
                      cellBuilder: (v) => Text(
                        v.estado,
                        style: VntlText.caption.copyWith(
                          color: v.estado == 'completada' ? colors.success : colors.error,
                        ),
                      ),
                    ),
                    VntlTableColumn(
                      label: 'Total',
                      flex: 1,
                      cellBuilder: (v) => Text(
                        '\$${v.total.toStringAsFixed(2)}',
                        style: VntlText.label,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenRow(dynamic colors, ResumenVentasAdminModel? resumen) {
    if (resumen == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Ventas',
            cantidad: resumen.ventasCount,
            total: resumen.ventasTotal,
            color: colors.success,
            icon: Icons.check_circle_rounded,
          ),
        ),
        const SizedBox(width: VntlSpacing.md),
        Expanded(
          child: _StatCard(
            label: 'Canceladas',
            cantidad: resumen.canceladasCount,
            total: resumen.canceladasTotal,
            color: colors.error,
            icon: Icons.cancel_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildBuscadorTicket(dynamic colors, TodasVentasController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Buscar por ticket', style: VntlText.labelSmall.copyWith(color: colors.textSecondary)),
        const SizedBox(height: VntlSpacing.xs),
        VntlInput(
          hint: 'Número de ticket...',
          controller: _buscarCtrl,
          prefixIcon: Icons.search_rounded,
          onChanged: (v) => ctrl.buscarPorTicket(v),
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

  Widget _buildSelectorMes(dynamic colors) {
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
}

class _StatCard extends StatelessWidget {
  final String label;
  final int cantidad;
  final double total;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.cantidad,
    required this.total,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(VntlSpacing.lg),
      decoration: BoxDecoration(
        color: colors.glassSurface,
        borderRadius: VntlRadius.lgBorderRadius,
        border: Border.all(color: colors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: VntlRadius.mdBorderRadius,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: VntlSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$label ($cantidad)',
                    style: VntlText.caption.copyWith(color: colors.textTertiary)),
                const SizedBox(height: 2),
                Text('\$${total.toStringAsFixed(2)}', style: VntlText.h4.copyWith(color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MesOption {
  final String value; // 'YYYY-MM'
  final String label; // ej. 'Julio 2026'

  const _MesOption({required this.value, required this.label});
}

class _MesSearchListConTodos extends StatelessWidget {
  const _MesSearchListConTodos({required this.meses});

  final List<_MesOption> meses;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(Icons.all_inclusive_rounded, color: colors.textSecondary),
          title: Text('Todas las fechas', style: VntlText.body),
          onTap: () => Navigator.pop(context, 'TODOS'),
        ),
        Divider(color: colors.border, height: 0.5),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 320),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: meses.length,
            itemBuilder: (_, i) {
              final m = meses[i];
              return ListTile(
                title: Text(m.label, style: VntlText.body),
                onTap: () => Navigator.pop(context, m.value),
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
