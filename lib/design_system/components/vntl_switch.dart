// lib/design_system/components/vntl_switch.dart
import 'package:flutter/material.dart';
import 'package:ventro_app/design_system/vntl.dart';

/// Switch del design system con label y tooltip informativo opcional.
///
/// Uso:
/// ```dart
/// VntlSwitch(
///   value: _tieneVariantes,
///   label: 'Este producto tiene variantes',
///   tooltip: 'Activa esto si vendes el mismo producto en diferentes '
///       'tamaños, sabores o presentaciones con precios distintos.',
///   onChanged: (v) => setState(() => _tieneVariantes = v),
/// )
/// ```
class VntlSwitch extends StatelessWidget {
  const VntlSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.tooltip,
  });

  /// Estado actual del switch.
  final bool value;

  /// Callback al cambiar el valor. Pasar null para deshabilitarlo.
  final ValueChanged<bool>? onChanged;

  /// Texto junto al switch. Si es null, solo se muestra el switch.
  final String? label;

  /// Mensaje del VntlTooltip junto al label. Solo aplica si label no es null.
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final switchWidget = Switch(
      value: value,
      activeColor: colors.primary,
      onChanged: onChanged,
    );

    if (label == null) return switchWidget;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        switchWidget,
        const SizedBox(width: VntlSpacing.sm),
        Expanded(
          child: Row(
            children: [
              Flexible(child: Text(label!, style: VntlText.body)),
              if (tooltip != null) ...[
                const SizedBox(width: VntlSpacing.xs),
                VntlTooltip(
                  message: tooltip!,
                  child: Icon(Icons.info_outline_rounded, size: 16, color: colors.textTertiary),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
