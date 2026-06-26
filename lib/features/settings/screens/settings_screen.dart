import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/auth/controllers/auth_controller.dart';
import 'package:ventro_app/features/auth/models/user_model.dart';
import 'package:ventro_app/features/caja/screens/cajas_settings_section.dart';
import 'package:ventro_app/features/gastos/screens/categorias_gasto_settings_section.dart';
import 'package:ventro_app/features/metodos_pago/screens/metodos_pago_settings_section.dart';
import 'package:ventro_app/features/settings/screens/partials/general_section.dart';
import 'package:ventro_app/features/settings/screens/partials/sucursales_sections.dart';
import 'package:ventro_app/features/tickets/screens/tickets_settings_section.dart';
import 'package:ventro_app/features/users/screens/users_section.dart';
import 'package:ventro_app/features/products/screens/partials/productos_settings_section.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _currentSection = 'general';

  static const double _collapseBreakpoint = 900.0;
  static const double _sidebarWidth = 220.0;
  static const double _sidebarCollapsedWidth = 64.0;

  List<_SettingsItem> get _visibleItems {
    final auth = context.read<AuthController>();
    final role = auth.user?.role ?? UserRole.vendedor;

    debugPrint('role recibido: $role, isAdmin: ${role?.isAdmin}');

    if (role.isAdmin) return _items;
    return const [
      _SettingsItem(label: 'General', icon: Icons.store_rounded, key: 'general'),
    ];
  }

  final List<_SettingsItem> _items = const [
    _SettingsItem(label: 'General', icon: Icons.store_rounded, key: 'general'),
    _SettingsItem(label: 'Usuarios', icon: Icons.people_rounded, key: 'usuarios'),
    _SettingsItem(label: 'Vendedores', icon: Icons.badge_rounded, key: 'vendedores'),
    _SettingsItem(label: 'Sucursales', icon: Icons.location_on_rounded, key: 'sucursales'),
    _SettingsItem(label: 'Cajas', icon: Icons.point_of_sale_rounded, key: 'cajas'),
    _SettingsItem(label: 'Productos', icon: Icons.inventory_2_rounded, key: 'productos'),
    _SettingsItem(label: 'Facturación', icon: Icons.receipt_rounded, key: 'facturacion'),
    _SettingsItem(label: 'Gastos', icon: Icons.sell_rounded, key: 'gastos'),
    _SettingsItem(label: 'Métodos de pago', icon: Icons.credit_card_rounded, key: 'pagos'),
    _SettingsItem(label: 'Tickets', icon: Icons.print_rounded, key: 'tickets'),
  ];

  _SettingsItem get _currentItem => _items.firstWhere((i) => i.key == _currentSection);

  Widget _buildSection(bool sidebarCollapsed) {
    switch (_currentSection) {
      case 'general':
        return GeneralSection(sidebarCollapsed: sidebarCollapsed);
      case 'sucursales':
        return const SucursalesSection();
      case 'usuarios':
        return const UsersSectionScreen();
      case 'productos':
        return const ProductosSettingsSection();
      case 'cajas':
        return const CajasSettingsSection();
      case 'pagos':
        return const MetodosPagoSettingsSection();
      case 'gastos':
        return const CategoriasGastoSettingsSection();
      case 'tickets':
        return const TicketsSettingsSection();
      default:
        return _SettingsPlaceholder(
          section: _currentItem.label,
          icon: _currentItem.icon,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final collapsed = width < _collapseBreakpoint;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: context.backgroundGradient,
        ),
        child: Column(
          children: [
            VntlAppBar(
              title: _currentItem.label,
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: colors.textSecondary,
                  size: 20,
                ),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  // ─── Sidebar ─────────────────────────────────────────
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    width: collapsed ? _sidebarCollapsedWidth : _sidebarWidth,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: colors.border, width: 0.5),
                      ),
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(VntlSpacing.sm),
                      itemCount: _visibleItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: VntlSpacing.xs),
                      itemBuilder: (context, index) {
                        final item = _visibleItems[index];
                        return _SettingsTile(
                          item: item,
                          isActive: _currentSection == item.key,
                          collapsed: collapsed,
                          onTap: () => setState(() => _currentSection = item.key),
                        );
                      },
                    ),
                  ),

                  // ─── Contenido ───────────────────────────────────────
                  Expanded(
                    child: ClipRect(
                      child: _buildSection(collapsed),
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

// ─── Tile ─────────────────────────────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final _SettingsItem item;
  final bool isActive;
  final bool collapsed;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.item,
    required this.isActive,
    required this.collapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 44,
        padding: EdgeInsets.symmetric(
          horizontal: collapsed ? VntlSpacing.sm : VntlSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isActive ? colors.primarySurface : Colors.transparent,
          borderRadius: VntlRadius.mdBorderRadius,
          border: isActive
              ? Border.all(
                  color: colors.primary.withValues(alpha: 0.25),
                  width: 0.5,
                )
              : null,
        ),
        child: Row(
          mainAxisAlignment: collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(
              item.icon,
              size: 18,
              color: isActive ? colors.primary : colors.textSecondary,
            ),
            if (!collapsed) ...[
              const SizedBox(width: VntlSpacing.md),
              Expanded(
                child: Text(
                  item.label,
                  style: VntlText.label.copyWith(
                    color: isActive ? colors.primary : colors.textSecondary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
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

// ─── Placeholder ──────────────────────────────────────────────────────────────
class _SettingsPlaceholder extends StatelessWidget {
  final String section;
  final IconData icon;

  const _SettingsPlaceholder({required this.section, required this.icon});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: colors.textTertiary),
          const SizedBox(height: VntlSpacing.lg),
          Text(section, style: VntlText.h3),
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

// ─── Model ────────────────────────────────────────────────────────────────────
class _SettingsItem {
  final String label;
  final IconData icon;
  final String key;

  const _SettingsItem({
    required this.label,
    required this.icon,
    required this.key,
  });
}
