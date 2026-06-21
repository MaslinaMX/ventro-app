import 'package:flutter/material.dart';
import 'package:ventro_app/design_system/vntl.dart';

class VntlDialog extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? content;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool destructive;
  final bool isLoading;

  const VntlDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    this.confirmLabel = 'Confirmar',
    this.cancelLabel = 'Cancelar',
    this.onConfirm,
    this.onCancel,
    this.destructive = false,
    this.isLoading = false,
  });

  static Future<bool?> confirm(
    BuildContext context, {
    required String title,
    String? message,
    String confirmLabel = 'Confirmar',
    String cancelLabel = 'Cancelar',
    bool destructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => VntlDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        destructive: destructive,
        onConfirm: () => Navigator.pop(context, true),
        onCancel: () => Navigator.pop(context, false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(VntlSpacing.xl),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: VntlRadius.lgBorderRadius,
          border: Border.all(color: colors.border, width: 0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: VntlText.h4),
            if (message != null) ...[
              const SizedBox(height: VntlSpacing.sm),
              Text(message!, style: VntlText.body.copyWith(color: colors.textSecondary)),
            ],
            if (content != null) ...[
              const SizedBox(height: VntlSpacing.lg),
              content!,
            ],
            const SizedBox(height: VntlSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: onCancel ?? () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: VntlSpacing.lg,
                      vertical: VntlSpacing.sm,
                    ),
                    child: Text(
                      cancelLabel,
                      style: VntlText.label.copyWith(color: colors.textSecondary),
                    ),
                  ),
                ),
                const SizedBox(width: VntlSpacing.sm),
                VntlButton(
                  label: isLoading ? 'Cargando...' : confirmLabel,
                  onPressed: isLoading ? null : onConfirm,
                  variant: destructive ? VntlButtonVariant.danger : VntlButtonVariant.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
