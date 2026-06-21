import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/settings/controllers/settings_controller.dart';
import 'package:ventro_app/features/settings/models/sucursal_model.dart';
import 'package:ventro_app/features/settings/screens/partials/sucursal_form_sheet.dart';

class SucursalesSection extends StatefulWidget {
  const SucursalesSection({super.key});

  @override
  State<SucursalesSection> createState() => _SucursalesSectionState();
}

class _SucursalesSectionState extends State<SucursalesSection> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      context.read<SettingsController>().loadSucursales();
    }
  }

  Future<void> _openForm({SucursalModel? sucursal}) async {
    await VntlModal.show(
      context,
      title: sucursal == null ? 'Nueva Sucursal' : 'Editar Sucursal',
      subtitle: sucursal == null ? 'Agrega una nueva ubicación' : sucursal.nombre,
      width: 600,
      content: SucursalFormSheet(sucursal: sucursal),
    );
  }

  Future<void> _confirmDelete(SucursalModel sucursal) async {
    final colors = context.colors;
    final confirmed = await VntlModal.show<bool>(
      context,
      title: 'Eliminar Sucursal',
      subtitle: '¿Estás seguro? Esta acción no se puede deshacer.',
      width: 440,
      content: Text(
        'Se eliminará la sucursal "${sucursal.nombre}" de forma permanente.',
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
    final ctrl = context.read<SettingsController>();
    final ok = await ctrl.deleteSucursal(sucursal.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'Sucursal eliminada' : ctrl.errorMessage ?? 'Error al eliminar'),
      backgroundColor: ok ? colors.success : colors.error,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<SettingsController>();

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
                      Text('Sucursales', style: VntlText.h3),
                      const SizedBox(height: VntlSpacing.xs),
                    ],
                  ),
                ),
                VntlButton(
                  label: 'Agregar Sucursal',
                  icon: Icons.add_rounded,
                  onPressed: () => _openForm(),
                ),
              ],
            ),
            const SizedBox(height: VntlSpacing.xl),
            if (ctrl.sucursales.isEmpty)
              _EmptyState(onAdd: () => _openForm())
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final twoColumns = constraints.maxWidth >= 600;
                  return Wrap(
                    spacing: VntlSpacing.md,
                    runSpacing: VntlSpacing.md,
                    children: ctrl.sucursales
                        .map((s) => SizedBox(
                              width: twoColumns
                                  ? (constraints.maxWidth - VntlSpacing.md) / 2
                                  : constraints.maxWidth,
                              child: _SucursalCard(
                                sucursal: s,
                                onEdit: () => _openForm(sucursal: s),
                                onDelete: () => _confirmDelete(s),
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
class _SucursalCard extends StatelessWidget {
  final SucursalModel sucursal;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SucursalCard({
    required this.sucursal,
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
          color: sucursal.isMain ? colors.primary.withValues(alpha: 0.3) : colors.border,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Fila título + acciones ──────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sucursal.nombre, style: VntlText.h4),
                    const SizedBox(height: VntlSpacing.xs),
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
                  if (sucursal.isDeletable) ...[
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
          if (sucursal.direccion != null ||
              sucursal.ciudad != null ||
              sucursal.telefono != null ||
              sucursal.email != null) ...[
            const SizedBox(height: VntlSpacing.md),
            Divider(color: colors.border, height: 0.5),
            const SizedBox(height: VntlSpacing.md),
            _InfoGrid(sucursal: sucursal),
          ],
        ],
      ),
    );
  }
}

// ─── Info Grid ────────────────────────────────────────────────────────────────
class _InfoGrid extends StatelessWidget {
  final SucursalModel sucursal;
  const _InfoGrid({required this.sucursal});

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String, String?)>[
      if (sucursal.direccion != null) (Icons.location_on_rounded, 'Dirección', sucursal.direccion),
      if (sucursal.ciudad != null)
        (
          Icons.location_city_rounded,
          'Ciudad',
          '${sucursal.ciudad}${sucursal.estado != null ? ', ${sucursal.estado}' : ''}'
        ),
      if (sucursal.telefono != null) (Icons.phone_rounded, 'Teléfono', sucursal.telefono),
      if (sucursal.email != null) (Icons.email_rounded, 'Email', sucursal.email),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 480;
        if (twoColumns) {
          final rows = <Widget>[];
          for (var i = 0; i < items.length; i += 2) {
            rows.add(Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _InfoItem(item: items[i])),
                if (i + 1 < items.length) Expanded(child: _InfoItem(item: items[i + 1])),
              ],
            ));
            if (i + 2 < items.length) rows.add(const SizedBox(height: VntlSpacing.md));
          }
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items
              .map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: VntlSpacing.md),
                    child: _InfoItem(item: item),
                  ))
              .toList(),
        );
      },
    );
  }
}

class _InfoItem extends StatelessWidget {
  final (IconData, String, String?) item;
  const _InfoItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(item.$1, size: 14, color: colors.textTertiary),
        const SizedBox(width: VntlSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.$2, style: VntlText.caption.copyWith(color: colors.textTertiary)),
              Text(item.$3 ?? '', style: VntlText.label.copyWith(color: colors.textSecondary)),
            ],
          ),
        ),
      ],
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
        Icon(Icons.location_on_rounded, size: 48, color: colors.textTertiary),
        const SizedBox(height: VntlSpacing.lg),
        Text('Sin sucursales', style: VntlText.h4),
        const SizedBox(height: VntlSpacing.sm),
        Text(
          'Agrega tu primera sucursal para comenzar.',
          style: VntlText.body.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: VntlSpacing.xl),
        VntlButton(
          label: 'Agregar Sucursal',
          icon: Icons.add_rounded,
          onPressed: onAdd,
        ),
      ],
    );
  }
}
