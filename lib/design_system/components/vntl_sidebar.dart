import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ventro_app/features/auth/models/user_model.dart';

class VntlSidebarItem {
  final String label;
  final IconData icon;
  final String route;
  final int? badgeCount;
  final Color? color;
  final String? permiso;
  final String? section;

  const VntlSidebarItem(
      {required this.label,
      required this.icon,
      required this.route,
      this.badgeCount,
      this.color,
      this.permiso,
      this.section});
}

class VntlSidebar extends StatefulWidget {
  final List<VntlSidebarItem> items;
  final String currentRoute;
  final ValueChanged<String> onRouteSelected;
  final bool collapsed;
  final UserRole userRole;

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
  State<VntlSidebar> createState() => _VntlSidebarState();
}

class _VntlSidebarState extends State<VntlSidebar> {
  final Map<String, bool> _expandedSections = {
    'OPERACIÓN DIARIA': true,
    'CATÁLOGO': true,
    'CADENA DE SUMINISTRO': true,
    'PERSONAS Y ANÁLISIS': true,
  };
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    String? activeSection;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: widget.collapsed ? VntlSidebar.collapsedWidth : VntlSidebar.expandedWidth,
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
                _SidebarHeader(collapsed: widget.collapsed),
                const SizedBox(height: VntlSpacing.lg),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final colors = context.colors;
                      final children = <Widget>[];
                      final rootItems = <VntlSidebarItem>[];
                      final sectionItems = <String, List<VntlSidebarItem>>{};
                      for (final item in widget.items) {
                        if (item.section == null) {
                          rootItems.add(item);
                        } else {
                          sectionItems.putIfAbsent(item.section!, () => []);
                          sectionItems[item.section!]!.add(item);
                        }
                      }
                      // ───── Items sin sección (Principal) ─────
                      for (final item in rootItems) {
                        children.add(
                          Padding(
                            padding: const EdgeInsets.only(bottom: VntlSpacing.xs),
                            child: _SidebarTile(
                              item: item,
                              isActive: widget.currentRoute == item.route,
                              collapsed: widget.collapsed,
                              onTap: () => widget.onRouteSelected(item.route),
                            ),
                          ),
                        );
                      }

                      for (final item in widget.items) {
                        if (item.route == widget.currentRoute) {
                          activeSection = item.section;
                          break;
                        }
                      }

                      // ───── Secciones ─────
                      sectionItems.forEach((section, items) {
                        if (!widget.collapsed) {
                          children.add(
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                VntlSpacing.md,
                                VntlSpacing.lg,
                                VntlSpacing.md,
                                VntlSpacing.sm,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  if (widget.collapsed) return;
                                  if (section == activeSection) return;

                                  setState(() {
                                    _expandedSections[section] =
                                        !(_expandedSections[section] ?? true);
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    VntlSpacing.md,
                                    VntlSpacing.xs,
                                    VntlSpacing.md,
                                    VntlSpacing.xs,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          section,
                                          style: VntlText.caption.copyWith(
                                            color: colors.textTertiary,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        (_expandedSections[section] ?? true)
                                            ? Icons.keyboard_arrow_down_rounded
                                            : Icons.keyboard_arrow_right_rounded,
                                        size: 18,
                                        color: colors.textTertiary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        if (widget.collapsed ||
                            section == activeSection ||
                            (_expandedSections[section] ?? true)) {
                          for (final item in items) {
                            children.add(
                              Padding(
                                padding: const EdgeInsets.only(bottom: VntlSpacing.xs),
                                child: _SidebarTile(
                                  item: item,
                                  isActive: widget.currentRoute == item.route,
                                  collapsed: widget.collapsed,
                                  onTap: () => widget.onRouteSelected(item.route),
                                ),
                              ),
                            );
                          }
                        }
                      });
                      return ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: VntlSpacing.sm,
                          vertical: VntlSpacing.xs,
                        ),
                        children: children,
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
                        collapsed: widget.collapsed,
                        onTap: () async {
                          final uri = Uri.parse('https://wa.me/522713164997');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                      ),
                      if (widget.userRole.isAdmin) ...[
                        const SizedBox(height: VntlSpacing.xs),
                        _SidebarTile(
                          item: const VntlSidebarItem(
                            label: 'Preferencias',
                            icon: Icons.settings_rounded,
                            route: '/preferencias',
                            color: Color(0xFF8A8A8A),
                          ),
                          isActive: false,
                          collapsed: widget.collapsed,
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
