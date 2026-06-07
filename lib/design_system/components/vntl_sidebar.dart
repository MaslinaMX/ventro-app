import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ventro_app/design_system/vntl.dart';

// ✅ Ventro Design System V1 — VntlSidebar
class VntlSidebarItem {
  final String label;
  final IconData icon;
  final String route;
  final int? badgeCount;
  final Color? color; // ← nuevo

  const VntlSidebarItem({
    required this.label,
    required this.icon,
    required this.route,
    this.badgeCount,
    this.color,
  });
}

class VntlSidebar extends StatelessWidget {
  final List<VntlSidebarItem> items;
  final String currentRoute;
  final ValueChanged<String> onRouteSelected;
  final bool collapsed;

  const VntlSidebar({
    super.key,
    required this.items,
    required this.currentRoute,
    required this.onRouteSelected,
    this.collapsed = false,
  });

  static const double expandedWidth = 240.0;
  static const double collapsedWidth = 64.0;

  @override
  Widget build(BuildContext context) {
    final width = collapsed ? collapsedWidth : expandedWidth;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: width,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: const BoxDecoration(
              color: VntlColors.glassSurface,
              border: Border(
                right: BorderSide(color: VntlColors.glassBorder, width: 0.5),
              ),
            ),
            child: Column(
              children: [
                _SidebarHeader(collapsed: collapsed),
                const SizedBox(height: VntlSpacing.lg),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: VntlSpacing.sm,
                      vertical: VntlSpacing.xs,
                    ),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: VntlSpacing.xs),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isActive = currentRoute == item.route;
                      return _SidebarTile(
                        item: item,
                        isActive: isActive,
                        collapsed: collapsed,
                        onTap: () => onRouteSelected(item.route),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  final bool collapsed;
  const _SidebarHeader({required this.collapsed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(
        horizontal: collapsed ? VntlSpacing.sm : VntlSpacing.lg, // ← dinámico
      ),
      child: Row(
        mainAxisAlignment: collapsed // ← centrar icono cuando colapsado
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              gradient: VntlColors.backgroundGradient,
              borderRadius: VntlRadius.smBorderRadius,
            ),
            child: const Icon(Icons.point_of_sale_rounded, color: Colors.white, size: 18),
          ),
          if (!collapsed) ...[
            const SizedBox(width: VntlSpacing.md),
            const Text('Ventro', style: VntlText.h4),
          ],
        ],
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  final VntlSidebarItem item;
  final bool isActive;
  final bool collapsed;
  final VoidCallback onTap;

  const _SidebarTile({
    required this.item,
    required this.isActive,
    required this.collapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? (item.color ?? VntlColors.primary) : VntlColors.textSecondary;

    final surfaceColor =
        item.color != null ? item.color!.withValues(alpha: 0.12) : VntlColors.primarySurface;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 44,
        padding: EdgeInsets.symmetric(
          horizontal: collapsed ? VntlSpacing.sm : VntlSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isActive ? surfaceColor : Colors.transparent,
          borderRadius: VntlRadius.mdBorderRadius,
          border: isActive
              ? Border.all(
                  color: (item.color ?? VntlColors.primary).withValues(alpha: 0.25), width: 0.5)
              : null,
        ),
        child: Row(
          mainAxisAlignment: collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(item.icon, size: 20, color: color),
            if (!collapsed) ...[
              const SizedBox(width: VntlSpacing.md),
              Expanded(
                child: Text(
                  item.label,
                  style: VntlText.label.copyWith(
                    color: color,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              if (item.badgeCount != null && item.badgeCount! > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: VntlSpacing.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: item.color ?? VntlColors.primary,
                    borderRadius: VntlRadius.fullBorderRadius,
                  ),
                  child: Text(
                    item.badgeCount.toString(),
                    style: VntlText.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
