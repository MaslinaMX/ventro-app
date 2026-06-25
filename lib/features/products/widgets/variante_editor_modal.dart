import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/products/controllers/producto_controller.dart';
import 'package:ventro_app/features/products/models/producto_variante_model.dart';
import 'package:ventro_app/features/products/models/variante_stock_inicial.dart';
import 'package:ventro_app/features/settings/controllers/settings_controller.dart';
import 'package:image_picker/image_picker.dart';

/// Resultado del editor de variante: o se guardó/canceló (con o sin modelo),
/// o se eliminó la variante en el backend dentro de este mismo flujo.
class ResultadoEditorVariante {
  final ProductoVarianteModel? variante;
  final bool eliminada;

  const ResultadoEditorVariante.guardada(this.variante) : eliminada = false;
  const ResultadoEditorVariante.eliminada()
      : variante = null,
        eliminada = true;
  const ResultadoEditorVariante.cancelada()
      : variante = null,
        eliminada = false;
}

/// Abre el modal de edición/creación de una variante.
///
/// Si [guardarInmediato] es true, el modal llama a updateVariante/createVariante
/// directo al backend al dar "Guardar" y se cierra solo tras éxito — usado
/// desde el listado de productos (edición rápida fuera del form).
///
/// Si [guardarInmediato] es false (default), el modal solo hace Navigator.pop
/// devolviendo el ProductoVarianteModel resultante, para que el form completo
/// del producto lo persista junto con el resto de cambios — comportamiento
/// actual dentro de ProductoFormScreen.
///
/// Si la variante existente se elimina desde este modal (solo disponible en
/// modo edición), el resultado viene marcado con `eliminada = true` y
/// `variante = null`, para que quien llama actualice su lista local.
///
/// Retorna un [ResultadoEditorVariante] que distingue entre guardado,
/// cancelado y eliminado.
Future<ResultadoEditorVariante> abrirEditorVariante(
  BuildContext context, {
  required int productoId,
  ProductoVarianteModel? variante,
  bool guardarInmediato = false,
  int totalVariantesExistentes = 0,
}) async {
  final esEdicionVariante = variante != null && variante.id != 0;

  if (esEdicionVariante) {
    final ctrl = context.read<ProductoController>();
    final fresca = await ctrl.obtenerVariante(variante!.productoId, variante.id);
    if (fresca != null) variante = fresca;
  }

  if (!context.mounted) return const ResultadoEditorVariante.cancelada();

  final colors = context.colors;
  final sucursales = context.read<SettingsController>().sucursales;

  final nombreCtrl = TextEditingController(text: variante?.nombre ?? '');
  final precioCtrl = TextEditingController(
    text: variante != null ? variante.precio.toStringAsFixed(2) : '',
  );
  final costoCtrl = TextEditingController(text: variante?.costoNeto?.toStringAsFixed(2) ?? '');
  final skuCtrl = TextEditingController(text: variante?.sku ?? '');
  final satKeyCtrl = TextEditingController(text: variante?.satKey ?? '');

  double ivaLocal = variante?.iva ?? 16;
  bool impuestosLocal = variante?.impuestosIncluidos ?? true;
  bool allowOnlineLocal = variante?.allowOnline ?? false;
  bool allowOutOfStockLocal = variante?.allowOutOfStock ?? false;
  var imagenActual = variante?.imagenPrincipal;
  bool subiendoImagen = false;
  bool guardando = false;
  bool eliminada = false;
  String? errorGuardado;

  final stockCtrls = <int, TextEditingController>{};
  for (final sucursal in sucursales) {
    VarianteStockInicial? existente;
    for (final s in variante?.stocksIniciales ?? const <VarianteStockInicial>[]) {
      if (s.sucursalId == sucursal.id) {
        existente = s;
        break;
      }
    }
    stockCtrls[sucursal.id] = TextEditingController(text: (existente?.cantidad ?? 0).toString());
  }

  final resultado = await VntlModal.show<ProductoVarianteModel>(
    context,
    title: variante == null ? 'Agregar variante' : 'Editar variante',
    width: 460,
    content: StatefulBuilder(
      builder: (context, setModalState) {
        final precioIngresado = double.tryParse(precioCtrl.text.trim()) ?? 0;
        final factor = 1 + ivaLocal / 100;
        final precioFinalPreview = impuestosLocal ? precioIngresado : precioIngresado * factor;
        final precioBasePreview = impuestosLocal
            ? (factor == 0 ? precioIngresado : precioIngresado / factor)
            : precioIngresado;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VntlInput(
              label: 'Nombre',
              hint: 'Ej. Grande, Chocolate, Vainilla',
              controller: nombreCtrl,
            ),
            const SizedBox(height: VntlSpacing.lg),
            VntlInput(
              label: impuestosLocal ? 'Precio (con impuestos incluidos)' : 'Precio (sin impuestos)',
              hint: '0.00',
              controller: precioCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setModalState(() {}),
            ),
            const SizedBox(height: VntlSpacing.sm),
            Row(
              children: [
                Switch(
                  value: impuestosLocal,
                  activeColor: colors.primary,
                  onChanged: (v) => setModalState(() => impuestosLocal = v),
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
                      onTap: () => setModalState(() => ivaLocal = tasa),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: VntlSpacing.md,
                          vertical: VntlSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: ivaLocal == tasa ? colors.primarySurface : Colors.transparent,
                          borderRadius: VntlRadius.mdBorderRadius,
                          border: Border.all(
                            color: ivaLocal == tasa ? colors.primary : colors.border,
                            width: ivaLocal == tasa ? 1.5 : 0.5,
                          ),
                        ),
                        child: Text(
                          '${tasa.toInt()}%',
                          style: VntlText.label.copyWith(
                            color: ivaLocal == tasa ? colors.primary : colors.textSecondary,
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
                impuestosLocal
                    ? 'Base sin impuestos: \$${precioBasePreview.toStringAsFixed(2)}'
                    : 'Precio final al cliente: \$${precioFinalPreview.toStringAsFixed(2)}',
                style: VntlText.caption.copyWith(color: colors.textTertiary),
              ),
            ],
            const SizedBox(height: VntlSpacing.lg),
            VntlInput(
              label: 'Costo (opcional)',
              hint: '0.00',
              controller: costoCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: VntlSpacing.lg),
            VntlInput(label: 'SKU (opcional)', hint: 'Código interno', controller: skuCtrl),
            const SizedBox(height: VntlSpacing.lg),
            VntlInput(
              label: 'Clave SAT (opcional)',
              hint: 'Código del catálogo SAT',
              controller: satKeyCtrl,
            ),
            const SizedBox(height: VntlSpacing.lg),
            Row(
              children: [
                Switch(
                  value: allowOnlineLocal,
                  activeColor: colors.primary,
                  onChanged: (v) => setModalState(() => allowOnlineLocal = v),
                ),
                const SizedBox(width: VntlSpacing.sm),
                Expanded(child: Text('Mostrar en tienda en línea', style: VntlText.body)),
              ],
            ),
            const SizedBox(height: VntlSpacing.lg),
            Row(
              children: [
                Switch(
                  value: allowOutOfStockLocal,
                  activeColor: colors.primary,
                  onChanged: (v) => setModalState(() => allowOutOfStockLocal = v),
                ),
                const SizedBox(width: VntlSpacing.sm),
                Expanded(child: Text('Permitir venta sin stock', style: VntlText.body)),
              ],
            ),
            const SizedBox(height: VntlSpacing.lg),
            Divider(color: colors.border, height: 0.5),
            const SizedBox(height: VntlSpacing.lg),
            Text('Imagen', style: VntlText.labelSmall.copyWith(color: colors.textSecondary)),
            const SizedBox(height: VntlSpacing.sm),
            if (!esEdicionVariante)
              Text(
                'Guarda la variante primero para poder subir una imagen',
                style: VntlText.caption.copyWith(color: colors.textTertiary),
              )
            else
              Row(
                children: [
                  ClipRRect(
                    borderRadius: VntlRadius.mdBorderRadius,
                    child: Container(
                      width: 64,
                      height: 64,
                      color: colors.surfaceSecondary,
                      child: subiendoImagen
                          ? const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : imagenActual != null
                              ? Image.network(imagenActual!.path, fit: BoxFit.cover)
                              : Icon(Icons.image_outlined, color: colors.textTertiary, size: 24),
                    ),
                  ),
                  const SizedBox(width: VntlSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        VntlButton(
                          label: imagenActual != null ? 'Cambiar imagen' : 'Subir imagen',
                          variant: VntlButtonVariant.secondary,
                          fullWidth: false,
                          onPressed: subiendoImagen
                              ? null
                              : () async {
                                  final picker = ImagePicker();
                                  final picked = await picker.pickImage(
                                    source: ImageSource.gallery,
                                    imageQuality: 85,
                                  );
                                  if (picked == null) return;

                                  setModalState(() => subiendoImagen = true);
                                  final bytes = await picked.readAsBytes();
                                  final ctrl = context.read<ProductoController>();
                                  final nueva = await ctrl.subirImagenVariante(
                                    variante!.productoId,
                                    variante.id,
                                    bytes,
                                    picked.name,
                                  );
                                  setModalState(() {
                                    subiendoImagen = false;
                                    if (nueva != null) imagenActual = nueva;
                                  });
                                },
                        ),
                        if (imagenActual != null) ...[
                          const SizedBox(height: VntlSpacing.xs),
                          GestureDetector(
                            onTap: subiendoImagen
                                ? null
                                : () async {
                                    setModalState(() => subiendoImagen = true);
                                    final ctrl = context.read<ProductoController>();
                                    final ok = await ctrl.eliminarImagenVariante(
                                      variante!.productoId,
                                      variante.id,
                                      imagenActual!.id,
                                    );
                                    setModalState(() {
                                      subiendoImagen = false;
                                      if (ok) imagenActual = null;
                                    });
                                  },
                            child: Text(
                              'Quitar imagen',
                              style: VntlText.caption.copyWith(color: colors.error),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
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
                if (esEdicionVariante) ...[
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
                          controller: stockCtrls[sucursal.id],
                          keyboardType: TextInputType.number,
                          readOnly: esEdicionVariante,
                          enabled: !esEdicionVariante,
                        ),
                      ),
                    ],
                  ),
                ),
            if (errorGuardado != null) ...[
              const SizedBox(height: VntlSpacing.sm),
              Text(errorGuardado!, style: VntlText.caption.copyWith(color: colors.error)),
            ],
          ],
        );
      },
    ),
    actions: [
      if (esEdicionVariante)
        StatefulBuilder(
          builder: (context, setModalState) {
            return VntlButton(
              label: 'Eliminar',
              variant: VntlButtonVariant.danger,
              onPressed: guardando
                  ? null
                  : () async {
                      final confirmado = await VntlModal.show<bool>(
                        context,
                        title: 'Eliminar variante',
                        subtitle: '¿Estás seguro? Esta acción no se puede deshacer.',
                        width: 440,
                        content: Text(
                          'Se eliminará la variante "${variante!.nombre}" de forma permanente.',
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

                      if (confirmado != true || !context.mounted) return;

                      setModalState(() => guardando = true);
                      final ctrl = context.read<ProductoController>();
                      final ok = await ctrl.eliminarVariante(productoId, variante.id);

                      if (ok) {
                        eliminada = true;
                        if (context.mounted) Navigator.pop(context);
                      } else {
                        setModalState(() {
                          guardando = false;
                          errorGuardado = ctrl.errorMessage ?? 'No se pudo eliminar la variante';
                        });
                      }
                    },
            );
          },
        ),
      VntlButton(
        label: 'Cancelar',
        variant: VntlButtonVariant.ghost,
        onPressed: () => Navigator.pop(context),
      ),
      StatefulBuilder(
        builder: (context, setModalState) {
          return VntlButton(
            label: 'Guardar',
            onPressed: guardando
                ? null
                : () async {
                    final nombre = nombreCtrl.text.trim();
                    final precio = double.tryParse(precioCtrl.text.trim());
                    if (nombre.isEmpty || precio == null) return;

                    final stocks = [
                      for (final sucursal in sucursales)
                        VarianteStockInicial(
                          sucursalId: sucursal.id,
                          sucursalNombre: sucursal.nombre,
                          cantidad: int.tryParse(stockCtrls[sucursal.id]!.text.trim()) ?? 0,
                        ),
                    ];

                    final modelo = ProductoVarianteModel(
                      id: variante?.id ?? 0,
                      productoId: variante?.productoId ?? productoId,
                      nombre: nombre,
                      precio: precio,
                      costoNeto: double.tryParse(costoCtrl.text.trim()),
                      sku: skuCtrl.text.trim().isEmpty ? null : skuCtrl.text.trim(),
                      satKey: satKeyCtrl.text.trim().isEmpty ? null : satKeyCtrl.text.trim(),
                      iva: ivaLocal,
                      impuestosIncluidos: impuestosLocal,
                      allowOnline: allowOnlineLocal,
                      allowOutOfStock: allowOutOfStockLocal,
                      isDefault: variante?.isDefault ?? totalVariantesExistentes == 0,
                      stocksIniciales: stocks,
                    );

                    if (!guardarInmediato) {
                      Navigator.pop(context, modelo);
                      return;
                    }

                    setModalState(() => guardando = true);
                    final ctrl = context.read<ProductoController>();
                    final guardado = esEdicionVariante
                        ? await ctrl.actualizarVarianteDirecto(productoId, variante!.id, modelo)
                        : await ctrl.crearVarianteDirecto(productoId, modelo);

                    if (guardado != null) {
                      if (context.mounted) Navigator.pop(context, guardado);
                    } else {
                      setModalState(() {
                        guardando = false;
                        errorGuardado = ctrl.errorMessage ?? 'No se pudo guardar la variante';
                      });
                    }
                  },
          );
        },
      ),
    ],
  );

  for (final ctrl in stockCtrls.values) {
    ctrl.dispose();
  }

  if (eliminada) {
    return const ResultadoEditorVariante.eliminada();
  }
  if (resultado == null) {
    return const ResultadoEditorVariante.cancelada();
  }
  return ResultadoEditorVariante.guardada(resultado);
}
