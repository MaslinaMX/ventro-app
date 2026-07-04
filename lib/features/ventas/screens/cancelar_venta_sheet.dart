import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/caja/widgets/verificar_empleado_fields.dart';
import 'package:ventro_app/features/metodos_pago/models/metodo_pago_model.dart';
import 'package:ventro_app/features/metodos_pago/services/metodo_pago_service.dart';
import 'package:ventro_app/features/ventas/controllers/venta_controller.dart';
import 'package:ventro_app/features/ventas/models/venta_detalle_model.dart';

class CancelarVentaSheet extends StatefulWidget {
  final VentaDetalleModel venta;
  const CancelarVentaSheet({super.key, required this.venta});

  @override
  State<CancelarVentaSheet> createState() => _CancelarVentaSheetState();
}

class _CancelarVentaSheetState extends State<CancelarVentaSheet> {
  final _formKey = GlobalKey<FormState>();
  final _employeeNumberCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _motivoCtrl = TextEditingController();
  final _montoCtrl = TextEditingController();
  final _metodoPagoService = MetodoPagoService();

  List<MetodoPagoModel> _metodosPago = [];
  MetodoPagoModel? _metodoSeleccionado;
  bool _cargandoMetodos = true;

  // Por cada item: si se devuelve o no a inventario
  late Map<int, bool> _itemsDevueltos;

  @override
  void initState() {
    super.initState();
    // Inicializar todos los items como devueltos por default
    _itemsDevueltos = {
      for (final item in widget.venta.items) item.id: true,
    };
    // Inicializar monto con el total de la venta
    _montoCtrl.text = widget.venta.total.toStringAsFixed(2);
    _cargarMetodos();
  }

  Future<void> _cargarMetodos() async {
    try {
      final metodos = await _metodoPagoService.getMetodosPago();
      setState(() {
        _metodosPago = metodos.where((m) => m.activo).toList();
        _cargandoMetodos = false;
      });
    } catch (_) {
      setState(() => _cargandoMetodos = false);
    }
  }

  @override
  void dispose() {
    _employeeNumberCtrl.dispose();
    _pinCtrl.dispose();
    _motivoCtrl.dispose();
    _montoCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_metodoSeleccionado == null) {
      VntlToast.show(context,
          message: 'Selecciona el método de devolución', type: VntlToastType.error);
      return;
    }

    final ctrl = context.read<VentaController>();
    final ok = await ctrl.cancelarVenta(
      ventaId: widget.venta.id,
      employeeNumber: _employeeNumberCtrl.text.trim(),
      pin: _pinCtrl.text.trim(),
      metodoDevolucionId: _metodoSeleccionado!.id,
      montoDevuelto: double.tryParse(_montoCtrl.text.trim()) ?? widget.venta.total,
      motivo: _motivoCtrl.text.trim().isEmpty ? null : _motivoCtrl.text.trim(),
      itemsDevueltos: widget.venta.items
          .map((item) => {
                'venta_item_id': item.id,
                'devuelto_a_inventario': _itemsDevueltos[item.id] ?? false,
              })
          .toList(),
    );

    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, true);
    } else {
      VntlToast.show(
        context,
        message: ctrl.errorMessage ?? 'Error al cancelar la venta',
        type: VntlToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ctrl = context.watch<VentaController>();

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── PIN ───────────────────────────────────────────────────────
          VerificarEmpleadoFields(
            employeeNumberCtrl: _employeeNumberCtrl,
            pinCtrl: _pinCtrl,
          ),
          const SizedBox(height: VntlSpacing.lg),

          // ─── Items — devolver inventario ───────────────────────────────
          Text('¿Qué productos fueron devueltos?', style: VntlText.label),
          const SizedBox(height: VntlSpacing.sm),
          Container(
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              borderRadius: VntlRadius.smBorderRadius,
            ),
            child: Column(
              children: widget.venta.items.map((item) {
                return CheckboxListTile(
                  dense: true,
                  activeColor: colors.primary,
                  title: Text(
                    '${item.cantidad}x ${item.nombreSnapshot}',
                    style: VntlText.body,
                  ),
                  subtitle: Text(
                    '\$${item.subtotal.toStringAsFixed(2)}',
                    style: VntlText.caption.copyWith(color: colors.textTertiary),
                  ),
                  value: _itemsDevueltos[item.id] ?? false,
                  onChanged: (v) => setState(() => _itemsDevueltos[item.id] = v ?? false),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: VntlSpacing.lg),

          // ─── Método de devolución ──────────────────────────────────────
          Text('Método de devolución', style: VntlText.label),
          const SizedBox(height: VntlSpacing.sm),
          if (_cargandoMetodos)
            const Center(child: CircularProgressIndicator())
          else
            Wrap(
              spacing: VntlSpacing.sm,
              runSpacing: VntlSpacing.sm,
              children: _metodosPago.map((m) {
                final style = VntlPaymentStyle.forMetodo(
                  context,
                  m.id,
                  iconoKey: m.icono,
                  colorHex: m.color,
                );
                final seleccionado = _metodoSeleccionado?.id == m.id;
                return GestureDetector(
                  onTap: () => setState(() => _metodoSeleccionado = m),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: VntlSpacing.md,
                      vertical: VntlSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: seleccionado ? style.background : colors.surfaceSecondary,
                      borderRadius: VntlRadius.smBorderRadius,
                      border: Border.all(
                        color: seleccionado ? style.foreground : colors.border,
                        width: seleccionado ? 1.5 : 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(style.icon, size: 14, color: style.foreground),
                        const SizedBox(width: VntlSpacing.xs),
                        Text(m.nombre, style: VntlText.label.copyWith(color: style.foreground)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: VntlSpacing.lg),

          // ─── Monto devuelto ────────────────────────────────────────────
          VntlInput(
            label: 'Monto a devolver',
            hint: widget.venta.total.toStringAsFixed(2),
            controller: _montoCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: Icons.payments_rounded,
            validator: (v) {
              final n = double.tryParse(v ?? '');
              if (n == null || n <= 0) return 'Ingresa un monto válido';
              return null;
            },
          ),
          const SizedBox(height: VntlSpacing.lg),

          // ─── Motivo (opcional) ─────────────────────────────────────────
          VntlInput(
            label: 'Motivo (opcional)',
            hint: 'Ej. Producto defectuoso...',
            controller: _motivoCtrl,
          ),
          const SizedBox(height: VntlSpacing.xl),

          // ─── Acciones ──────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              VntlButton(
                label: 'Cancelar',
                variant: VntlButtonVariant.ghost,
                onPressed: ctrl.cancelando ? null : () => Navigator.pop(context),
              ),
              const SizedBox(width: VntlSpacing.sm),
              VntlButton(
                label: ctrl.cancelando ? 'Procesando...' : 'Confirmar cancelación',
                loading: ctrl.cancelando,
                variant: VntlButtonVariant.danger,
                onPressed: ctrl.cancelando ? null : _submit,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
