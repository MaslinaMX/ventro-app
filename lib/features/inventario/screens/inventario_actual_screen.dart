import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/inventario/controllers/inventario_controller.dart';
import 'package:ventro_app/features/inventario/models/inventario_stock_model.dart';
import 'package:ventro_app/features/inventario/services/inventario_service.dart';

class InventarioActualScreen extends StatefulWidget {
  const InventarioActualScreen({
    super.key,
    required this.sucursalId,
    required this.sucursalNombre,
  });

  final int sucursalId;
  final String sucursalNombre;

  @override
  State<InventarioActualScreen> createState() => _InventarioActualScreenState();
}

class _InventarioActualScreenState extends State<InventarioActualScreen> {
  final InventarioService _service = InventarioService();
  final _buscarCtrl = TextEditingController();
  String _busqueda = '';
  bool _descargando = false;

  @override
  void dispose() {
    _buscarCtrl.dispose();
    super.dispose();
  }

  List<InventarioStockModel> _filtrar(List<InventarioStockModel> stock) {
    if (_busqueda.isEmpty) return stock;
    final q = _busqueda.toLowerCase();
    return stock.where((s) {
      return s.productoNombre.toLowerCase().contains(q) ||
          s.varianteNombre.toLowerCase().contains(q) ||
          (s.sku?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  Future<void> _descargarPdf() async {
    setState(() => _descargando = true);
    try {
      final bytes = await _service.descargarStockPdf(
        widget.sucursalId,
        search: _busqueda.isEmpty ? null : _busqueda,
      );
      final blob = html.Blob([Uint8List.fromList(bytes)], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', 'inventario-${widget.sucursalNombre}.pdf')
        ..click();
      html.Url.revokeObjectUrl(url);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo descargar el PDF.')),
        );
      }
    } finally {
      if (mounted) setState(() => _descargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final controller = context.watch<InventarioController>();
    final items = _filtrar(controller.stock);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(VntlSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Inventario actual', style: VntlText.h2),
                        Text(widget.sucursalNombre,
                            style: VntlText.body.copyWith(color: colors.textSecondary)),
                      ],
                    ),
                  ),
                  VntlButton(
                    label: _descargando ? 'Generando...' : 'Descargar PDF',
                    icon: Icons.picture_as_pdf_rounded,
                    fullWidth: false,
                    size: VntlButtonSize.sm,
                    loading: _descargando,
                    onPressed: _descargando ? null : _descargarPdf,
                  ),
                ],
              ),
              const SizedBox(height: VntlSpacing.lg),
              Text('Buscar producto o SKU',
                  style: VntlText.labelSmall.copyWith(color: colors.textSecondary)),
              const SizedBox(height: VntlSpacing.xs),
              VntlInput(
                hint: 'Nombre o SKU...',
                controller: _buscarCtrl,
                prefixIcon: Icons.search_rounded,
                onChanged: (v) => setState(() => _busqueda = v),
              ),
              const SizedBox(height: VntlSpacing.lg),
              VntlTable<InventarioStockModel>(
                isLoading: controller.isLoading,
                items: items,
                emptyLabel: 'Sin resultados',
                columns: [
                  VntlTableColumn(
                    label: 'Producto',
                    flex: 3,
                    sortValue: (s) => s.productoNombre,
                    cellBuilder: (s) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(s.productoNombre, style: VntlText.body),
                        if (s.varianteNombre.isNotEmpty)
                          Text(s.varianteNombre,
                              style: VntlText.caption.copyWith(color: colors.textTertiary)),
                      ],
                    ),
                  ),
                  VntlTableColumn(
                    label: 'SKU',
                    flex: 2,
                    sortValue: (s) => s.sku ?? '',
                    cellBuilder: (s) => Text(s.sku ?? '—',
                        style: VntlText.body.copyWith(color: colors.textSecondary)),
                  ),
                  VntlTableColumn(
                    label: 'Cantidad',
                    flex: 1,
                    sortValue: (s) => s.cantidad,
                    cellBuilder: (s) => VntlBadge(
                      label: s.cantidad % 1 == 0
                          ? s.cantidad.toInt().toString()
                          : s.cantidad.toString(),
                      variant: s.cantidad <= 0
                          ? VntlBadgeVariant.error
                          : (s.bajoStock ? VntlBadgeVariant.warning : VntlBadgeVariant.success),
                    ),
                  ),
                  VntlTableColumn(
                    label: 'Mínimo',
                    flex: 1,
                    sortValue: (s) => s.cantidadMinima,
                    cellBuilder: (s) => Text(
                      s.cantidadMinima % 1 == 0
                          ? s.cantidadMinima.toInt().toString()
                          : s.cantidadMinima.toString(),
                      style: VntlText.body.copyWith(color: colors.textSecondary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
