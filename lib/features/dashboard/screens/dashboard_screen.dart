import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/auth/controllers/auth_controller.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _currentRoute = '/ventas';

  final List<VntlSidebarItem> _sidebarItems = const [
    VntlSidebarItem(
      label: 'Ventas',
      icon: Icons.point_of_sale_rounded,
      route: '/ventas',
      color: VntlColors.navVentas,
    ),
    VntlSidebarItem(
      label: 'Productos',
      icon: Icons.inventory_2_rounded,
      route: '/productos',
      color: VntlColors.navProductos,
    ),
    VntlSidebarItem(
      label: 'Categorías',
      icon: Icons.category_rounded,
      route: '/categorias',
      color: VntlColors.navCategorias,
    ),
    VntlSidebarItem(
      label: 'Clientes',
      icon: Icons.people_rounded,
      route: '/clientes',
      color: VntlColors.navClientes,
    ),
    VntlSidebarItem(
      label: 'Reportes',
      icon: Icons.bar_chart_rounded,
      route: '/reportes',
      color: VntlColors.navReportes,
    ),
  ];

  void _onRouteSelected(String route) {
    setState(() => _currentRoute = route);
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: VntlColors.primarySurface,
        shape: RoundedRectangleBorder(borderRadius: VntlRadius.lgBorderRadius),
        title: const Text('Cerrar sesión', style: VntlText.h4),
        content: Text(
          '¿Estás seguro que deseas cerrar sesión?',
          style: VntlText.body.copyWith(color: VntlColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                Text('Cancelar', style: VntlText.label.copyWith(color: VntlColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Cerrar sesión', style: VntlText.label.copyWith(color: VntlColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context.read<AuthController>().logout();
      if (mounted) Navigator.pushReplacementNamed(context, '/');
    }
  }

  Widget _buildCurrentScreen() {
    switch (_currentRoute) {
      case '/ventas':
        return _Placeholder(label: 'Ventas', icon: Icons.point_of_sale_rounded);
      case '/productos':
        return _Placeholder(label: 'Productos', icon: Icons.inventory_2_rounded);
      case '/categorias':
        return _Placeholder(label: 'Categorías', icon: Icons.category_rounded);
      case '/clientes':
        return _Placeholder(label: 'Clientes', icon: Icons.people_rounded);
      case '/reportes':
        return _Placeholder(label: 'Reportes', icon: Icons.bar_chart_rounded);
      default:
        return _Placeholder(label: 'Ventas', icon: Icons.point_of_sale_rounded);
    }
  }

  String get _currentTitle {
    return _sidebarItems
        .firstWhere((i) => i.route == _currentRoute, orElse: () => _sidebarItems.first)
        .label;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;

    return VntlLayout(
      title: _currentTitle,
      currentRoute: _currentRoute,
      sidebarItems: _sidebarItems,
      onRouteSelected: _onRouteSelected,
      appBarActions: [
        // Usuario
        if (user != null)
          Padding(
            padding: const EdgeInsets.only(right: VntlSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: VntlColors.primarySurface,
                    borderRadius: VntlRadius.fullBorderRadius,
                  ),
                  child: Center(
                    child: Text(
                      (user.firstName ?? user.name).substring(0, 1).toUpperCase(),
                      style: VntlText.label.copyWith(color: VntlColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: VntlSpacing.sm),
                Text(
                  user.firstName ?? user.name,
                  style: VntlText.label.copyWith(color: VntlColors.textSecondary),
                ),
              ],
            ),
          ),
        // Logout
        GestureDetector(
          onTap: _logout,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: VntlColors.destructiveSurface,
              borderRadius: VntlRadius.mdBorderRadius,
              border: Border.all(
                color: VntlColors.destructive.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: const Icon(
              Icons.logout_rounded,
              color: VntlColors.destructive,
              size: 18,
            ),
          ),
        ),
      ],
      child: _buildCurrentScreen(),
    );
  }
}

// Placeholder temporal para cada sección
class _Placeholder extends StatelessWidget {
  final String label;
  final IconData icon;

  const _Placeholder({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: VntlColors.textTertiary),
          const SizedBox(height: VntlSpacing.lg),
          Text(label, style: VntlText.h3),
          const SizedBox(height: VntlSpacing.sm),
          Text(
            'Próximamente',
            style: VntlText.body.copyWith(color: VntlColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
