import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/auth/controllers/auth_controller.dart';
import 'package:ventro_app/features/auth/models/auth_model.dart';

class VntlAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final VoidCallback? onMenuTap;
  final Widget? leading;
  final bool showUserMenu;

  const VntlAppBar({
    super.key,
    required this.title,
    this.actions,
    this.onMenuTap,
    this.leading,
    this.showUserMenu = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: colors.glassSurface,
            border: Border(bottom: BorderSide(color: colors.glassBorder, width: 0.5)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: VntlSpacing.lg),
          child: Row(
            children: [
              if (onMenuTap != null)
                GestureDetector(
                  onTap: onMenuTap,
                  child: Icon(Icons.menu_rounded, color: colors.textSecondary, size: 22),
                ),
              if (leading != null) leading!,
              const SizedBox(width: VntlSpacing.md),
              Expanded(child: Text(title, style: VntlText.h4)),
              if (actions != null) ...actions!,
              if (showUserMenu) ...[
                const SizedBox(width: VntlSpacing.md),
                const _NotificationButton(),
                const SizedBox(width: VntlSpacing.sm),
                const _UserMenuButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return _AppBarDropdown(
      button: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: colors.glassSurface,
          borderRadius: VntlRadius.mdBorderRadius,
          border: Border.all(color: colors.glassBorder, width: 0.5),
        ),
        child: Icon(Icons.notifications_outlined, color: colors.textSecondary, size: 18),
      ),
      dropdown: (close) => Container(
        width: 320,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: VntlRadius.lgBorderRadius,
          border: Border.all(color: colors.border, width: 0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(VntlSpacing.lg),
              child: Text('Notificaciones', style: VntlText.h4),
            ),
            Divider(color: colors.border, height: 0.5),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: VntlSpacing.xl3),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_off_outlined, size: 36, color: colors.textTertiary),
                    const SizedBox(height: VntlSpacing.md),
                    Text(
                      'No hay avisos nuevos',
                      textAlign: TextAlign.center,
                      style: VntlText.body.copyWith(color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            Divider(color: colors.border, height: 0.5),
            Padding(
              padding: const EdgeInsets.all(VntlSpacing.md),
              child: Center(
                child: Text(
                  'Ver todas las notificaciones',
                  style: VntlText.label.copyWith(color: colors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserMenuButton extends StatelessWidget {
  const _UserMenuButton();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final user = context.watch<AuthController>().user;
    final displayName = (user?.firstName?.isNotEmpty == true)
        ? '${user!.firstName} ${user.lastName ?? ''}'.trim()
        : (user?.name ?? '');
    final avatarLetter = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return _AppBarDropdown(
      button: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: colors.primarySurface,
              borderRadius: VntlRadius.fullBorderRadius,
            ),
            child: Center(
              child: Text(avatarLetter, style: VntlText.label.copyWith(color: colors.primary)),
            ),
          ),
          const SizedBox(width: VntlSpacing.sm),
          Text(displayName, style: VntlText.label),
          const SizedBox(width: VntlSpacing.xs),
          Icon(Icons.keyboard_arrow_down_rounded, color: colors.textSecondary, size: 16),
        ],
      ),
      dropdown: (close) => Container(
        width: 200,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: VntlRadius.lgBorderRadius,
          border: Border.all(color: colors.border, width: 0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (context.read<AuthController>().user?.role == UserRole.admin) ...[
              Divider(color: colors.border, height: 0.5, thickness: 0.5),
              _DropdownItem(
                icon: Icons.storefront_outlined,
                label: 'Mi negocio',
                color: colors.textPrimary,
                onTap: () {
                  close();
                  Navigator.pushNamed(context, '/cuenta');
                },
              ),
            ],
            _DropdownItem(
              icon: Icons.person_outline_rounded,
              label: 'Mi perfil',
              color: colors.textPrimary,
              onTap: () {
                close();
                Navigator.pushNamed(context, '/mi-perfil');
              },
            ),
            Divider(color: colors.border, height: 0.5, thickness: 0.5),
            _DropdownItem(
              icon: Icons.logout_rounded,
              label: 'Cerrar sesión',
              color: colors.destructive,
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: colors.surface,
                    shape: RoundedRectangleBorder(borderRadius: VntlRadius.lgBorderRadius),
                    title: const Text('Cerrar sesión', style: VntlText.h4),
                    content: Text(
                      '¿Estás seguro que deseas cerrar sesión?',
                      style: VntlText.body.copyWith(color: colors.textSecondary),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text('Cancelar',
                            style: VntlText.label.copyWith(color: colors.textSecondary)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text('Cerrar sesión',
                            style: VntlText.label.copyWith(color: colors.destructive)),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  await context.read<AuthController>().logout();
                  if (context.mounted) Navigator.pushReplacementNamed(context, '/');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DropdownItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: VntlSpacing.lg),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: VntlSpacing.md),
            Text(label, style: VntlText.label.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

class _AppBarDropdown extends StatefulWidget {
  final Widget button;
  final Widget Function(VoidCallback close) dropdown;

  const _AppBarDropdown({required this.button, required this.dropdown});

  @override
  State<_AppBarDropdown> createState() => _AppBarDropdownState();
}

class _AppBarDropdownState extends State<_AppBarDropdown> {
  final _key = GlobalKey();
  bool _disposed = false;

  OverlayEntry? _entry;

  void _toggle() => _entry != null ? _close() : _open();

  void _open() {
    final box = _key.currentContext!.findRenderObject() as RenderBox;
    final offset = box.localToGlobal(Offset.zero);
    final size = box.size;
    _entry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          GestureDetector(
            onTap: _close,
            behavior: HitTestBehavior.translucent,
            child: const SizedBox.expand(),
          ),
          Positioned(
            top: offset.dy + size.height + 8,
            right: MediaQuery.of(context).size.width - offset.dx - size.width,
            child: Material(color: Colors.transparent, child: widget.dropdown(_close)),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_entry!);
    setState(() {});
  }

  void _close() {
    if (_entry == null) return;
    _entry!.remove();
    _entry = null;
    setState(() {});
  }

  @override
  void dispose() {
    _entry?.remove();
    _entry = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(key: _key, onTap: _toggle, child: widget.button);
  }
}
