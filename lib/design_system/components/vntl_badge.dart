import 'package:flutter/material.dart';
import 'package:ventro_app/design_system/vntl.dart';

enum VntlBadgeVariant { primary, success, warning, error, neutral }

class VntlBadge extends StatelessWidget {
  final String label;
  final VntlBadgeVariant variant;
  final bool dot;

  const VntlBadge({
    super.key,
    required this.label,
    this.variant = VntlBadgeVariant.neutral,
    this.dot = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (bgColor, textColor) = switch (variant) {
      VntlBadgeVariant.primary => (colors.primarySurface, colors.primary),
      VntlBadgeVariant.success => (colors.successSurface, colors.success),
      VntlBadgeVariant.warning => (colors.warningSurface, colors.warning),
      VntlBadgeVariant.error => (colors.errorSurface, colors.error),
      VntlBadgeVariant.neutral => (colors.glassSurface, colors.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: VntlSpacing.sm, vertical: VntlSpacing.xs),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: VntlRadius.fullBorderRadius,
        border: Border.all(color: textColor.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: textColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: VntlSpacing.xs),
          ],
          Text(
            label,
            style: VntlText.caption.copyWith(color: textColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
