import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/helpers/vntl_payment_style.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/metodos_pago/controllers/metodo_pago_controller.dart';
import 'package:ventro_app/features/metodos_pago/models/metodo_pago_model.dart';
import 'package:ventro_app/features/metodos_pago/widgets/metodo_pago_form_sheet.dart';

class MetodosPagoSettingsSection extends StatefulWidget {
  const MetodosPagoSettingsSection({super.key});

  @override
  State<MetodosPagoSettingsSection> createState() => _MetodosPagoSettingsSectionState();
}

class _MetodosPagoSettingsSectionState extends State<MetodosPagoSettingsSection> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      context.read<MetodoPagoController>().loadMetodosPago();
    }
  }

  Future<void> _openForm({MetodoPagoModel? metodo}) async {
    await VntlModal.show(
      context,
      title: metodo == null ? 'Nuevo Método de Pago' : 'Editar Método de Pago',
      subtitle: metodo == null ? 'Agrega un nuevo método' : metodo.nombre,
      width: 480,
      content: MetodoPagoFormSheet(metodoPago: metodo),
    );
  }

  Future<void> _confirmDelete(MetodoPagoModel metodo) async {
    final colors = context.colors;
    final confirmed = await VntlModal.show<bool>(
      context,
      title: 'Eliminar Método de Pago',
      subtitle: '¿Estás seguro? Esta acción no se puede deshacer.',
      width: 440,
      content: Text(
        'Se eliminará "${metodo.nombre}" de forma permanente.',
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
    final ctrl = context.read<MetodoPagoController>();
    final ok = await ctrl.deleteMetodoPago(metodo.id);
    if (!mounted) return;
    VntlToast.show(
      context,
      message: ok ? 'Método de pago eliminado' : ctrl.errorMessage ?? 'Error al eliminar',
      type: ok ? VntlToastType.error : VntlToastType.success,
    );
  }

  Future<void> _toggleActivo(MetodoPagoModel metodo) async {
    final ctrl = context.read<MetodoPagoController>();
    await ctrl.editMetodoPago(metodo.id, {'activo': !metodo.activo});
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<MetodoPagoController>();

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
                  child: Text('Métodos de Pago', style: VntlText.h3),
                ),
                VntlButton(
                  label: 'Agregar Método',
                  icon: Icons.add_rounded,
                  onPressed: () => _openForm(),
                ),
              ],
            ),
            const SizedBox(height: VntlSpacing.xl),
            if (ctrl.metodosPago.isEmpty)
              _EmptyState(onAdd: () => _openForm())
            else
              ...ctrl.metodosPago.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: VntlSpacing.md),
                    child: _MetodoPagoCard(
                      metodo: m,
                      onEdit: () => _openForm(metodo: m),
                      onDelete: () => _confirmDelete(m),
                      onToggleActivo: () => _toggleActivo(m),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

// ─── Card ─────────────────────────────────────────────────────────────────────
class _MetodoPagoCard extends StatelessWidget {
  final MetodoPagoModel metodo;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActivo;

  const _MetodoPagoCard({
    required this.metodo,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActivo,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = VntlPaymentStyle.forMetodo(
      context,
      metodo.id,
      iconoKey: metodo.icono,
      colorHex: metodo.color,
    );

    return Container(
      padding: const EdgeInsets.all(VntlSpacing.lg),
      decoration: BoxDecoration(
        color: colors.glassSurface,
        borderRadius: VntlRadius.lgBorderRadius,
        border: Border.all(
          color: !metodo.isDeletable ? colors.primary.withValues(alpha: 0.3) : colors.border,
          width: 0.5,
        ),
      ),
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
          const SizedBox(width: VntlSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(metodo.nombre, style: VntlText.h4),
                if (metodo.requiereReferencia) ...[
                  const SizedBox(height: VntlSpacing.xs),
                  Text(
                    'Requiere referencia o folio',
                    style: VntlText.caption.copyWith(color: colors.textTertiary),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: metodo.activo,
            activeColor: colors.primary,
            onChanged: (_) => onToggleActivo(),
          ),
          const SizedBox(width: VntlSpacing.sm),
          VntlButton(
            label: null,
            variant: VntlButtonVariant.secondary,
            size: VntlButtonSize.sm,
            icon: Icons.edit_rounded,
            onPressed: onEdit,
          ),
          if (metodo.isDeletable) ...[
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
        Icon(Icons.credit_card_rounded, size: 48, color: colors.textTertiary),
        const SizedBox(height: VntlSpacing.lg),
        Text('Sin métodos de pago', style: VntlText.h4),
        const SizedBox(height: VntlSpacing.sm),
        Text(
          'Agrega tu primer método de pago para comenzar.',
          style: VntlText.body.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}
