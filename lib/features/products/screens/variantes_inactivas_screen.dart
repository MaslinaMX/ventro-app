import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/products/controllers/producto_controller.dart';
import 'package:ventro_app/features/products/models/variantes_inactivas_page.dart';
import 'package:ventro_app/features/products/widgets/variante_editor_modal.dart';

class VariantesInactivasScreen extends StatefulWidget {
  const VariantesInactivasScreen({super.key});

  @override
  State<VariantesInactivasScreen> createState() => _VariantesInactivasScreenState();
}

class _VariantesInactivasScreenState extends State<VariantesInactivasScreen> {
  final _scrollController = ScrollController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductoController>().cargarVariantesInactivas();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<ProductoController>().cargarMasVariantesInactivas(
            search: _query.isEmpty ? null : _query,
          );
    }
  }

  void _buscar(String value) {
    setState(() => _query = value);
    context.read<ProductoController>().cargarVariantesInactivas(
          search: value.isEmpty ? null : value,
        );
  }

  Future<void> _abrirEditor(VarianteInactiva inactiva) async {
    final resultado = await abrirEditorVariante(
      context,
      productoId: inactiva.variante.productoId,
      variante: inactiva.variante,
      guardarInmediato: true,
    );

    if (!mounted) return;

    // Si se editó algo (nombre, precio, etc.) mientras estaba inactiva,
    // refrescamos la lista para reflejar los cambios.
    if (resultado.variante != null) {
      context.read<ProductoController>().cargarVariantesInactivas(
            search: _query.isEmpty ? null : _query,
          );
    }
  }

  Future<void> _reactivar(VarianteInactiva inactiva) async {
    final colors = context.colors;
    final confirmado = await VntlModal.show<bool>(
      context,
      title: 'Reactivar variante',
      subtitle: 'Volverá a aparecer en Productos e Inventario.',
      width: 440,
      content: Text(
        '¿Reactivar "${inactiva.variante.nombre}" de "${inactiva.productoNombre}"?',
        style: VntlText.body.copyWith(color: colors.textSecondary),
      ),
      actions: [
        VntlButton(
          label: 'Cancelar',
          variant: VntlButtonVariant.ghost,
          onPressed: () => Navigator.pop(context, false),
        ),
        VntlButton(
          label: 'Reactivar',
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );

    if (confirmado != true || !mounted) return;

    final ctrl = context.read<ProductoController>();
    final ok = await ctrl.reactivarVariante(
      inactiva.variante.productoId,
      inactiva.variante.id,
    );

    if (!mounted) return;
    VntlToast.show(
      context,
      message: ok != null ? 'Variante reactivada' : ctrl.errorInactivas ?? 'No se pudo reactivar',
      type: ok != null ? VntlToastType.success : VntlToastType.error,
    );
  }

  String _formatearFecha(DateTime? fecha) {
    if (fecha == null) return '';
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ctrl = context.watch<ProductoController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: context.backgroundGradient),
        child: Column(
          children: [
            VntlAppBar(
              title: 'Variantes inactivas',
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.arrow_back_rounded, color: colors.textSecondary, size: 20),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.topLeft,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(VntlSpacing.xl),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Variantes que fueron eliminadas y puedes recuperar.',
                          style: VntlText.body.copyWith(color: colors.textSecondary),
                        ),
                        const SizedBox(height: VntlSpacing.lg),
                        VntlInput(
                          hint: 'Buscar por nombre, SKU o producto...',
                          prefixIcon: Icons.search_rounded,
                          onChanged: _buscar,
                        ),
                        const SizedBox(height: VntlSpacing.lg),
                        if (ctrl.isLoadingInactivas && ctrl.variantesInactivas.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: VntlSpacing.xl),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (ctrl.errorInactivas != null && ctrl.variantesInactivas.isEmpty)
                          _ErrorState(message: ctrl.errorInactivas!)
                        else if (ctrl.variantesInactivas.isEmpty)
                          const _EmptyState()
                        else
                          _ListaInactivas(
                            items: ctrl.variantesInactivas,
                            formatearFecha: _formatearFecha,
                            onEditar: _abrirEditor,
                            onReactivar: _reactivar,
                          ),
                        if (ctrl.isLoadingInactivas && ctrl.variantesInactivas.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: VntlSpacing.lg),
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          ),
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

class _ListaInactivas extends StatelessWidget {
  const _ListaInactivas({
    required this.items,
    required this.formatearFecha,
    required this.onEditar,
    required this.onReactivar,
  });

  final List<VarianteInactiva> items;
  final String Function(DateTime?) formatearFecha;
  final void Function(VarianteInactiva) onEditar;
  final void Function(VarianteInactiva) onReactivar;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.glassSurface,
        borderRadius: VntlRadius.lgBorderRadius,
        border: Border.all(color: colors.border, width: 0.5),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _InactivaTile(
              inactiva: items[i],
              fechaTexto: formatearFecha(items[i].desactivadaEn),
              onTap: () => onEditar(items[i]),
              onReactivar: () => onReactivar(items[i]),
            ),
            if (i < items.length - 1)
              Divider(color: colors.border, height: 0.5, indent: VntlSpacing.xl),
          ],
        ],
      ),
    );
  }
}

class _InactivaTile extends StatelessWidget {
  const _InactivaTile({
    required this.inactiva,
    required this.fechaTexto,
    required this.onTap,
    required this.onReactivar,
  });

  final VarianteInactiva inactiva;
  final String fechaTexto;
  final VoidCallback onTap;
  final VoidCallback onReactivar;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final variante = inactiva.variante;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: VntlSpacing.lg,
            vertical: VntlSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.surfaceSecondary,
                  borderRadius: VntlRadius.mdBorderRadius,
                ),
                child: Icon(Icons.inventory_2_outlined, size: 18, color: colors.textTertiary),
              ),
              const SizedBox(width: VntlSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            variante.nombre,
                            style: VntlText.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: VntlSpacing.sm),
                        Text(
                          '\$${variante.precioFinal.toStringAsFixed(2)}',
                          style: VntlText.label.copyWith(color: colors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: VntlSpacing.xs),
                    Text(
                      [
                        inactiva.productoNombre,
                        if (variante.sku != null) 'SKU: ${variante.sku}',
                        if (fechaTexto.isNotEmpty) 'Desactivada: $fechaTexto',
                      ].join(' · '),
                      style: VntlText.caption.copyWith(color: colors.textTertiary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: VntlSpacing.md),
              VntlButton(
                label: 'Reactivar',
                variant: VntlButtonVariant.secondary,
                fullWidth: false,
                size: VntlButtonSize.sm,
                onPressed: onReactivar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(VntlSpacing.xl * 1.5),
      decoration: BoxDecoration(
        color: colors.glassSurface,
        borderRadius: VntlRadius.lgBorderRadius,
        border: Border.all(color: colors.border, width: 0.5),
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle_outline_rounded, size: 48, color: colors.textTertiary),
          const SizedBox(height: VntlSpacing.lg),
          Text('No tienes variantes inactivas', style: VntlText.h4),
          const SizedBox(height: VntlSpacing.sm),
          Text(
            'Las variantes que elimines aparecerán aquí.',
            style: VntlText.body.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: VntlSpacing.xl),
      child: Text(message, style: VntlText.body.copyWith(color: colors.error)),
    );
  }
}
