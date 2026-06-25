import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/auth/controllers/auth_controller.dart';
import 'package:ventro_app/features/auth/models/user_model.dart';
import 'package:ventro_app/features/caja/screens/caja_operacion_screen.dart';
import 'package:ventro_app/features/inventario/screens/inventario_screen.dart';
import 'package:ventro_app/features/products/screens/productos_screen.dart';
import 'package:ventro_app/features/ventas/screens/venta_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _currentRoute = '/principal';

  List<VntlSidebarItem> get _allSidebarItems {
    final colors = context.colors;

    return [
      // Sin categoría
      VntlSidebarItem(
        label: 'Principal',
        icon: Icons.speed_rounded,
        route: '/principal',
        color: colors.primary,
        permiso: 'principal',
      ),

      // Operación diaria
      VntlSidebarItem(
        label: 'Caja',
        icon: Icons.point_of_sale_rounded,
        route: '/caja',
        color: colors.navCaja,
        permiso: 'caja',
        section: 'OPERACIÓN DIARIA',
      ),
      VntlSidebarItem(
        label: 'Ventas',
        icon: Icons.shopping_cart_rounded,
        route: '/ventas',
        color: colors.navVentas,
        permiso: 'ventas',
        section: 'OPERACIÓN DIARIA',
      ),
      VntlSidebarItem(
        label: 'Pedidos',
        icon: Icons.checklist_rounded,
        route: '/pedidos',
        color: colors.navPedidos,
        permiso: 'pedidos',
        section: 'OPERACIÓN DIARIA',
      ),

      // Catálogo
      VntlSidebarItem(
        label: 'Productos',
        icon: Icons.inventory_2_rounded,
        route: '/productos',
        color: colors.navProductos,
        permiso: 'productos',
        section: 'CATÁLOGO',
      ),
      VntlSidebarItem(
        label: 'Inventario',
        icon: Icons.warehouse_rounded,
        route: '/inventario',
        color: colors.navInventario,
        permiso: 'inventario',
        section: 'CATÁLOGO',
      ),
      VntlSidebarItem(
        label: 'Cotizaciones',
        icon: Icons.receipt_long_rounded,
        route: '/cotizaciones',
        color: colors.navCotizaciones,
        permiso: 'cotizaciones',
        section: 'CATÁLOGO',
      ),

      // Cadena de suministro
      VntlSidebarItem(
        label: 'Proveedores',
        icon: Icons.local_shipping_rounded,
        route: '/proveedores',
        color: colors.navProveedores,
        permiso: 'proveedores',
        section: 'CADENA DE SUMINISTRO',
      ),
      VntlSidebarItem(
        label: 'Compras',
        icon: Icons.add_shopping_cart_rounded,
        route: '/compras',
        color: colors.navCompras,
        permiso: 'compras',
        section: 'CADENA DE SUMINISTRO',
      ),

      // Personas y análisis
      VntlSidebarItem(
        label: 'Clientes',
        icon: Icons.people_rounded,
        route: '/clientes',
        color: colors.navClientes,
        permiso: 'clientes',
        section: 'PERSONAS Y ANÁLISIS',
      ),
      VntlSidebarItem(
        label: 'Reportes',
        icon: Icons.bar_chart_rounded,
        route: '/reportes',
        color: colors.navReportes,
        permiso: 'reportes',
        section: 'PERSONAS Y ANÁLISIS',
      ),
    ];
  }

  List<VntlSidebarItem> _filteredItems(UserModel user) {
    if (user.role.isAdmin) return _allSidebarItems;

    // vendedor
    const permitidosVendedor = {
      'principal',
      'caja',
      'cotizaciones',
      'productos',
      'ventas',
      'clientes'
    };
    return _allSidebarItems.where((item) => permitidosVendedor.contains(item.permiso)).toList();
  }

  void _onRouteSelected(String route) {
    setState(() => _currentRoute = route);
  }

  Widget _buildCurrentScreen() {
    switch (_currentRoute) {
      case '/principal':
        return _Placeholder(label: 'Principal', icon: Icons.speed_rounded);
      case '/caja':
        return const CajaOperacionScreen();
      case '/cotizaciones':
        return _Placeholder(label: 'Cotizaciones', icon: Icons.receipt_long_rounded);
      case '/productos':
        return const ProductosScreen();
      case '/ventas':
        return const VentaScreen();
      case '/pedidos':
        return _Placeholder(label: 'Pedidos', icon: Icons.checklist_rounded);
      case '/clientes':
        return _Placeholder(label: 'Clientes', icon: Icons.people_rounded);
      case '/inventario':
        return InventarioScreen(onNavigateToProductos: () => _onRouteSelected('/productos'));
      case '/proveedores':
        return _Placeholder(label: 'Proveedores', icon: Icons.local_shipping_rounded);
      case '/compras':
        return _Placeholder(label: 'Compras', icon: Icons.add_shopping_cart_rounded);
      case '/reportes':
        return _Placeholder(label: 'Reportes', icon: Icons.bar_chart_rounded);
      default:
        return _Placeholder(label: 'Principal', icon: Icons.speed_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;
    if (user == null) return const SizedBox.shrink();

    final items = _filteredItems(user);

    // Si la ruta actual ya no está disponible, ir a la primera
    if (!items.any((i) => i.route == _currentRoute) && items.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _currentRoute = items.first.route);
      });
    }

    final currentTitle =
        items.firstWhere((i) => i.route == _currentRoute, orElse: () => items.first).label;

    return VntlLayout(
      title: currentTitle,
      currentRoute: _currentRoute,
      sidebarItems: items, // ← filtrados, no _allSidebarItems
      onRouteSelected: _onRouteSelected,
      showUserMenu: true,
      forceCollapsed: _currentRoute == '/ventas',
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
    final colors = context.colors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: colors.textTertiary),
          const SizedBox(height: VntlSpacing.lg),
          Text(label, style: VntlText.h3),
          const SizedBox(height: VntlSpacing.sm),
          Text(
            'Próximamente',
            style: VntlText.body.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
