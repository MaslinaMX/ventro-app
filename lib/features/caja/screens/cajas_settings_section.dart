import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/caja/controllers/caja_controller.dart';
import 'package:ventro_app/features/caja/models/caja_model.dart';
import 'package:ventro_app/features/caja/widgets/caja_form_sheet.dart';

class CajasSettingsSection extends StatefulWidget {
  const CajasSettingsSection({super.key});

  @override
  State<CajasSettingsSection> createState() => _CajasSettingsSectionState();
}

class _CajasSettingsSectionState extends State<CajasSettingsSection> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      context.read<CajaController>().loadCajas();
    }
  }

  Future<void> _openForm({CajaModel? caja}) async {
    await VntlModal.show(
      context,
      title: caja == null ? 'Nueva Caja' : 'Editar Caja',
      subtitle: caja == null ? 'Agrega una nueva caja' : caja.nombre,
      width: 480,
      content: CajaFormSheet(caja: caja),
    );
  }

  Future<void> _confirmDelete(CajaModel caja) async {
    final colors = context.colors;
    final confirmed = await VntlModal.show<bool>(
      context,
      title: 'Eliminar Caja',
      subtitle: '¿Estás seguro? Esta acción no se puede deshacer.',
      width: 440,
      content: Text(
        'Se eliminará la caja "${caja.nombre}" de forma permanente.',
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
    if (confirmed != true || !mounted) return;
    final ctrl = context.read<CajaController>();
    final ok = await ctrl.deleteCaja(caja.id);
    if (!mounted) return;
    VntlToast.show(
      context,
      message: ok ? 'Caja eliminada' : (ctrl.errorMessage ?? 'Error al eliminar'),
      type: ok ? VntlToastType.success : VntlToastType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<CajaController>();

    if (ctrl.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Align(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(VntlSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cajas', style: VntlText.h3),
                      const SizedBox(height: VntlSpacing.xs),
                    ],
                  ),
                ),
                VntlButton(
                  label: 'Agregar Caja',
                  icon: Icons.add_rounded,
                  onPressed: () => _openForm(),
                ),
              ],
            ),
            const SizedBox(height: VntlSpacing.xl),
            if (ctrl.cajas.isEmpty)
              _EmptyState(onAdd: () => _openForm())
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final twoColumns = constraints.maxWidth >= 600;
                  return Wrap(
                    spacing: VntlSpacing.md,
                    runSpacing: VntlSpacing.md,
                    children: ctrl.cajas
                        .map((c) => SizedBox(
                              width: twoColumns
                                  ? (constraints.maxWidth - VntlSpacing.md) / 2
                                  : constraints.maxWidth,
                              child: _CajaCard(
                                caja: c,
                                onEdit: () => _openForm(caja: c),
                                onDelete: () => _confirmDelete(c),
                              ),
                            ))
                        .toList(),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Card ─────────────────────────────────────────────────────────────────────
class _CajaCard extends StatelessWidget {
  final CajaModel caja;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CajaCard({
    required this.caja,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(VntlSpacing.lg),
      decoration: BoxDecoration(
        color: colors.glassSurface,
        borderRadius: VntlRadius.lgBorderRadius,
        border: Border.all(
          color: !caja.isDeletable ? colors.primary.withValues(alpha: 0.3) : colors.border,
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(caja.nombre, style: VntlText.h4),
                    if (caja.tieneSesionAbierta) ...[
                      const SizedBox(width: VntlSpacing.sm),
                      Icon(Icons.circle, size: 8, color: colors.success),
                    ],
                  ],
                ),
                const SizedBox(height: VntlSpacing.xs),
                Row(
                  children: [
                    Icon(Icons.storefront_rounded, size: 14, color: colors.textTertiary),
                    const SizedBox(width: VntlSpacing.xs),
                    Text(
                      caja.sucursalNombre ?? '—',
                      style: VntlText.caption.copyWith(color: colors.textTertiary),
                    ),
                  ],
                ),
                const SizedBox(height: VntlSpacing.sm),
                Row(
                  children: [
                    Icon(Icons.person_rounded,
                        size: 14, color: caja.tieneSesionAbierta ? colors.success : colors.error),
                    const SizedBox(width: VntlSpacing.xs),
                    Text(
                      caja.tieneSesionAbierta
                          ? 'Abierta por ${caja.abiertaPorNombre}'
                          : 'Caja Cerrada',
                      style: VntlText.caption
                          .copyWith(color: caja.tieneSesionAbierta ? colors.success : colors.error),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: VntlSpacing.sm),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              VntlButton(
                label: null,
                variant: VntlButtonVariant.secondary,
                size: VntlButtonSize.sm,
                icon: Icons.edit_rounded,
                onPressed: onEdit,
              ),
              if (caja.isDeletable && !caja.tieneSesionAbierta) ...[
                const SizedBox(width: VntlSpacing.sm),
                VntlButton(
                  label: null,
                  variant: VntlButtonVariant.danger,
                  size: VntlButtonSize.sm,
                  icon: Icons.delete_rounded,
                  onPressed: onDelete,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.point_of_sale_rounded, size: 48, color: colors.textTertiary),
        const SizedBox(height: VntlSpacing.lg),
        Text('Sin cajas', style: VntlText.h4),
        const SizedBox(height: VntlSpacing.sm),
        Text(
          'Agrega tu primera caja para comenzar.',
          style: VntlText.body.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: VntlSpacing.xl),
        VntlButton(
          label: 'Agregar Caja',
          icon: Icons.add_rounded,
          onPressed: onAdd,
        ),
      ],
    );
  }
}
