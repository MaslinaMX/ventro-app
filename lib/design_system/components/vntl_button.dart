import 'package:flutter/material.dart';
import 'package:ventro_app/design_system/vntl.dart';

// ✅ Ventro Design System V1 — VntlButton
enum VntlButtonVariant { primary, secondary, ghost, danger }

enum VntlButtonSize { sm, md, lg }

class VntlButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final VntlButtonVariant variant;
  final VntlButtonSize size;
  final IconData? icon;
  final bool loading;
  final bool fullWidth;

  const VntlButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = VntlButtonVariant.primary,
    this.size = VntlButtonSize.md,
    this.icon,
    this.loading = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final height = switch (size) {
      VntlButtonSize.sm => 36.0,
      VntlButtonSize.md => 44.0,
      VntlButtonSize.lg => 52.0,
    };

    final fontSize = switch (size) {
      VntlButtonSize.sm => 13.0,
      VntlButtonSize.md => 14.0,
      VntlButtonSize.lg => 16.0,
    };

    final padding = switch (size) {
      VntlButtonSize.sm => const EdgeInsets.symmetric(horizontal: VntlSpacing.md),
      VntlButtonSize.md => const EdgeInsets.symmetric(horizontal: VntlSpacing.lg),
      VntlButtonSize.lg => const EdgeInsets.symmetric(horizontal: VntlSpacing.xl2),
    };

    final (bgColor, textColor, borderColor) = switch (variant) {
      VntlButtonVariant.primary => (VntlColors.primary, VntlColors.textPrimary, Colors.transparent),
      VntlButtonVariant.secondary => (
          VntlColors.primarySurface,
          VntlColors.primary,
          VntlColors.primary
        ),
      VntlButtonVariant.ghost => (Colors.transparent, VntlColors.textSecondary, VntlColors.border),
      VntlButtonVariant.danger => (VntlColors.errorSurface, VntlColors.error, VntlColors.error),
    };

    final isDisabled = onPressed == null || loading;

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: textColor,
            ),
          )
        else if (icon != null) ...[
          Icon(icon, size: fontSize + 2, color: textColor),
          const SizedBox(width: VntlSpacing.sm),
        ],
        if (!loading)
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: isDisabled ? textColor.withValues(alpha: 0.4) : textColor,
            ),
          ),
      ],
    );

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height,
      child: GestureDetector(
        onTap: isDisabled ? null : onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: padding,
          decoration: BoxDecoration(
            color: isDisabled ? bgColor.withValues(alpha: 0.4) : bgColor,
            borderRadius: VntlRadius.mdBorderRadius,
            border: Border.all(
              color: borderColor == Colors.transparent ? Colors.transparent : borderColor,
              width: 1,
            ),
          ),
          child: Center(child: content),
        ),
      ),
    );
  }
}
