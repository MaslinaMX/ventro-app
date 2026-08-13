import 'package:flutter/material.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/clientes/models/cliente_estadisticas_model.dart';
import 'package:ventro_app/features/clientes/services/cliente_service.dart';
import 'package:ventro_app/features/ventas/screens/venta_detalle_screen.dart';

class ClienteDetalleScreen extends StatefulWidget {
  const ClienteDetalleScreen({super.key, required this.clienteId});

  final int clienteId;

  @override
  State<ClienteDetalleScreen> createState() => _ClienteDetalleScreenState();
}

class _ClienteDetalleScreenState extends State<ClienteDetalleScreen> {
  final _service = ClienteService();
  ClienteEstadisticasModel? _datos;
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final datos = await _service.getEstadisticas(widget.clienteId);
      if (!mounted) return;
      setState(() {
        _datos = datos;
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudieron cargar los datos del cliente';
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: context.backgroundGradient),
        child: Column(
          children: [
            VntlAppBar(
              title: _datos?.clienteNombre ?? 'Cliente',
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.arrow_back_rounded, color: colors.textSecondary, size: 20),
              ),
            ),
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Text(_error!, style: VntlText.body.copyWith(color: colors.error)),
                        )
                      : Align(
                          alignment: Alignment.topCenter,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(VntlSpacing.xl),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 720),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _StatsGrid(datos: _datos!),
                                  const SizedBox(height: VntlSpacing.xl),
                                  Text('Historial de compras', style: VntlText.h4),
                                  const SizedBox(height: VntlSpacing.md),
                                  _ListaCompras(compras: _datos!.compras),
                                ],
                              ),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.datos});

  final ClienteEstadisticasModel datos;

  @override
  Widget build(BuildContext context) {
    final cancelaciones = datos.compras.where((c) => c.estado == 'cancelada').length;

    return Wrap(
      spacing: VntlSpacing.md,
      runSpacing: VntlSpacing.md,
      children: [
        _StatCard(
          icon: Icons.payments_rounded,
          accent: _StatAccent.primary,
          label: 'Total gastado',
          value: '\$${datos.totalGastado.toStringAsFixed(2)}',
        ),
        _StatCard(
          icon: Icons.receipt_long_rounded,
          accent: _StatAccent.success,
          label: 'Compras',
          value: '${datos.numeroCompras}',
        ),
        _StatCard(
          icon: Icons.trending_up_rounded,
          accent: _StatAccent.warning,
          label: 'Promedio por compra',
          value: '\$${datos.promedioCompra.toStringAsFixed(2)}',
        ),
        _StatCard(
          icon: Icons.event_rounded,
          accent: _StatAccent.neutral,
          label: 'Última compra',
          value: datos.ultimaCompra ?? '—',
        ),
        _StatCard(
          icon: Icons.favorite_rounded,
          accent: _StatAccent.error,
          label: 'Producto favorito',
          value: datos.productoFavorito ?? '—',
        ),
        _StatCard(
          icon: Icons.cancel_outlined,
          accent: _StatAccent.error,
          label: 'Cancelaciones',
          value: '$cancelaciones',
        ),
      ],
    );
  }
}

enum _StatAccent { primary, success, warning, error, neutral }

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.accent,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final _StatAccent accent;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final Color iconBg;
    final Color iconFg;
    switch (accent) {
      case _StatAccent.primary:
        iconBg = colors.primarySurface;
        iconFg = colors.primary;
        break;
      case _StatAccent.success:
        iconBg = colors.successSurface;
        iconFg = colors.success;
        break;
      case _StatAccent.warning:
        iconBg = colors.warningSurface;
        iconFg = colors.warning;
        break;
      case _StatAccent.error:
        iconBg = colors.errorSurface;
        iconFg = colors.error;
        break;
      case _StatAccent.neutral:
        iconBg = colors.surfaceSecondary;
        iconFg = colors.textSecondary;
        break;
    }

    return Container(
      width: 220,
      padding: const EdgeInsets.all(VntlSpacing.lg),
      decoration: BoxDecoration(
        color: colors.glassSurface,
        borderRadius: VntlRadius.lgBorderRadius,
        border: Border.all(color: colors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: VntlRadius.mdBorderRadius,
            ),
            child: Icon(icon, color: iconFg, size: 18),
          ),
          const SizedBox(height: VntlSpacing.md),
          Text(label, style: VntlText.caption.copyWith(color: colors.textTertiary)),
          const SizedBox(height: VntlSpacing.xs),
          Text(
            value,
            style: VntlText.h4.copyWith(color: colors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ListaCompras extends StatelessWidget {
  const _ListaCompras({required this.compras});

  final List<CompraResumenModel> compras;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return VntlTable<CompraResumenModel>(
      isLoading: false,
      items: compras,
      emptyLabel: 'Este cliente aún no tiene compras registradas.',
      columns: [
        VntlTableColumn<CompraResumenModel>(
          label: 'Ticket',
          flex: 2,
          sortValue: (c) => c.numeroTicketCompleto,
          cellBuilder: (c) => Text(c.numeroTicketCompleto, style: VntlText.label),
        ),
        VntlTableColumn<CompraResumenModel>(
          label: 'Fecha',
          flex: 2,
          sortValue: (c) => c.fecha,
          cellBuilder: (c) => Text(
            c.fecha,
            style: VntlText.body.copyWith(color: colors.textSecondary),
          ),
        ),
        VntlTableColumn<CompraResumenModel>(
          label: 'Estado',
          flex: 1,
          sortValue: (c) => c.estado,
          cellBuilder: (c) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: c.estado == 'cancelada' ? colors.errorSurface : colors.successSurface,
              borderRadius: VntlRadius.smBorderRadius,
            ),
            child: Text(
              c.estado.toUpperCase(),
              style: VntlText.caption.copyWith(
                color: c.estado == 'cancelada' ? colors.error : colors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        VntlTableColumn<CompraResumenModel>(
          label: 'Total',
          flex: 1,
          sortValue: (c) => c.total,
          cellBuilder: (c) => Text(
            '\$${c.total.toStringAsFixed(2)}',
            style: VntlText.label.copyWith(color: colors.primary),
          ),
        ),
        VntlTableColumn<CompraResumenModel>(
          label: '',
          flex: 1,
          alignment: Alignment.centerRight,
          cellBuilder: (c) => VntlButton(
            label: null,
            variant: VntlButtonVariant.secondary,
            size: VntlButtonSize.sm,
            icon: Icons.visibility_rounded,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => VentaDetalleScreen(ventaId: c.id)),
            ),
          ),
        ),
      ],
    );
  }
}
