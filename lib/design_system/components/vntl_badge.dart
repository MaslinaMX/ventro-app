import 'package:flutter/material.dart';
import '../vntl.dart';

// ✅ Ventro Design System V1 — VntlBadge
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
    final (bgColor, textColor) = switch (variant) {
      VntlBadgeVariant.primary => (VntlColors.primarySurface, VntlColors.primary),
      VntlBadgeVariant.success => (VntlColors.accentSurface, VntlColors.accent),
      VntlBadgeVariant.warning => (VntlColors.warningSurface, VntlColors.warning),
      VntlBadgeVariant.error => (VntlColors.errorSurface, VntlColors.error),
      VntlBadgeVariant.neutral => (VntlColors.glassSurface, VntlColors.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: VntlSpacing.sm,
        vertical: VntlSpacing.xs,
      ),
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
              decoration: BoxDecoration(
                color: textColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: VntlSpacing.xs),
          ],
          Text(
            label,
            style: VntlText.caption.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
