import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:url_launcher/url_launcher.dart';

class VntlSidebarItem {
  final String label;
  final IconData icon;
  final String route;
  final int? badgeCount;
  final Color? color;
  final String? permiso; // ← nuevo

  const VntlSidebarItem({
    required this.label,
    required this.icon,
    required this.route,
    this.badgeCount,
    this.color,
    this.permiso, // ← nuevo
  });
}

class VntlSidebar extends StatelessWidget {
  final List<VntlSidebarItem> items;
  final String currentRoute;
  final ValueChanged<String> onRouteSelected;
  final bool collapsed;
  final String userRole;

  const VntlSidebar({
    super.key,
    required this.items,
    required this.currentRoute,
    required this.onRouteSelected,
    required this.userRole,
    this.collapsed = false,
  });

  static const double expandedWidth = 240.0;
  static const double collapsedWidth = 64.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: collapsed ? collapsedWidth : expandedWidth,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: colors.glassSurface,
              border: Border(right: BorderSide(color: colors.glassBorder, width: 0.5)),
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
                      return _SidebarTile(
                        item: item,
                        isActive: currentRoute == item.route,
                        collapsed: collapsed,
                        onTap: () => onRouteSelected(item.route),
                      );
                    },
                  ),
                ),
                Divider(color: colors.border, thickness: 0.5),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: VntlSpacing.sm,
                    vertical: VntlSpacing.sm,
                  ),
                  child: Column(
                    children: [
                      _SidebarTile(
                        item: const VntlSidebarItem(
                          label: 'Soporte',
                          icon: Icons.support_agent_rounded,
                          route: '/soporte',
                          color: Color(0xFF4ADE80),
                        ),
                        isActive: false,
                        collapsed: collapsed,
                        onTap: () async {
                          final uri = Uri.parse('https://wa.me/522713164997');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                      ),
                      if (userRole == 'admin') ...[
                        const SizedBox(height: VntlSpacing.xs),
                        _SidebarTile(
                          item: const VntlSidebarItem(
                            label: 'Preferencias',
                            icon: Icons.settings_rounded,
                            route: '/preferencias',
                            color: Color(0xFF8A8A8A),
                          ),
                          isActive: false,
                          collapsed: collapsed,
                          onTap: () => Navigator.pushNamed(context, '/preferencias'),
                        ),
                      ],
                    ],
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
    final colors = context.colors;
    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(
        horizontal: collapsed ? VntlSpacing.sm : VntlSpacing.lg,
      ),
      child: Row(
        mainAxisAlignment: collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: colors.backgroundGradient,
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
    final colors = context.colors;
    final color = isActive ? (item.color ?? colors.primary) : colors.textSecondary;
    final surfaceColor =
        item.color != null ? item.color!.withValues(alpha: 0.12) : colors.primarySurface;

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
                  color: (item.color ?? colors.primary).withValues(alpha: 0.25),
                  width: 0.5,
                )
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
                  padding: const EdgeInsets.symmetric(horizontal: VntlSpacing.xs, vertical: 2),
                  decoration: BoxDecoration(
                    color: item.color ?? colors.primary,
                    borderRadius: VntlRadius.fullBorderRadius,
                  ),
                  child: Text(
                    item.badgeCount.toString(),
                    style:
                        VntlText.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
