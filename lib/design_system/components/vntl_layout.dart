import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/auth/controllers/auth_controller.dart';
import 'package:ventro_app/features/auth/models/user_model.dart';

class VntlLayout extends StatefulWidget {
  final String title;
  final Widget child;
  final List<VntlSidebarItem> sidebarItems;
  final String currentRoute;
  final ValueChanged<String> onRouteSelected;
  final List<Widget>? appBarActions;
  final bool showUserMenu;
  final bool forceCollapsed;

  const VntlLayout({
    super.key,
    required this.title,
    required this.child,
    required this.sidebarItems,
    required this.currentRoute,
    required this.onRouteSelected,
    this.appBarActions,
    this.showUserMenu = false,
    this.forceCollapsed = false,
  });

  @override
  State<VntlLayout> createState() => _VntlLayoutState();
}

class _VntlLayoutState extends State<VntlLayout> {
  bool _sidebarCollapsed = false;
  static const double _collapseBreakpoint = 900.0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final autoCollapse = width < _collapseBreakpoint;
    final collapsed = autoCollapse || _sidebarCollapsed || widget.forceCollapsed;
    final role = context.watch<AuthController>().user?.role ?? UserRole.vendedor;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: context.backgroundGradient),
        child: Column(
          children: [
            VntlAppBar(
              title: widget.title,
              showUserMenu: widget.showUserMenu,
              onMenuTap: (autoCollapse || widget.forceCollapsed)
                  ? null
                  : () => setState(() => _sidebarCollapsed = !_sidebarCollapsed),
            ),
            Expanded(
              child: Row(
                children: [
                  VntlSidebar(
                    userRole: role,
                    items: widget.sidebarItems,
                    currentRoute: widget.currentRoute,
                    onRouteSelected: widget.onRouteSelected,
                    collapsed: collapsed,
                  ),
                  Expanded(child: ClipRect(child: widget.child)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
