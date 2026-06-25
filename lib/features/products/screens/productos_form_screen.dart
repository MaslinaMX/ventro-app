import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/products/controllers/producto_controller.dart';
import 'package:ventro_app/features/products/models/categoria_model.dart';
import 'package:ventro_app/features/products/models/producto_model.dart';
import 'package:ventro_app/features/products/models/producto_variante_imagen_model.dart';
import 'package:ventro_app/features/products/models/producto_variante_model.dart';
import 'package:ventro_app/features/products/models/variante_stock_inicial.dart';
import 'package:ventro_app/features/products/widgets/variante_editor_modal.dart';
import 'package:ventro_app/features/settings/controllers/settings_controller.dart';

class ProductoFormScreen extends StatefulWidget {
  const ProductoFormScreen({super.key, this.productoExistente});

  final ProductoModel? productoExistente;

  @override
  State<ProductoFormScreen> createState() => _ProductoFormScreenState();
}

class _ProductoFormScreenState extends State<ProductoFormScreen> {
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _descripcionCtrl;

  CategoriaModel? _categoriaSeleccionada;
  List<ProductoVarianteModel> _variantes = [];

  // ─── Caso "sin variantes" ────────────────────────────────────────────
  bool _tieneVariantes = true;
  late final TextEditingController _precioSimpleCtrl;
  late final TextEditingController _costoSimpleCtrl;
  late final TextEditingController _skuSimpleCtrl;
  late final TextEditingController _satKeySimpleCtrl;
  double _ivaSimple = 16;
  bool _impuestosSimple = true;
  bool _allowOnlineSimple = false;
  bool _allowOutOfStockSimple = false;
  final Map<int, TextEditingController> _stockSimpleCtrls = {};

  String? _nombreError;
  String? _categoriaError;
  String? _variantesError;

  bool _sucursalesCargadas = false;

  bool get _esEdicion => widget.productoExistente != null;

  @override
  void initState() {
    super.initState();
    final producto = widget.productoExistente;
    _nombreCtrl = TextEditingController(text: producto?.nombre ?? '');
    _descripcionCtrl = TextEditingController(text: producto?.descripcion ?? '');
    _categoriaSeleccionada = producto?.categoria;
    _variantes = producto != null ? List.of(producto.variantes) : [];
    _tieneVariantes = producto?.tieneVariantes ?? true;

    // Si es edición de un producto sin variantes, precargamos los campos
    // planos desde la única variante que existe.
    final varianteUnica = (!_tieneVariantes && _variantes.isNotEmpty) ? _variantes.first : null;

    _precioSimpleCtrl = TextEditingController(
      text: varianteUnica != null ? varianteUnica.precio.toStringAsFixed(2) : '',
    );
    _costoSimpleCtrl = TextEditingController(
      text: varianteUnica?.costoNeto?.toStringAsFixed(2) ?? '',
    );
    _skuSimpleCtrl = TextEditingController(text: varianteUnica?.sku ?? '');
    _satKeySimpleCtrl = TextEditingController(text: varianteUnica?.satKey ?? '');
    _ivaSimple = varianteUnica?.iva ?? 16;
    _impuestosSimple = varianteUnica?.impuestosIncluidos ?? true;
    _allowOnlineSimple = varianteUnica?.allowOnline ?? false;
    _allowOutOfStockSimple = varianteUnica?.allowOutOfStock ?? false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_sucursalesCargadas) {
      _sucursalesCargadas = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final settingsCtrl = context.read<SettingsController>();
        if (settingsCtrl.sucursales.isEmpty) {
          settingsCtrl.loadSucursales();
        } else {
          _inicializarStockSimpleCtrls(settingsCtrl.sucursales);
        }
      });
    }
  }

  void _inicializarStockSimpleCtrls(List sucursales) {
    if (_stockSimpleCtrls.isNotEmpty) return;
    final varianteUnica = (!_tieneVariantes && _variantes.isNotEmpty) ? _variantes.first : null;

    for (final sucursal in sucursales) {
      VarianteStockInicial? existente;
      for (final s in varianteUnica?.stocksIniciales ?? const <VarianteStockInicial>[]) {
        if (s.sucursalId == sucursal.id) {
          existente = s;
          break;
        }
      }
      _stockSimpleCtrls[sucursal.id] = TextEditingController(
        text: (existente?.cantidad ?? 0).toString(),
      );
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    _precioSimpleCtrl.dispose();
    _costoSimpleCtrl.dispose();
    _skuSimpleCtrl.dispose();
    _satKeySimpleCtrl.dispose();
    for (final ctrl in _stockSimpleCtrls.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _seleccionarCategoria() async {
    final ctrl = context.read<ProductoController>();
    final nuevaCategoriaCtrl = TextEditingController();
    final colors = context.colors;

    String iconoSeleccionado = VntlCategoryStyle.iconos.keys.first;
    String colorSeleccionado = VntlCategoryStyle.colores.first;

    final seleccion = await VntlModal.show<CategoriaModel>(
      context,
      title: 'Selecciona una categoría',
      width: 420,
      content: StatefulBuilder(
        builder: (context, setModalState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (ctrl.categorias.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: VntlSpacing.md),
                  child: Text(
                    'Aún no tienes categorías',
                    style: VntlText.body.copyWith(color: colors.textSecondary),
                  ),
                )
              else
                for (final categoria in ctrl.categorias)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Builder(
                      builder: (context) {
                        final style = VntlCategoryStyle.forCategoria(
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
              const SizedBox(height: VntlSpacing.lg),
              Divider(color: colors.border, height: 0.5),
              const SizedBox(height: VntlSpacing.lg),
              Text(
                'Crear nueva categoría',
                style: VntlText.labelSmall.copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: VntlSpacing.sm),
              VntlInput(hint: 'Ej. Pasteles, Panadería, Galletas', controller: nuevaCategoriaCtrl),
              const SizedBox(height: VntlSpacing.lg),
              Text('Ícono', style: VntlText.labelSmall.copyWith(color: colors.textSecondary)),
              const SizedBox(height: VntlSpacing.sm),
              Wrap(
                spacing: VntlSpacing.sm,
                runSpacing: VntlSpacing.sm,
                children: [
                  for (final entry in VntlCategoryStyle.iconos.entries)
                    GestureDetector(
                      onTap: () => setModalState(() => iconoSeleccionado = entry.key),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: iconoSeleccionado == entry.key
                              ? colors.primarySurface
                              : colors.surfaceSecondary,
                          borderRadius: VntlRadius.smBorderRadius,
                          border: Border.all(
                            color: iconoSeleccionado == entry.key ? colors.primary : colors.border,
                            width: iconoSeleccionado == entry.key ? 1.5 : 0.5,
                          ),
                        ),
                        child: Icon(
                          entry.value,
                          size: 18,
                          color: iconoSeleccionado == entry.key
                              ? colors.primary
                              : colors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: VntlSpacing.lg),
              Text('Color', style: VntlText.labelSmall.copyWith(color: colors.textSecondary)),
              const SizedBox(height: VntlSpacing.sm),
              Wrap(
                spacing: VntlSpacing.sm,
                runSpacing: VntlSpacing.sm,
                children: [
                  for (final hex in VntlCategoryStyle.colores)
                    GestureDetector(
                      onTap: () => setModalState(() => colorSeleccionado = hex),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Color(int.parse('FF${hex.replaceFirst('#', '')}', radix: 16)),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                colorSeleccionado == hex ? colors.textPrimary : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: colorSeleccionado == hex
                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                            : null,
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
      actions: [
        VntlButton(
          label: 'Cancelar',
          variant: VntlButtonVariant.ghost,
          onPressed: () => Navigator.pop(context),
        ),
        VntlButton(
          label: 'Crear y usar',
          onPressed: () async {
            final nombre = nuevaCategoriaCtrl.text.trim();
            if (nombre.isEmpty) return;
            final creada = await ctrl.crearCategoria(
              nombre,
              icono: iconoSeleccionado,
              color: colorSeleccionado,
            );
            if (creada != null) {
              Navigator.pop(context, creada);
            } else {
              VntlToast.show(
                context,
                message: ctrl.errorMessage ?? 'No se pudo crear la categoría',
                type: VntlToastType.error,
              );
            }
          },
        ),
      ],
    );

    if (seleccion != null) {
      setState(() {
        _categoriaSeleccionada = seleccion;
        _categoriaError = null;
      });
    }
  }

  Future<void> _abrirFormularioVariante({int? index}) async {
    final variante = index != null ? _variantes[index] : null;
    final productoId = widget.productoExistente?.id ?? 0;

    final resultado = await abrirEditorVariante(
      context,
      productoId: productoId,
      variante: variante,
      guardarInmediato: false,
      totalVariantesExistentes: _variantes.length,
    );

    if (resultado.eliminada && index != null) {
      setState(() => _variantes.removeAt(index));
      return;
    }

    if (resultado.variante != null) {
      setState(() {
        if (index != null) {
          _variantes[index] = resultado.variante!;
        } else {
          _variantes.add(resultado.variante!);
        }
        _variantesError = null;
      });
    }
  }

  Future<void> _eliminarVariante(int index) async {
    final variante = _variantes[index];

    // Variante nueva, todavía sin guardar en el backend: se quita directo.
    if (variante.id == 0) {
      setState(() => _variantes.removeAt(index));
      return;
    }

    final colors = context.colors;
    final confirmado = await VntlModal.show<bool>(
      context,
      title: 'Eliminar variante',
      subtitle: '¿Estás seguro? Esta acción no se puede deshacer.',
      width: 440,
      content: Text(
        'Se eliminará la variante "${variante.nombre}" de forma permanente.',
        style: VntlText.body.copyWith(color: colors.textSecondary),
      ),
      actions: [
        VntlButton(
          label: 'Cancelar',
          variant: VntlButtonVariant.ghost,
          onPressed: () => Navigator.pop(context, false),
        ),
        VntlButton(
          label: 'Eliminar',
          variant: VntlButtonVariant.danger,
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );

    if (confirmado != true || !mounted) return;

    final productoId = widget.productoExistente?.id;
    if (productoId == null) return; // no debería pasar si variante.id != 0

    final ctrl = context.read<ProductoController>();
    final ok = await ctrl.eliminarVariante(productoId, variante.id);

    if (!mounted) return;

    if (ok) {
      setState(() => _variantes.removeAt(index));
    } else {
      VntlToast.show(
        context,
        message: ctrl.errorMessage ?? 'No se pudo eliminar la variante',
        type: VntlToastType.error,
      );
    }
  }

  /// Construye la variante única a partir de los campos planos, para el
  /// caso en que el producto no tiene variantes.
  ProductoVarianteModel _construirVarianteSimple() {
    final sucursales = context.read<SettingsController>().sucursales;
    final varianteExistente = (!_tieneVariantes && _variantes.isNotEmpty) ? _variantes.first : null;

    final stocks = [
      for (final sucursal in sucursales)
        VarianteStockInicial(
          sucursalId: sucursal.id,
          sucursalNombre: sucursal.nombre,
          cantidad: int.tryParse(_stockSimpleCtrls[sucursal.id]?.text.trim() ?? '') ?? 0,
        ),
    ];

    return ProductoVarianteModel(
      id: varianteExistente?.id ?? 0,
      productoId: varianteExistente?.productoId ?? 0,
      nombre: _nombreCtrl.text.trim(),
      precio: double.tryParse(_precioSimpleCtrl.text.trim()) ?? 0,
      costoNeto: double.tryParse(_costoSimpleCtrl.text.trim()),
      sku: _skuSimpleCtrl.text.trim().isEmpty ? null : _skuSimpleCtrl.text.trim(),
      satKey: _satKeySimpleCtrl.text.trim().isEmpty ? null : _satKeySimpleCtrl.text.trim(),
      iva: _ivaSimple,
      impuestosIncluidos: _impuestosSimple,
      allowOnline: _allowOnlineSimple,
      allowOutOfStock: _allowOutOfStockSimple,
      isDefault: true,
      stocksIniciales: stocks,
    );
  }

  Future<void> _guardar() async {
    final ctrl = context.read<ProductoController>();
    if (ctrl.isSaving) return;

    final precioSimpleValido =
        !_tieneVariantes ? double.tryParse(_precioSimpleCtrl.text.trim()) != null : true;

    setState(() {
      _nombreError = _nombreCtrl.text.trim().isEmpty ? 'El nombre es requerido' : null;
      _categoriaError = _categoriaSeleccionada == null ? 'Selecciona una categoría' : null;
      _variantesError = _tieneVariantes && _variantes.isEmpty
          ? 'Agrega al menos una variante'
          : (!_tieneVariantes && !precioSimpleValido ? 'Captura un precio válido' : null);
    });

    if (_nombreError != null || _categoriaError != null || _variantesError != null) return;

    final variantesParaGuardar = _tieneVariantes ? _variantes : [_construirVarianteSimple()];

    final resultado = await ctrl.guardarProductoConVariantes(
      productoExistente: widget.productoExistente,
      nombre: _nombreCtrl.text.trim(),
      descripcion: _descripcionCtrl.text.trim().isEmpty ? null : _descripcionCtrl.text.trim(),
      categoriaId: _categoriaSeleccionada!.id,
      tieneVariantes: _tieneVariantes,
      variantes: variantesParaGuardar,
    );

    if (!mounted) return;

    if (resultado != null) {
      Navigator.pop(context);
    } else {
      VntlToast.show(
        context,
        message: ctrl.errorMessage ?? 'No se pudo guardar el producto',
        type: VntlToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ctrl = context.watch<ProductoController>();
    final sucursales = context.watch<SettingsController>().sucursales;

    if (sucursales.isNotEmpty && _stockSimpleCtrls.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _inicializarStockSimpleCtrls(sucursales);
      });
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: context.backgroundGradient),
        child: Column(
          children: [
            VntlAppBar(
              title: _esEdicion ? 'Editar producto' : 'Nuevo producto',
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.arrow_back_rounded, color: colors.textSecondary, size: 20),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.topLeft,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(VntlSpacing.xl),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(VntlSpacing.xl),
                          decoration: BoxDecoration(
                            color: colors.glassSurface,
                            borderRadius: VntlRadius.lgBorderRadius,
                            border: Border.all(color: colors.border, width: 0.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Datos del producto', style: VntlText.h4),
                              const SizedBox(height: VntlSpacing.xl),
                              VntlInput(
                                label: 'Nombre',
                                hint: 'Ej. Pastel de chocolate',
                                controller: _nombreCtrl,
                                error: _nombreError,
                              ),
                              const SizedBox(height: VntlSpacing.lg),
                              VntlInput(
                                label: 'Descripción (opcional)',
                                hint: 'Detalles del producto',
                                controller: _descripcionCtrl,
                                maxLines: 3,
                              ),
                              const SizedBox(height: VntlSpacing.lg),
                              Text(
                                'Categoría',
                                style: VntlText.labelSmall.copyWith(color: colors.textSecondary),
                              ),
                              const SizedBox(height: VntlSpacing.xs),
                              GestureDetector(
                                onTap: _seleccionarCategoria,
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
                                      color: _categoriaError != null ? colors.error : colors.border,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _categoriaSeleccionada?.nombre ??
                                              'Selecciona una categoría',
                                          style: VntlText.body.copyWith(
                                            color: _categoriaSeleccionada != null
                                                ? colors.textPrimary
                                                : colors.textTertiary,
                                          ),
                                        ),
                                      ),
                                      Icon(Icons.expand_more_rounded,
                                          color: colors.textTertiary, size: 18),
                                    ],
                                  ),
                                ),
                              ),
                              if (_categoriaError != null) ...[
                                const SizedBox(height: VntlSpacing.xs),
                                Text(_categoriaError!,
                                    style: VntlText.caption.copyWith(color: colors.error)),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: VntlSpacing.lg),

                        // ─── Switch: ¿tiene variantes? ───────────────
                        if (!_esEdicion) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(VntlSpacing.lg),
                            decoration: BoxDecoration(
                              color: colors.glassSurface,
                              borderRadius: VntlRadius.lgBorderRadius,
                              border: Border.all(color: colors.border, width: 0.5),
                            ),
                            child: VntlSwitch(
                              value: _tieneVariantes,
                              label: 'Este producto tiene variantes',
                              tooltip: 'Activa esto si vendes el mismo producto en diferentes '
                                  'tamaños, sabores o presentaciones con precios distintos. '
                                  'Si es un producto único, déjalo apagado.',
                              onChanged: (v) => setState(() => _tieneVariantes = v),
                            ),
                          ),
                          const SizedBox(height: VntlSpacing.lg),
                        ],
                        const SizedBox(height: VntlSpacing.lg),

                        if (_tieneVariantes)
                          _buildSeccionVariantes(colors)
                        else
                          _buildSeccionPrecioSimple(colors, sucursales),

                        const SizedBox(height: VntlSpacing.xl),
                        VntlButton(
                          label: _esEdicion ? 'Guardar cambios' : 'Crear producto',
                          onPressed: ctrl.isSaving ? null : _guardar,
                        ),
                        const SizedBox(height: VntlSpacing.xl),
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

  Widget _buildSeccionVariantes(VntlColorScheme colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(VntlSpacing.xl),
      decoration: BoxDecoration(
        color: colors.glassSurface,
        borderRadius: VntlRadius.lgBorderRadius,
        border: Border.all(
          color: _variantesError != null ? colors.error : colors.border,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Variantes', style: VntlText.h4),
              VntlButton(
                label: 'Agregar',
                icon: Icons.add_rounded,
                variant: VntlButtonVariant.secondary,
                fullWidth: false,
                onPressed: () => _abrirFormularioVariante(),
              ),
            ],
          ),
          const SizedBox(height: VntlSpacing.sm),
          Text(
            'Cada tamaño o sabor que vendas por separado es una variante.',
            style: VntlText.caption.copyWith(color: colors.textTertiary),
          ),
          const SizedBox(height: VntlSpacing.lg),
          if (_variantes.isEmpty)
            Text(
              'Aún no agregas ninguna variante',
              style: VntlText.body.copyWith(color: colors.textSecondary),
            )
          else
            for (int i = 0; i < _variantes.length; i++)
              _VarianteRow(
                variante: _variantes[i],
                onTap: () => _abrirFormularioVariante(index: i),
                onDelete: () => _eliminarVariante(i),
              ),
          if (_variantesError != null) ...[
            const SizedBox(height: VntlSpacing.sm),
            Text(_variantesError!, style: VntlText.caption.copyWith(color: colors.error)),
          ],
        ],
      ),
    );
  }

  Widget _buildSeccionPrecioSimple(VntlColorScheme colors, List sucursales) {
    final precioIngresado = double.tryParse(_precioSimpleCtrl.text.trim()) ?? 0;
    final factor = 1 + _ivaSimple / 100;
    final precioFinalPreview = _impuestosSimple ? precioIngresado : precioIngresado * factor;
    final precioBasePreview = _impuestosSimple
        ? (factor == 0 ? precioIngresado : precioIngresado / factor)
        : precioIngresado;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(VntlSpacing.xl),
      decoration: BoxDecoration(
        color: colors.glassSurface,
        borderRadius: VntlRadius.lgBorderRadius,
        border: Border.all(
          color: _variantesError != null ? colors.error : colors.border,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Precio e inventario', style: VntlText.h4),
          const SizedBox(height: VntlSpacing.xl),
          VntlInput(
            label: _impuestosSimple ? 'Precio (con impuestos incluidos)' : 'Precio (sin impuestos)',
            hint: '0.00',
            controller: _precioSimpleCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: VntlSpacing.sm),
          Row(
            children: [
              Switch(
                value: _impuestosSimple,
                activeColor: colors.primary,
                onChanged: (v) => setState(() => _impuestosSimple = v),
              ),
              const SizedBox(width: VntlSpacing.sm),
              Expanded(
                child: Text(
                  'Este precio ya incluye impuestos',
                  style: VntlText.caption.copyWith(color: colors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: VntlSpacing.sm),
          Text('IVA', style: VntlText.labelSmall.copyWith(color: colors.textSecondary)),
          const SizedBox(height: VntlSpacing.xs),
          Row(
            children: [
              for (final tasa in [0.0, 8.0, 16.0])
                Padding(
                  padding: const EdgeInsets.only(right: VntlSpacing.sm),
                  child: GestureDetector(
                    onTap: () => setState(() => _ivaSimple = tasa),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: VntlSpacing.md,
                        vertical: VntlSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: _ivaSimple == tasa ? colors.primarySurface : Colors.transparent,
                        borderRadius: VntlRadius.mdBorderRadius,
                        border: Border.all(
                          color: _ivaSimple == tasa ? colors.primary : colors.border,
                          width: _ivaSimple == tasa ? 1.5 : 0.5,
                        ),
                      ),
                      child: Text(
                        '${tasa.toInt()}%',
                        style: VntlText.label.copyWith(
                          color: _ivaSimple == tasa ? colors.primary : colors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (precioIngresado > 0) ...[
            const SizedBox(height: VntlSpacing.sm),
            Text(
              _impuestosSimple
                  ? 'Base sin impuestos: \$${precioBasePreview.toStringAsFixed(2)}'
                  : 'Precio final al cliente: \$${precioFinalPreview.toStringAsFixed(2)}',
              style: VntlText.caption.copyWith(color: colors.textTertiary),
            ),
          ],
          const SizedBox(height: VntlSpacing.lg),
          VntlInput(
            label: 'Costo (opcional)',
            hint: '0.00',
            controller: _costoSimpleCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: VntlSpacing.lg),
          VntlInput(label: 'SKU (opcional)', hint: 'Código interno', controller: _skuSimpleCtrl),
          const SizedBox(height: VntlSpacing.lg),
          VntlInput(
            label: 'Clave SAT (opcional)',
            hint: 'Código del catálogo SAT',
            controller: _satKeySimpleCtrl,
          ),
          const SizedBox(height: VntlSpacing.lg),
          Row(
            children: [
              Switch(
                value: _allowOnlineSimple,
                activeColor: colors.primary,
                onChanged: (v) => setState(() => _allowOnlineSimple = v),
              ),
              const SizedBox(width: VntlSpacing.sm),
              Expanded(child: Text('Mostrar en tienda en línea', style: VntlText.body)),
            ],
          ),
          const SizedBox(height: VntlSpacing.lg),
          Row(
            children: [
              Switch(
                value: _allowOutOfStockSimple,
                activeColor: colors.primary,
                onChanged: (v) => setState(() => _allowOutOfStockSimple = v),
              ),
              const SizedBox(width: VntlSpacing.sm),
              Expanded(child: Text('Permitir venta sin stock', style: VntlText.body)),
            ],
          ),
          const SizedBox(height: VntlSpacing.lg),
          Divider(color: colors.border, height: 0.5),
          const SizedBox(height: VntlSpacing.lg),
          Row(
            children: [
              Text(
                'Inventario inicial',
                style: VntlText.labelSmall.copyWith(color: colors.textSecondary),
              ),
              if (_esEdicion) ...[
                const SizedBox(width: VntlSpacing.xs),
                VntlTooltip(
                  message: 'El stock se ajusta desde la sección de Inventario',
                  child: Icon(Icons.info_outline_rounded, size: 14, color: colors.textTertiary),
                ),
              ],
            ],
          ),
          const SizedBox(height: VntlSpacing.sm),
          if (sucursales.isEmpty)
            Text(
              'No tienes sucursales registradas',
              style: VntlText.body.copyWith(color: colors.textSecondary),
            )
          else
            for (final sucursal in sucursales)
              Padding(
                padding: const EdgeInsets.only(bottom: VntlSpacing.sm),
                child: Row(
                  children: [
                    Expanded(child: Text(sucursal.nombre, style: VntlText.body)),
                    SizedBox(
                      width: 90,
                      child: VntlInput(
                        hint: '0',
                        controller: _stockSimpleCtrls[sucursal.id],
                        keyboardType: TextInputType.number,
                        readOnly: _esEdicion,
                        enabled: !_esEdicion,
                      ),
                    ),
                  ],
                ),
              ),
          if (_variantesError != null) ...[
            const SizedBox(height: VntlSpacing.sm),
            Text(_variantesError!, style: VntlText.caption.copyWith(color: colors.error)),
          ],
        ],
      ),
    );
  }
}

class _VarianteRow extends StatelessWidget {
  const _VarianteRow({required this.variante, required this.onTap, required this.onDelete});

  final ProductoVarianteModel variante;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: VntlSpacing.sm),
      child: Material(
        color: Colors.transparent,
        borderRadius: VntlRadius.mdBorderRadius,
        child: InkWell(
          borderRadius: VntlRadius.mdBorderRadius,
          onTap: onTap,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: VntlSpacing.md, vertical: VntlSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: VntlRadius.mdBorderRadius,
              border: Border.all(color: colors.border, width: 0.5),
            ),
            child: Row(
              children: [
                Expanded(child: Text(variante.nombre, style: VntlText.label)),
                Text(
                  '\$${variante.precioFinal.toStringAsFixed(2)}',
                  style: VntlText.label.copyWith(color: colors.primary),
                ),
                const SizedBox(width: VntlSpacing.md),
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(Icons.delete_outline_rounded, color: colors.textTertiary, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
