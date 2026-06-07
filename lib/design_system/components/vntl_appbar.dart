import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ventro_app/design_system/vntl.dart';

// ✅ Ventro Design System V1 — VntlAppBar
class VntlAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final VoidCallback? onMenuTap;
  final Widget? leading;

  const VntlAppBar({
    super.key,
    required this.title,
    this.actions,
    this.onMenuTap,
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 64,
          decoration: const BoxDecoration(
            color: VntlColors.glassSurface,
            border: Border(
              bottom: BorderSide(color: VntlColors.glassBorder, width: 0.5),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: VntlSpacing.lg),
          child: Row(
            children: [
              if (onMenuTap != null)
                GestureDetector(
                  onTap: onMenuTap,
                  child: const Icon(
                    Icons.menu_rounded,
                    color: VntlColors.textSecondary,
                    size: 22,
                  ),
                ),
              if (leading != null) leading!,
              const SizedBox(width: VntlSpacing.md),
              Expanded(
                child: Text(title, style: VntlText.h4),
              ),
              if (actions != null) ...actions!,
            ],
          ),
        ),
      ),
    );
  }
}
