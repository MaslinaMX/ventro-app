// lib/features/perfil/screens/mi_perfil_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/auth/controllers/auth_controller.dart';
import 'package:ventro_app/features/auth/models/user_model.dart';
import 'package:ventro_app/features/settings/screens/partials/change_password_screen.dart';
import 'package:ventro_app/features/settings/screens/partials/change_pin_screen.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = VntlColors.of(context);
    final user = context.watch<AuthController>().user!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text('Mi perfil', style: VntlText.h4),
        iconTheme: IconThemeData(color: colors.textPrimary),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: colors.border),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(VntlSpacing.md),
        children: [
          _UserHeader(user: user, colors: colors),
          const SizedBox(height: VntlSpacing.lg),
          _SectionLabel(label: 'Seguridad', colors: colors),
          const SizedBox(height: VntlSpacing.xs),
          _ProfileTile(
            icon: Icons.lock_outline_rounded,
            label: 'Cambiar contraseña',
            colors: colors,
            onTap: () => showDialog(
              context: context,
              barrierDismissible: true,
              builder: (_) => ChangePasswordDialog(
                onChanged: () => context.read<AuthController>().loadSession(),
              ),
            ),
          ),
          _ProfileTile(
            icon: Icons.pin_outlined,
            label: 'Cambiar PIN',
            subtitle: user.pinIsDefault ? 'Aún usas el PIN predeterminado' : null,
            subtitleColor: user.pinIsDefault ? colors.warning : null,
            colors: colors,
            onTap: () => showDialog(
              context: context,
              barrierDismissible: true,
              builder: (_) => ChangePinDialog(
                dismissible: true,
                onChanged: () {
                  // Refresca el usuario para que pinIsDefault se actualice
                  context.read<AuthController>().loadSession();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _UserHeader extends StatelessWidget {
  const _UserHeader({required this.user, required this.colors});

  final UserModel user;
  final VntlColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final initials = user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.all(VntlSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(VntlRadius.md),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: colors.primarySurface,
            child: Text(initials, style: VntlText.bodyLarge),
          ),
          const SizedBox(width: VntlSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.firstName} ${user.lastName}'.trim(),
                  style: VntlText.bodyLarge,
                ),
                const SizedBox(height: 2),
                Text(user.email, style: VntlText.bodySmall),
                if (user.sucursal != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.storefront_outlined, size: 12, color: colors.textTertiary),
                      const SizedBox(width: 4),
                      Text(user.sucursal!, style: VntlText.bodySmall),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: VntlSpacing.sm,
              vertical: VntlSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: colors.primarySurface,
              borderRadius: BorderRadius.circular(VntlRadius.sm),
            ),
            child: Text(
              user.role.label,
              style: VntlText.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.colors});

  final String label;
  final VntlColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: VntlSpacing.xs),
      child: Text(
        label.toUpperCase(),
        style: VntlText.labelSmall,
      ),
    );
  }
}

// ─── Tile ─────────────────────────────────────────────────────────────────────

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.colors,
    required this.onTap,
    this.subtitle,
    this.subtitleColor,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final Color? subtitleColor;
  final VntlColorScheme colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: VntlSpacing.xs),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(VntlRadius.md),
        border: Border.all(color: colors.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: colors.textSecondary, size: 20),
        title: Text(label, style: VntlText.body),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: VntlText.bodySmall,
              )
            : null,
        trailing: Icon(Icons.chevron_right_rounded, color: colors.textTertiary, size: 20),
        onTap: onTap,
      ),
    );
  }
}
