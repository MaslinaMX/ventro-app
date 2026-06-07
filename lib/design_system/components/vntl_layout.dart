import 'package:flutter/material.dart';
import 'package:ventro_app/design_system/vntl.dart';

// ✅ Ventro Design System V1 — VntlLayout
class VntlLayout extends StatefulWidget {
  final String title;
  final Widget child;
  final List<VntlSidebarItem> sidebarItems;
  final String currentRoute;
  final ValueChanged<String> onRouteSelected;
  final List<Widget>? appBarActions;

  const VntlLayout({
    super.key,
    required this.title,
    required this.child,
    required this.sidebarItems,
    required this.currentRoute,
    required this.onRouteSelected,
    this.appBarActions,
  });

  @override
  State<VntlLayout> createState() => _VntlLayoutState();
}

class _VntlLayoutState extends State<VntlLayout> {
  bool _sidebarCollapsed = false;

  // Breakpoint para colapsar sidebar automáticamente
  static const double _collapseBreakpoint = 900.0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final autoCollapse = width < _collapseBreakpoint;
    final collapsed = autoCollapse || _sidebarCollapsed;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: VntlColors.backgroundGradient,
        ),
        child: Column(
          children: [
            VntlAppBar(
              title: widget.title,
              actions: widget.appBarActions,
              onMenuTap: autoCollapse
                  ? null
                  : () => setState(() => _sidebarCollapsed = !_sidebarCollapsed),
            ),
            Expanded(
              child: Row(
                children: [
                  VntlSidebar(
                    items: widget.sidebarItems,
                    currentRoute: widget.currentRoute,
                    onRouteSelected: widget.onRouteSelected,
                    collapsed: collapsed,
                  ),
                  Expanded(
                    child: ClipRect(
                      child: widget.child,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
