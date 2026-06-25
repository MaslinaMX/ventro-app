// ✅ V2

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/auth/controllers/auth_controller.dart';
import 'package:ventro_app/features/auth/models/user_model.dart';
import 'package:ventro_app/features/users/controllers/users_controller.dart';
import 'package:ventro_app/features/users/screens/user_form_sheet.dart';
import 'package:ventro_app/features/users/services/user_service.dart';

class UsersSectionScreen extends StatefulWidget {
  const UsersSectionScreen({super.key});

  @override
  State<UsersSectionScreen> createState() => _UsersSectionScreenState();
}

class _UsersSectionScreenState extends State<UsersSectionScreen> {
  late final UsersController _ctrl;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _ctrl = UsersController(UserService());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _ctrl.load();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _openForm({UserModel? user}) async {
    await VntlModal.show(
      context,
      title: user == null ? 'Nuevo usuario' : 'Editar usuario',
      subtitle: user == null ? 'Completa los datos del nuevo usuario' : user.name,
      width: 580,
      content: ChangeNotifierProvider.value(
        value: _ctrl,
        child: UserFormSheet(existing: user),
      ),
    );
  }

  Future<void> _confirmDelete(UserModel user) async {
    final colors = context.colors;
    final confirmed = await VntlModal.show<bool>(
      context,
      title: 'Eliminar usuario',
      subtitle: '¿Estás seguro? Esta acción no se puede deshacer.',
      width: 440,
      content: Text(
        'Se eliminará a "${user.name}" de forma permanente.',
        style: VntlText.body.copyWith(color: colors.textSecondary),
      ),
      actions: [
        VntlButton(
          label: 'Cancelar',
          variant: VntlButtonVariant.ghost,
          onPressed: () => Navigator.pop(context, false),
        ),
        VntlButton(
          label: 'Eliminar',
          variant: VntlButtonVariant.danger,
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
    if (confirmed != true || !mounted) return;
    final ok = await _ctrl.delete(user.id);
    if (!mounted) return;
    VntlToast.show(
      context,
      message: ok ? 'Usuario eliminado' : _ctrl.error ?? 'Error al eliminar',
      type: ok ? VntlToastType.success : VntlToastType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _ctrl,
      child: Consumer<UsersController>(
        builder: (context, ctrl, _) {
          final currentUserId = context.watch<AuthController>().user?.id;
          return Align(
            alignment: Alignment.topLeft,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(VntlSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(child: Text('Usuarios', style: VntlText.h3)),
                      VntlButton(
                        label: 'Nuevo usuario',
                        icon: Icons.person_add_rounded,
                        onPressed: () => _openForm(),
                      ),
                    ],
                  ),
                  const SizedBox(height: VntlSpacing.xl),

                  // ── Buscador ────────────────────────────────────────
                  VntlInput(
                    hint: 'Buscar por nombre, email o número...',
                    prefixIcon: Icons.search_rounded,
                    onChanged: ctrl.setQuery,
                  ),
                  const SizedBox(height: VntlSpacing.lg),

                  // ── Body ────────────────────────────────────────────
                  if (ctrl.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: VntlSpacing.xl),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (ctrl.status == UsersStatus.error)
                    _ErrorState(message: ctrl.error ?? 'Error al cargar usuarios')
                  else if (ctrl.filtered.isEmpty)
                    _EmptyState(onAdd: () => _openForm())
                  else
                    _UserList(
                      users: ctrl.filtered,
                      currentUserId: currentUserId,
                      onEdit: (u) => _openForm(user: u),
                      onDelete: _confirmDelete,
                      onToggle: (u) => ctrl.toggleActivo(u.id),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lista
// ─────────────────────────────────────────────────────────────────────────────

class _UserList extends StatelessWidget {
  final List<UserModel> users;
  final int? currentUserId;
  final void Function(UserModel) onEdit;
  final void Function(UserModel) onDelete;
  final void Function(UserModel) onToggle;

  const _UserList({
    required this.users,
    required this.currentUserId,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.glassSurface,
        borderRadius: VntlRadius.lgBorderRadius,
        border: Border.all(color: colors.border, width: 0.5),
      ),
      child: Column(
        children: [
          for (int i = 0; i < users.length; i++) ...[
            _UserTile(
              user: users[i],
              isSelf: users[i].id == currentUserId,
              onEdit: () => onEdit(users[i]),
              onDelete: () => onDelete(users[i]),
              onToggle: () => onToggle(users[i]),
            ),
            if (i < users.length - 1)
              Divider(color: colors.border, height: 0.5, indent: VntlSpacing.xl),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tile
// ─────────────────────────────────────────────────────────────────────────────

class _UserTile extends StatelessWidget {
  final UserModel user;
  final bool isSelf;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const _UserTile({
    required this.user,
    required this.isSelf,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  Color _avatarColor() {
    final hue = (user.name.codeUnitAt(0) * 37) % 360;
    return HSLColor.fromAHSL(1.0, hue.toDouble(), 0.55, 0.42).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';
    final avatarColor = _avatarColor();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: VntlSpacing.lg,
        vertical: VntlSpacing.md,
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: avatarColor.withValues(alpha: 0.15),
              borderRadius: VntlRadius.mdBorderRadius,
              border: Border.all(color: avatarColor.withValues(alpha: 0.3), width: 0.5),
            ),
            child: Center(
              child: Text(
                initial,
                style: VntlText.label.copyWith(
                  color: avatarColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: VntlSpacing.md),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(user.name, style: VntlText.label),
                    const SizedBox(width: VntlSpacing.sm),
                    VntlBadge(label: user.role.label),
                    if (!user.activo) ...[
                      const SizedBox(width: VntlSpacing.xs),
                      VntlBadge(label: 'Inactivo', variant: VntlBadgeVariant.warning),
                    ],
                  ],
                ),
                const SizedBox(height: VntlSpacing.xs),
                Text(
                  user.email,
                  style: VntlText.caption.copyWith(color: colors.textSecondary),
                ),
                if (user.employeeNumber != null || user.sucursal != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      [
                        if (user.employeeNumber != null) '#${user.employeeNumber}',
                        if (user.sucursal != null) user.sucursal!,
                      ].join(' · '),
                      style: VntlText.caption.copyWith(color: colors.textTertiary),
                    ),
                  ),
              ],
            ),
          ),

          // Acciones
          if (user.isDeletable || isSelf)
            PopupMenuButton<String>(
              color: colors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: VntlRadius.mdBorderRadius,
                side: BorderSide(color: colors.border, width: 0.5),
              ),
              icon: Icon(Icons.more_horiz_rounded, color: colors.textTertiary, size: 20),
              onSelected: (v) {
                if (v == 'edit') onEdit();
                if (v == 'toggle') onToggle();
                if (v == 'delete') onDelete();
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(children: [
                    Icon(Icons.edit_rounded, size: 15, color: colors.textSecondary),
                    const SizedBox(width: VntlSpacing.sm),
                    Text('Editar', style: VntlText.body.copyWith(color: colors.textPrimary)),
                  ]),
                ),
                // El creador del tenant (is_deletable=false) no puede desactivarse
                // ni eliminarse a sí mismo, solo editar sus datos.
                if (user.isDeletable) ...[
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(children: [
                      Icon(
                        user.activo ? Icons.block_rounded : Icons.check_circle_rounded,
                        size: 15,
                        color: colors.textSecondary,
                      ),
                      const SizedBox(width: VntlSpacing.sm),
                      Text(
                        user.activo ? 'Desactivar' : 'Activar',
                        style: VntlText.body.copyWith(color: colors.textPrimary),
                      ),
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_rounded, size: 15, color: colors.error),
                      const SizedBox(width: VntlSpacing.sm),
                      Text('Eliminar', style: VntlText.body.copyWith(color: colors.error)),
                    ]),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Estados vacío / error
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.group_rounded, size: 48, color: colors.textTertiary),
        const SizedBox(height: VntlSpacing.lg),
        Text('Sin usuarios', style: VntlText.h4),
        const SizedBox(height: VntlSpacing.sm),
        Text(
          'Agrega tu primer usuario para comenzar.',
          style: VntlText.body.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: VntlSpacing.xl),
        VntlButton(
          label: 'Nuevo usuario',
          icon: Icons.person_add_rounded,
          onPressed: onAdd,
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: VntlSpacing.xl),
      child: Text(message, style: VntlText.body.copyWith(color: colors.error)),
    );
  }
}
