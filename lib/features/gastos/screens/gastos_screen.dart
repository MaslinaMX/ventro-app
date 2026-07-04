import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/auth/controllers/auth_controller.dart';
import 'package:ventro_app/features/auth/models/user_model.dart';
import 'package:ventro_app/features/settings/models/sucursal_model.dart';
import 'package:ventro_app/features/settings/services/settings_service.dart';

import '../controllers/gasto_controller.dart';
import '../models/gasto_model.dart';
import '../widgets/gasto_form_modal.dart';

class GastosScreen extends StatefulWidget {
  const GastosScreen({super.key});

  @override
  State<GastosScreen> createState() => _GastosScreenState();
}

class _GastosScreenState extends State<GastosScreen> {
  late GastoController _controller;
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
    _controller = context.read<GastoController>();
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

    await _controller.cargarGastos(sucursalId: _sucursalSeleccionadaId);
  }

  Future<void> _onSucursalChanged(int? sucursalId) async {
    if (sucursalId == null) return;
    setState(() => _sucursalSeleccionadaId = sucursalId);
    await _controller.cargarGastos(sucursalId: sucursalId);
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

  String _formatMonto(double monto) {
    final partes = monto.toStringAsFixed(2).split('.');
    final entero = partes[0];
    final buffer = StringBuffer();
    for (int i = 0; i < entero.length; i++) {
      if (i > 0 && (entero.length - i) % 3 == 0) buffer.write(',');
      buffer.write(entero[i]);
    }
    return '\$${buffer.toString()}.${partes[1]}';
  }

  String _formatFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    return '$dia/$mes/${fecha.year}';
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
                      _buildTotalCard(colors),
                      const SizedBox(height: VntlSpacing.xl),
                      _buildGastosList(colors),
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
              Text('Gastos', style: VntlText.h2),
              const SizedBox(height: VntlSpacing.xs),
              Text(
                'Control de egresos del negocio',
                style: VntlText.body.copyWith(color: colors.textSecondary),
              ),
            ],
          ),
        ),
        VntlButton(
          label: 'Nuevo gasto',
          icon: Icons.add_rounded,
          fullWidth: false,
          size: VntlButtonSize.sm,
          onPressed: _sucursalSeleccionadaId == null
              ? null
              : () async {
                  final creado = await abrirFormularioGasto(
                    context,
                    sucursalId: _sucursalSeleccionadaId!,
                  );
                  if (creado == true && mounted) {
                    await _controller.cargarGastos(sucursalId: _sucursalSeleccionadaId);
                  }
                },
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

  Widget _buildTotalCard(dynamic colors) {
    return Consumer<GastoController>(
      builder: (context, controller, _) {
        if (controller.isLoadingGastos && controller.gastos.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage != null) {
          return Text(controller.errorMessage!, style: VntlText.body.copyWith(color: colors.error));
        }

        final total = controller.gastos.fold<double>(0, (sum, g) => sum + g.monto);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(VntlSpacing.md),
          decoration: BoxDecoration(
            color: colors.errorSurface,
            borderRadius: VntlRadius.mdBorderRadius,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total registrado',
                style: VntlText.caption.copyWith(color: colors.error),
              ),
              const SizedBox(height: 2),
              Text(
                _formatMonto(total),
                style: VntlText.h2.copyWith(color: colors.error),
              ),
              const SizedBox(height: 2),
              Text(
                '${controller.gastos.length} gasto${controller.gastos.length == 1 ? '' : 's'}',
                style: VntlText.caption.copyWith(color: colors.error),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGastosList(dynamic colors) {
    return Consumer<GastoController>(
      builder: (context, controller, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Historial de gastos', style: VntlText.h4),
            const SizedBox(height: VntlSpacing.md),
            if (controller.errorMessage != null)
              Text(
                controller.errorMessage!,
                style: VntlText.body.copyWith(color: colors.error),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final esTablet = constraints.maxWidth >= 700;

                  if (esTablet) {
                    return VntlTable<GastoModel>(
                      isLoading: controller.isLoadingGastos,
                      items: controller.gastos,
                      emptyLabel: 'Sin gastos registrados',
                      columns: [
                        VntlTableColumn(
                          label: 'Fecha',
                          flex: 2,
                          sortValue: (g) => g.fecha,
                          cellBuilder: (g) => Text(
                            _formatFecha(g.fecha),
                            style: VntlText.body.copyWith(color: colors.textSecondary),
                          ),
                        ),
                        VntlTableColumn(
                          label: 'Concepto',
                          flex: 3,
                          cellBuilder: (g) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(g.concepto, style: VntlText.body),
                              if (g.proveedor != null && g.proveedor!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  g.proveedor!,
                                  style: VntlText.caption.copyWith(color: colors.textTertiary),
                                ),
                              ],
                            ],
                          ),
                        ),
                        VntlTableColumn(
                          label: 'Tipo',
                          flex: 2,
                          sortValue: (g) => g.categoriaId,
                          cellBuilder: (g) {
                            final style = VntlGastoIconStyle.forCategoria(
                              context,
                              g.categoriaId,
                              iconoKey: g.categoria?.icono,
                              colorHex: g.categoria?.color,
                            );
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(style.icon, size: 14, color: style.foreground),
                                const SizedBox(width: VntlSpacing.xs),
                                Text(
                                  g.categoria?.nombre ?? '—',
                                  style: VntlText.body.copyWith(color: colors.textSecondary),
                                ),
                              ],
                            );
                          },
                        ),
                        VntlTableColumn(
                          label: 'Método de pago',
                          flex: 2,
                          sortValue: (g) => g.metodoPago?.nombre ?? '',
                          cellBuilder: (g) => Text(
                            g.metodoPago?.nombre ?? '—',
                            style: VntlText.body.copyWith(color: colors.textSecondary),
                          ),
                        ),
                        VntlTableColumn(
                          label: 'Registrado por',
                          flex: 2,
                          cellBuilder: (g) => Text(
                            g.user?.name ?? '—',
                            style: VntlText.body.copyWith(color: colors.textSecondary),
                          ),
                        ),
                        VntlTableColumn(
                          label: 'Monto',
                          flex: 2,
                          sortValue: (g) => g.monto,
                          cellBuilder: (g) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatMonto(g.monto),
                                style: VntlText.label,
                              ),
                              if (g.fueEditado) ...[
                                const SizedBox(width: VntlSpacing.xs),
                                VntlBadge(label: 'Editado', variant: VntlBadgeVariant.warning),
                              ],
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  if (controller.isLoadingGastos) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: VntlSpacing.xl2),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (controller.gastos.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: VntlSpacing.xl2),
                      child: Center(
                        child: Text(
                          'Sin gastos registrados',
                          style: VntlText.body.copyWith(color: colors.textTertiary),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      for (final g in controller.gastos) _GastoCard(gasto: g),
                    ],
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

class _GastoCard extends StatelessWidget {
  const _GastoCard({required this.gasto});

  final GastoModel gasto;

  String _formatFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    return '$dia/$mes/${fecha.year}';
  }

  String _formatMonto(double monto) {
    final partes = monto.toStringAsFixed(2).split('.');
    final entero = partes[0];
    final buffer = StringBuffer();
    for (int i = 0; i < entero.length; i++) {
      if (i > 0 && (entero.length - i) % 3 == 0) buffer.write(',');
      buffer.write(entero[i]);
    }
    return '\$${buffer.toString()}.${partes[1]}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = VntlGastoIconStyle.forCategoria(
      context,
      gasto.categoriaId,
      iconoKey: gasto.categoria?.icono,
      colorHex: gasto.categoria?.color,
    );

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
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: style.background,
                  borderRadius: VntlRadius.smBorderRadius,
                ),
                child: Icon(style.icon, color: style.foreground, size: 16),
              ),
              const SizedBox(width: VntlSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gasto.concepto,
                      style: VntlText.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (gasto.proveedor != null && gasto.proveedor!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        gasto.proveedor!,
                        style: VntlText.caption.copyWith(color: colors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: VntlSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_formatMonto(gasto.monto), style: VntlText.label),
                  if (gasto.fueEditado) ...[
                    const SizedBox(height: 2),
                    VntlBadge(label: 'Editado', variant: VntlBadgeVariant.warning),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: VntlSpacing.sm),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 12, color: colors.textTertiary),
              const SizedBox(width: 4),
              Text(
                _formatFecha(gasto.fecha),
                style: VntlText.caption.copyWith(color: colors.textTertiary),
              ),
              const SizedBox(width: VntlSpacing.md),
              Icon(Icons.payments_rounded, size: 12, color: colors.textTertiary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  gasto.metodoPago?.nombre ?? '—',
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
