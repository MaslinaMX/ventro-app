// lib/design_system/components/vntl_action_list.dart
import 'package:flutter/material.dart';
import 'package:ventro_app/design_system/vntl.dart';

/// Lista de acciones tipo menú: ícono + label + chevron, separadas por
/// líneas finas. Útil para agrupar acciones relacionadas (cambiar caja,
/// ver corte, cerrar caja, etc.) en un solo bloque visual.
///
/// Uso:
/// ```dart
/// VntlActionList(
///   items: [
///     VntlActionItem(icon: Icons.swap_horiz_rounded, label: 'Cambiar caja', onTap: ...),
///     VntlActionItem(icon: Icons.receipt_long_rounded, label: 'Ver Corte X', onTap: ...),
///     VntlActionItem(
///       icon: Icons.lock_rounded,
///       label: 'Cerrar Caja',
///       destructive: true,
///       onTap: ...,
///     ),
///   ],
/// )
/// ```
class VntlActionItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;
  final bool enabled;

  const VntlActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
    this.enabled = true,
  });
}

class VntlActionList extends StatelessWidget {
  final List<VntlActionItem> items;

  const VntlActionList({super.key, required this.items});

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
            if (i > 0) Divider(color: colors.border, height: 0.5),
            _ActionRow(item: items[i]),
          ],
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final VntlActionItem item;
  const _ActionRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = item.destructive ? colors.error : colors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.enabled ? item.onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: VntlSpacing.lg, vertical: VntlSpacing.md),
          child: Row(
            children: [
              Icon(item.icon, size: 18, color: item.enabled ? color : colors.textTertiary),
              const SizedBox(width: VntlSpacing.md),
              Expanded(
                child: Text(
                  item.label,
                  style: VntlText.label.copyWith(
                    color: item.enabled ? color : colors.textTertiary,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 18, color: colors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
