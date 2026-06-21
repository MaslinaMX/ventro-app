import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/products/controllers/producto_controller.dart';
import 'package:ventro_app/features/products/models/categoria_model.dart';

class CategoriasSettingsSection extends StatefulWidget {
  const CategoriasSettingsSection({super.key});

  @override
  State<CategoriasSettingsSection> createState() => _CategoriasSettingsSectionState();
}

class _CategoriasSettingsSectionState extends State<CategoriasSettingsSection> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      context.read<ProductoController>().cargarCategorias();
    }
  }

  Future<void> _abrirEditor({CategoriaModel? categoria}) async {
    final ctrl = context.read<ProductoController>();
    final colors = context.colors;
    final nombreCtrl = TextEditingController(text: categoria?.nombre ?? '');
    final descripcionCtrl = TextEditingController(text: categoria?.descripcion ?? '');
    final busquedaIconoCtrl = TextEditingController();

    String iconoSeleccionado = categoria?.icono ?? VntlCategoryStyle.iconos.keys.first;
    String colorSeleccionado = categoria?.color ?? VntlCategoryStyle.colores.first;

    final guardado = await VntlModal.show<bool>(
      context,
      title: categoria == null ? 'Nueva categoría' : 'Editar categoría',
      width: 420,
      content: StatefulBuilder(
        builder: (context, setModalState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VntlInput(label: 'Nombre', hint: 'Ej. Pasteles', controller: nombreCtrl),
              const SizedBox(height: VntlSpacing.lg),
              VntlInput(
                label: 'Descripción (opcional)',
                hint: 'Detalles de la categoría',
                controller: descripcionCtrl,
                maxLines: 2,
              ),
              const SizedBox(height: VntlSpacing.lg),
              Text('Ícono', style: VntlText.labelSmall.copyWith(color: colors.textSecondary)),
              const SizedBox(height: VntlSpacing.sm),
              VntlInput(
                hint: 'Buscar ícono (ej. pan, café, regalo)',
                controller: busquedaIconoCtrl,
                prefixIcon: Icons.search_rounded,
                onChanged: (_) => setModalState(() {}),
              ),
              const SizedBox(height: VntlSpacing.sm),
              Builder(
                builder: (context) {
                  final resultados = VntlCategoryStyle.buscar(busquedaIconoCtrl.text);
                  final mostrados = busquedaIconoCtrl.text.trim().isEmpty
                      ? resultados.take(30).toList()
                      : resultados;

                  if (mostrados.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: VntlSpacing.md),
                      child: Text(
                        'Sin resultados para "${busquedaIconoCtrl.text}"',
                        style: VntlText.caption.copyWith(color: colors.textTertiary),
                      ),
                    );
                  }

                  return ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 180),
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: VntlSpacing.sm,
                        runSpacing: VntlSpacing.sm,
                        children: [
                          for (final entry in mostrados)
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
                                    color: iconoSeleccionado == entry.key
                                        ? colors.primary
                                        : colors.border,
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
                    ),
                  );
                },
              ),
              if (busquedaIconoCtrl.text.trim().isEmpty) ...[
                const SizedBox(height: VntlSpacing.xs),
                Text(
                  'Mostrando 30 de ${VntlCategoryStyle.iconos.length} — busca para ver más',
                  style: VntlText.caption.copyWith(color: colors.textTertiary),
                ),
              ],
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
          label: 'Guardar',
          onPressed: () async {
            final nombre = nombreCtrl.text.trim();
            if (nombre.isEmpty) return;

            final descripcion =
                descripcionCtrl.text.trim().isEmpty ? null : descripcionCtrl.text.trim();

            final ok = categoria == null
                ? (await ctrl.crearCategoria(
                      nombre,
                      descripcion: descripcion,
                      icono: iconoSeleccionado,
                      color: colorSeleccionado,
                    )) !=
                    null
                : await ctrl.actualizarCategoria(
                    categoria.id,
                    nombre: nombre,
                    descripcion: descripcion,
                    icono: iconoSeleccionado,
                    color: colorSeleccionado,
                  );

            if (ok) {
              if (context.mounted) Navigator.pop(context, true);
            } else if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(ctrl.errorMessage ?? 'No se pudo guardar la categoría')),
              );
            }
          },
        ),
      ],
    );

    nombreCtrl.dispose();
    descripcionCtrl.dispose();
    busquedaIconoCtrl.dispose();

    if (guardado == true) setState(() {});
  }

  Future<void> _confirmarEliminar(CategoriaModel categoria) async {
    final ctrl = context.read<ProductoController>();

    final confirmado = await VntlDialog.confirm(
      context,
      title: 'Eliminar categoría',
      message:
          '¿Seguro que quieres eliminar "${categoria.nombre}"? Los productos que la usan quedarán sin categoría.',
      confirmLabel: 'Eliminar',
      destructive: true,
    );

    if (confirmado == true) {
      final ok = await ctrl.eliminarCategoria(categoria.id);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ctrl.errorMessage ?? 'No se pudo eliminar')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ProductoController>();
    final colors = context.colors;

    return Align(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(VntlSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Categorías', style: VntlText.h3),
                  VntlButton(
                    label: 'Nueva categoría',
                    icon: Icons.add_rounded,
                    fullWidth: false,
                    onPressed: () => _abrirEditor(),
                  ),
                ],
              ),
              const SizedBox(height: VntlSpacing.xl),
              if (ctrl.isLoadingCategorias && ctrl.categorias.isEmpty)
                const Center(child: CircularProgressIndicator())
              else if (ctrl.categorias.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(VntlSpacing.xl * 1.5),
                  decoration: BoxDecoration(
                    color: colors.glassSurface,
                    borderRadius: VntlRadius.lgBorderRadius,
                    border: Border.all(color: colors.border, width: 0.5),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.category_outlined, size: 48, color: colors.textTertiary),
                      const SizedBox(height: VntlSpacing.lg),
                      Text('Aún no tienes categorías', style: VntlText.h4),
                    ],
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colors.glassSurface,
                    borderRadius: VntlRadius.lgBorderRadius,
                    border: Border.all(color: colors.border, width: 0.5),
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < ctrl.categorias.length; i++) ...[
                        if (i > 0) Divider(color: colors.border, height: 0.5),
                        _CategoriaRow(
                          categoria: ctrl.categorias[i],
                          onEditar: () => _abrirEditor(categoria: ctrl.categorias[i]),
                          onEliminar: () => _confirmarEliminar(ctrl.categorias[i]),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoriaRow extends StatelessWidget {
  const _CategoriaRow({required this.categoria, required this.onEditar, required this.onEliminar});

  final CategoriaModel categoria;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = VntlCategoryStyle.forCategoria(
      context,
      categoria.id,
      iconoKey: categoria.icono,
      colorHex: categoria.color,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onEditar,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: VntlSpacing.lg, vertical: VntlSpacing.md),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: style.background,
                  borderRadius: VntlRadius.smBorderRadius,
                ),
                child: Icon(style.icon, color: style.foreground, size: 18),
              ),
              const SizedBox(width: VntlSpacing.lg),
              Expanded(child: Text(categoria.nombre, style: VntlText.label)),
              GestureDetector(
                onTap: onEliminar,
                child: Icon(Icons.delete_outline_rounded, color: colors.textTertiary, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
