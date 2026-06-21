import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ventro_app/design_system/vntl.dart';

class VntlModal extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget content;
  final List<Widget>? actions;
  final double? width;
  final bool showClose;

  const VntlModal({
    super.key,
    required this.title,
    this.subtitle,
    required this.content,
    this.actions,
    this.width,
    this.showClose = true,
  });

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    String? subtitle,
    required Widget content,
    List<Widget>? actions,
    double? width,
    bool showClose = true,
  }) {
    if (kIsWeb || MediaQuery.of(context).size.width >= 600) {
      return showDialog<T>(
        context: context,
        builder: (_) => VntlModal(
          title: title,
          subtitle: subtitle,
          content: content,
          actions: actions,
          width: width,
          showClose: showClose,
        ),
      );
    } else {
      return showModalBottomSheet<T>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => VntlModalBottomSheet(
          title: title,
          subtitle: subtitle,
          content: content,
          actions: actions,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: width ?? 560,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: VntlRadius.lgBorderRadius,
          border: Border.all(color: colors.border, width: 0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: VntlSpacing.xl, vertical: VntlSpacing.lg),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: colors.border, width: 0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: VntlText.h4),
                        if (subtitle != null) ...[
                          const SizedBox(height: VntlSpacing.xs),
                          Text(subtitle!,
                              style: VntlText.body.copyWith(color: colors.textSecondary)),
                        ],
                      ],
                    ),
                  ),
                  if (showClose)
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: colors.glassSurface,
                          borderRadius: VntlRadius.mdBorderRadius,
                          border: Border.all(color: colors.border, width: 0.5),
                        ),
                        child: Icon(Icons.close_rounded, size: 16, color: colors.textSecondary),
                      ),
                    ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(VntlSpacing.xl),
                child: content,
              ),
            ),
            if (actions != null)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: VntlSpacing.xl, vertical: VntlSpacing.lg),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: colors.border, width: 0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!
                      .map((a) => Padding(
                            padding: const EdgeInsets.only(left: VntlSpacing.sm),
                            child: a,
                          ))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class VntlModalBottomSheet extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget content;
  final List<Widget>? actions;

  const VntlModalBottomSheet({
    super.key,
    required this.title,
    this.subtitle,
    required this.content,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: VntlSpacing.md),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: VntlSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: VntlSpacing.xl),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: VntlText.h4),
                      if (subtitle != null) ...[
                        const SizedBox(height: VntlSpacing.xs),
                        Text(subtitle!, style: VntlText.body.copyWith(color: colors.textSecondary)),
                      ],
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colors.glassSurface,
                      borderRadius: VntlRadius.mdBorderRadius,
                      border: Border.all(color: colors.border, width: 0.5),
                    ),
                    child: Icon(Icons.close_rounded, size: 16, color: colors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: VntlSpacing.lg),
          Divider(color: colors.border, height: 0.5),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(VntlSpacing.xl),
              child: content,
            ),
          ),
          if (actions != null) ...[
            Divider(color: colors.border, height: 0.5),
            Padding(
              padding: const EdgeInsets.all(VntlSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions!
                    .map((a) => Padding(
                          padding: const EdgeInsets.only(left: VntlSpacing.sm),
                          child: a,
                        ))
                    .toList(),
              ),
            ),
          ],
          const SizedBox(height: VntlSpacing.lg),
        ],
      ),
    );
  }
}
