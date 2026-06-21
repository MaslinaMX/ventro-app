import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/inventario/controllers/inventario_controller.dart';
import 'package:ventro_app/features/inventario/models/inventario_stock_model.dart';

class AjusteRapidoSheet extends StatefulWidget {
  const AjusteRapidoSheet({super.key});

  @override
  State<AjusteRapidoSheet> createState() => _AjusteRapidoSheetState();
}

class _AjusteRapidoSheetState extends State<AjusteRapidoSheet> {
  InventarioStockModel? _varianteSeleccionada;
  final _searchController = TextEditingController();
  final _nuevoStockController = TextEditingController();
  final _motivoController = TextEditingController();
  double? _nuevoStock;
  bool _saving = false;
  bool _buscando = false;
  String? _errorNuevoStock;
  String? _errorMotivo;
  List<InventarioStockModel> _resultados = [];

  @override
  void dispose() {
    _searchController.dispose();
    _nuevoStockController.dispose();
    _motivoController.dispose();
    super.dispose();
  }

  double? get _diferencia {
    if (_varianteSeleccionada == null || _nuevoStock == null) return null;
    return _nuevoStock! - _varianteSeleccionada!.cantidad;
  }

  void _filtrar(String query) {
    final controller = context.read<InventarioController>();
    setState(() {
      _buscando = query.isNotEmpty;
      if (query.isEmpty) {
        _resultados = [];
      } else {
        _resultados = controller.stock
            .where((o) =>
                o.varianteNombre.toLowerCase().contains(query.toLowerCase()) ||
                o.productoNombre.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _seleccionarVariante(InventarioStockModel item) {
    setState(() {
      _varianteSeleccionada = item;
      _searchController.text = item.varianteNombre;
      _buscando = false;
      _resultados = [];
      _nuevoStockController.clear();
      _nuevoStock = null;
      _errorNuevoStock = null;
    });
  }

  Future<void> _guardar() async {
    setState(() {
      _errorNuevoStock = null;
      _errorMotivo = null;
    });

    if (_varianteSeleccionada == null) return;

    if (_nuevoStock == null) {
      setState(() => _errorNuevoStock = 'Ingresa el nuevo stock');
      return;
    }

    if (_motivoController.text.trim().isEmpty) {
      setState(() => _errorMotivo = 'El motivo es requerido');
      return;
    }

    if (_diferencia == 0) {
      setState(() => _errorNuevoStock = 'El nuevo stock debe ser diferente al actual');
      return;
    }

    setState(() => _saving = true);

    final controller = context.read<InventarioController>();
    final ok = await controller.registrarAjusteRapido(
      varianteId: _varianteSeleccionada!.varianteId,
      stockActual: _varianteSeleccionada!.cantidad,
      stockNuevo: _nuevoStock!,
      motivo: _motivoController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      Navigator.pop(context, true);
    } else {
      setState(() => _errorNuevoStock = 'No se pudo guardar el ajuste. Intenta de nuevo.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final diferencia = _diferencia;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Producto / Variante',
            style: VntlText.labelSmall.copyWith(color: colors.textSecondary)),
        const SizedBox(height: VntlSpacing.xs),
        VntlInput(
          hint: 'Buscar producto...',
          controller: _searchController,
          prefixIcon: Icons.search,
          suffix: _varianteSeleccionada != null
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _varianteSeleccionada = null;
                      _searchController.clear();
                      _resultados = [];
                      _buscando = false;
                    });
                  },
                  child: Icon(Icons.close, size: 16, color: colors.textTertiary),
                )
              : null,
          onChanged: _filtrar,
        ),
        if (!_buscando) ...[
          const SizedBox(height: VntlSpacing.xs),
          Text(
            'Busque y seleccione el producto a ajustar',
            style: VntlText.caption.copyWith(color: colors.textTertiary),
          ),
        ],
        if (_buscando) _buildResultadosList(colors),
        if (_varianteSeleccionada != null) ...[
          const SizedBox(height: VntlSpacing.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Stock Actual',
                        style: VntlText.labelSmall.copyWith(color: colors.textSecondary)),
                    const SizedBox(height: VntlSpacing.xs),
                    Text(
                      _formatCantidad(_varianteSeleccionada!.cantidad),
                      style: VntlText.h3,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Movimiento',
                      style: VntlText.labelSmall.copyWith(color: colors.textSecondary)),
                  const SizedBox(height: VntlSpacing.xs),
                  _buildMovimientoBadge(diferencia),
                ],
              ),
            ],
          ),
          const SizedBox(height: VntlSpacing.lg),
          VntlInput(
            label: 'Nuevo Stock *',
            hint: '0',
            controller: _nuevoStockController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            error: _errorNuevoStock,
            onChanged: (value) {
              setState(() {
                _nuevoStock = double.tryParse(value);
                _errorNuevoStock = null;
              });
            },
          ),
          const SizedBox(height: VntlSpacing.xs),
          Text(
            'Ingrese el nuevo stock después del ajuste',
            style: VntlText.caption.copyWith(color: colors.textTertiary),
          ),
          const SizedBox(height: VntlSpacing.lg),
          VntlInput(
            label: 'Motivo del ajuste *',
            hint: 'Ej. Conteo físico, producto dañado, etc.',
            controller: _motivoController,
            maxLines: 2,
            error: _errorMotivo,
            onChanged: (_) {
              if (_errorMotivo != null) setState(() => _errorMotivo = null);
            },
          ),
        ],
        const SizedBox(height: VntlSpacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            VntlButton(
              label: 'Cancelar',
              variant: VntlButtonVariant.danger,
              onPressed: _saving ? null : () => Navigator.pop(context),
            ),
            const SizedBox(width: VntlSpacing.sm),
            VntlButton(
              label: 'Guardar Ajuste',
              variant: VntlButtonVariant.primary,
              loading: _saving,
              onPressed: _varianteSeleccionada == null ? null : _guardar,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultadosList(dynamic colors) {
    return Container(
      margin: const EdgeInsets.only(top: VntlSpacing.xs),
      constraints: const BoxConstraints(maxHeight: 240),
      decoration: BoxDecoration(
        color: colors.glassSurface,
        borderRadius: VntlRadius.mdBorderRadius,
        border: Border.all(color: colors.border, width: 0.5),
      ),
      child: _resultados.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(VntlSpacing.lg),
              child: Text(
                'Sin resultados',
                style: VntlText.body.copyWith(color: colors.textTertiary),
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: VntlSpacing.xs),
              itemCount: _resultados.length,
              itemBuilder: (_, i) {
                final item = _resultados[i];
                return ListTile(
                  dense: true,
                  title: Text(item.varianteNombre, style: VntlText.body),
                  subtitle: Text(
                    item.productoNombre,
                    style: VntlText.caption.copyWith(color: colors.textTertiary),
                  ),
                  trailing: Text(
                    _formatCantidad(item.cantidad),
                    style: VntlText.body.copyWith(color: colors.textSecondary),
                  ),
                  onTap: () => _seleccionarVariante(item),
                );
              },
            ),
    );
  }

  String _formatCantidad(double cantidad) {
    return cantidad % 1 == 0 ? cantidad.toInt().toString() : cantidad.toString();
  }

  Widget _buildMovimientoBadge(double? diferencia) {
    if (diferencia == null || diferencia == 0) {
      return const VntlBadge(label: '--', variant: VntlBadgeVariant.neutral);
    }

    final esEntrada = diferencia > 0;
    final cantidadStr = _formatCantidad(diferencia.abs());

    return VntlBadge(
      label: esEntrada ? 'Entrada +$cantidadStr' : 'Salida -$cantidadStr',
      variant: esEntrada ? VntlBadgeVariant.success : VntlBadgeVariant.error,
    );
  }
}
