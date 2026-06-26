import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/gastos/controllers/categoria_gasto_controller.dart';
import 'package:ventro_app/features/metodos_pago/controllers/metodo_pago_controller.dart';
import 'package:ventro_app/features/metodos_pago/models/metodo_pago_model.dart';

import '../controllers/gasto_controller.dart';
import '../models/categoria_gasto_model.dart';
import '../models/gasto_model.dart';

/// Abre el modal de captura de un gasto nuevo para [sucursalId].
/// Devuelve `true` si el gasto se creó correctamente.
Future<bool?> abrirFormularioGasto(BuildContext context, {required int sucursalId}) {
  return VntlModal.show<bool>(
    context,
    title: 'Nuevo gasto',
    width: 480,
    content: _GastoFormContent(sucursalId: sucursalId),
  );
}

class _GastoFormContent extends StatefulWidget {
  const _GastoFormContent({required this.sucursalId});

  final int sucursalId;

  @override
  State<_GastoFormContent> createState() => _GastoFormContentState();
}

class _GastoFormContentState extends State<_GastoFormContent> {
  final _conceptoCtrl = TextEditingController();
  final _montoCtrl = TextEditingController();
  final _proveedorCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();

  CategoriaGastoModel? _categoriaSeleccionada;
  MetodoPagoModel? _metodoPagoSeleccionado;
  DateTime _fechaSeleccionada = DateTime.now();

  String? _conceptoError;
  String? _montoError;
  String? _categoriaError;
  String? _metodoPagoError;

  bool _cargado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_cargado) {
      _cargado = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final categoriaCtrl = context.read<CategoriaGastoController>();
        final metodoPagoCtrl = context.read<MetodoPagoController>();
        if (categoriaCtrl.categorias.isEmpty) categoriaCtrl.cargarCategorias();
        if (metodoPagoCtrl.metodosPago.isEmpty) metodoPagoCtrl.loadMetodosPago();
      });
    }
  }

  @override
  void dispose() {
    _conceptoCtrl.dispose();
    _montoCtrl.dispose();
    _proveedorCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarCategoria() async {
    final categoriaCtrl = context.read<CategoriaGastoController>();
    final colors = context.colors;

    final seleccion = await VntlModal.show<CategoriaGastoModel>(
      context,
      title: 'Selecciona un tipo de gasto',
      width: 420,
      content: categoriaCtrl.categorias.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: VntlSpacing.md),
              child: Text(
                'Aún no tienes tipos de gasto. Créalos primero en Configuración.',
                style: VntlText.body.copyWith(color: colors.textSecondary),
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final categoria in categoriaCtrl.categorias)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Builder(
                      builder: (context) {
                        final style = VntlGastoIconStyle.forCategoria(
                          context,
                          categoria.id,
                          iconoKey: categoria.icono,
                          colorHex: categoria.color,
                        );
                        return Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: style.background,
                            borderRadius: VntlRadius.smBorderRadius,
                          ),
                          child: Icon(style.icon, color: style.foreground, size: 16),
                        );
                      },
                    ),
                    title: Text(categoria.nombre, style: VntlText.body),
                    onTap: () => Navigator.pop(context, categoria),
                  ),
              ],
            ),
    );

    if (seleccion != null) {
      setState(() {
        _categoriaSeleccionada = seleccion;
        _categoriaError = null;
      });
    }
  }

  Future<void> _seleccionarMetodoPago() async {
    final metodoPagoCtrl = context.read<MetodoPagoController>();
    final colors = context.colors;

    final activos = metodoPagoCtrl.metodosPago.where((m) => m.activo).toList();

    final seleccion = await VntlModal.show<MetodoPagoModel>(
      context,
      title: 'Selecciona un método de pago',
      width: 420,
      content: activos.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: VntlSpacing.md),
              child: Text(
                'No tienes métodos de pago activos.',
                style: VntlText.body.copyWith(color: colors.textSecondary),
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final metodo in activos)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(metodo.nombre, style: VntlText.body),
                    onTap: () => Navigator.pop(context, metodo),
                  ),
              ],
            ),
    );

    if (seleccion != null) {
      setState(() {
        _metodoPagoSeleccionado = seleccion;
        _metodoPagoError = null;
      });
    }
  }

  Future<void> _seleccionarFecha() async {
    final seleccion = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (seleccion != null) {
      setState(() => _fechaSeleccionada = seleccion);
    }
  }

  String _formatFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    return '$dia/$mes/${fecha.year}';
  }

  /// Confirma con el usuario que el gasto no podrá editarse libremente
  /// después (solo admin con motivo) ni borrarse nunca. Devuelve true
  /// si el usuario aceptó continuar.
  Future<bool> _confirmarIrreversible() async {
    final confirmado = await VntlDialog.confirm(
      context,
      title: 'Confirmar registro de gasto',
      message: 'Una vez guardado, este gasto no se puede eliminar. Solo un administrador '
          'podrá editarlo más adelante, y deberá indicar un motivo. ¿Deseas continuar?',
      confirmLabel: 'Registrar gasto',
      destructive: false,
    );
    return confirmado == true;
  }

  Future<void> _guardar() async {
    final gastoCtrl = context.read<GastoController>();
    if (gastoCtrl.isSaving) return;

    final monto = double.tryParse(_montoCtrl.text.trim().replaceAll(',', ''));

    setState(() {
      _conceptoError = _conceptoCtrl.text.trim().isEmpty ? 'El concepto es requerido' : null;
      _montoError = (monto == null || monto <= 0) ? 'Captura un monto válido' : null;
      _categoriaError = _categoriaSeleccionada == null ? 'Selecciona un tipo de gasto' : null;
      _metodoPagoError = _metodoPagoSeleccionado == null ? 'Selecciona un método de pago' : null;
    });

    if (_conceptoError != null ||
        _montoError != null ||
        _categoriaError != null ||
        _metodoPagoError != null) {
      return;
    }

    final acepto = await _confirmarIrreversible();
    if (!acepto || !mounted) return;

    final nuevoGasto = GastoModel(
      id: 0,
      sucursalId: widget.sucursalId,
      categoriaId: _categoriaSeleccionada!.id,
      metodoPagoId: _metodoPagoSeleccionado!.id,
      userId: 0, // el backend lo asigna del usuario autenticado
      concepto: _conceptoCtrl.text.trim(),
      monto: monto!,
      fecha: _fechaSeleccionada,
      proveedor: _proveedorCtrl.text.trim().isEmpty ? null : _proveedorCtrl.text.trim(),
      notas: _notasCtrl.text.trim().isEmpty ? null : _notasCtrl.text.trim(),
    );

    final creado = await gastoCtrl.crearGasto(nuevoGasto);

    if (!mounted) return;

    if (creado != null) {
      Navigator.pop(context, true);
    } else {
      VntlToast.show(
        context,
        message: gastoCtrl.errorMessage ?? 'No se pudo registrar el gasto',
        type: VntlToastType.error,
      );
    }
  }

  Widget _buildSelector({
    required String label,
    required String placeholder,
    required String? valorActual,
    required String? error,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: VntlText.labelSmall.copyWith(color: colors.textSecondary)),
        const SizedBox(height: VntlSpacing.xs),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: VntlSpacing.lg,
              vertical: VntlSpacing.md,
            ),
            decoration: BoxDecoration(
              color: colors.glassSurface,
              borderRadius: VntlRadius.mdBorderRadius,
              border: Border.all(
                color: error != null ? colors.error : colors.border,
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    valorActual ?? placeholder,
                    style: VntlText.body.copyWith(
                      color: valorActual != null ? colors.textPrimary : colors.textTertiary,
                    ),
                  ),
                ),
                Icon(Icons.expand_more_rounded, color: colors.textTertiary, size: 18),
              ],
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: VntlSpacing.xs),
          Text(error, style: VntlText.caption.copyWith(color: colors.error)),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final gastoCtrl = context.watch<GastoController>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VntlInput(
          label: 'Concepto',
          hint: 'Ej. Compra de harina, recibo de luz',
          controller: _conceptoCtrl,
          error: _conceptoError,
        ),
        const SizedBox(height: VntlSpacing.lg),
        VntlInput(
          label: 'Monto',
          hint: '0.00',
          controller: _montoCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          error: _montoError,
        ),
        const SizedBox(height: VntlSpacing.lg),
        Text('Fecha', style: VntlText.labelSmall.copyWith(color: colors.textSecondary)),
        const SizedBox(height: VntlSpacing.xs),
        GestureDetector(
          onTap: _seleccionarFecha,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: VntlSpacing.lg,
              vertical: VntlSpacing.md,
            ),
            decoration: BoxDecoration(
              color: colors.glassSurface,
              borderRadius: VntlRadius.mdBorderRadius,
              border: Border.all(color: colors.border, width: 0.5),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 16, color: colors.textSecondary),
                const SizedBox(width: VntlSpacing.sm),
                Expanded(
                  child: Text(_formatFecha(_fechaSeleccionada), style: VntlText.body),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: VntlSpacing.lg),
        _buildSelector(
          label: 'Tipo de gasto',
          placeholder: 'Selecciona un tipo de gasto',
          valorActual: _categoriaSeleccionada?.nombre,
          error: _categoriaError,
          onTap: _seleccionarCategoria,
        ),
        const SizedBox(height: VntlSpacing.lg),
        _buildSelector(
          label: 'Método de pago',
          placeholder: 'Selecciona un método de pago',
          valorActual: _metodoPagoSeleccionado?.nombre,
          error: _metodoPagoError,
          onTap: _seleccionarMetodoPago,
        ),
        const SizedBox(height: VntlSpacing.lg),
        VntlInput(
          label: 'Proveedor (opcional)',
          hint: 'Ej. Distribuidora García',
          controller: _proveedorCtrl,
        ),
        const SizedBox(height: VntlSpacing.lg),
        VntlInput(
          label: 'Notas (opcional)',
          hint: 'Detalles adicionales',
          controller: _notasCtrl,
          maxLines: 2,
        ),
        const SizedBox(height: VntlSpacing.xl),
        Row(
          children: [
            Expanded(
              child: VntlButton(
                label: 'Cancelar',
                variant: VntlButtonVariant.ghost,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: VntlSpacing.md),
            Expanded(
              child: VntlButton(
                label: 'Registrar gasto',
                onPressed: gastoCtrl.isSaving ? null : _guardar,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
