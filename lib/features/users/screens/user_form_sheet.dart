// ✅ V2

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/core/network/api_client.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/auth/models/auth_model.dart';
import 'package:ventro_app/features/settings/models/sucursal_model.dart';
import 'package:ventro_app/features/settings/services/settings_service.dart';
import 'package:ventro_app/features/users/controllers/users_controller.dart';

class UserFormSheet extends StatefulWidget {
  final UserModel? existing;
  const UserFormSheet({super.key, this.existing});

  @override
  State<UserFormSheet> createState() => _UserFormSheetState();
}

class _UserFormSheetState extends State<UserFormSheet> {
  final _formKey = GlobalKey<FormState>();
  List<SucursalModel> _sucursales = [];

  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _employeeNumber;
  late final TextEditingController _password;
  late final TextEditingController _pin;

  UserRole _role = UserRole.vendedor;
  int? _sucursalId;
  bool _isSeller = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final u = widget.existing;
    _firstName = TextEditingController(text: u?.firstName ?? '');
    _lastName = TextEditingController(text: u?.lastName ?? '');
    _email = TextEditingController(text: u?.email ?? '');
    _phone = TextEditingController(text: u?.phone ?? '');
    _employeeNumber = TextEditingController(text: u?.employeeNumber ?? '');
    _password = TextEditingController();
    _pin = TextEditingController();
    _role = u?.role ?? UserRole.vendedor;
    _sucursalId = u?.sucursalId;
    _isSeller = u?.isSeller ?? false;
    _loadSucursales();
  }

  @override
  void dispose() {
    for (final c in [_firstName, _lastName, _email, _phone, _employeeNumber, _password, _pin]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadSucursales() async {
    try {
      final list = await SettingsService().getSucursales();
      if (mounted) setState(() => _sucursales = list);
    } catch (_) {}
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ctrl = context.read<UsersController>();

    final data = <String, dynamic>{};
    data['first_name'] = _firstName.text.trim();
    data['last_name'] = _lastName.text.trim();
    data['email'] = _email.text.trim();
    data['role'] = _role.value;
    data['is_seller'] = _isSeller;
    if (_phone.text.isNotEmpty) data['phone'] = _phone.text.trim();
    if (_employeeNumber.text.isNotEmpty) data['employee_number'] = _employeeNumber.text.trim();
    if (_sucursalId != null) data['sucursal_id'] = _sucursalId;

    bool ok;
    if (_isEditing) {
      if (_password.text.isNotEmpty) data['password'] = _password.text;
      if (_pin.text.isNotEmpty) data['security_pin'] = _pin.text;
      ok = await ctrl.update(widget.existing!.id, data) != null;
    } else {
      // Al crear: sin password ni PIN, el backend pone defaults
      ok = await ctrl.create(data) != null;
    }

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final successColor = context.colors.success;
    final errorColor = context.colors.error;
    final errorMsg = ctrl.error ?? 'Error al guardar';

    if (ok) {
      Navigator.pop(context);
      messenger.showSnackBar(SnackBar(
        content: Text(_isEditing ? 'Usuario actualizado' : 'Usuario creado'),
        backgroundColor: successColor,
      ));
    } else {
      messenger.showSnackBar(SnackBar(
        content: Text(errorMsg),
        backgroundColor: errorColor,
      ));
    }
  }

  Future<void> _handleSecurityAction(
    BuildContext context, {
    required String accion,
  }) async {
    final password = await showDialog<String>(
      // ← String, no bool
      context: context,
      builder: (_) => _AdminPasswordDialog(colors: context.colors),
    );
    if (password == null || password.isEmpty || !mounted) return;

    try {
      final dio = ApiClient.instance;
      await dio.post(
        '/usuarios/${widget.existing!.id}/enviar-reset-$accion',
        data: {'admin_password': password},
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          accion == 'password'
              ? 'Correo de restablecimiento enviado'
              : 'Correo de restablecimiento de PIN enviado',
        ),
        backgroundColor: context.colors.success,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Contraseña incorrecta o error al enviar el correo.'),
        backgroundColor: context.colors.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ctrl = context.watch<UsersController>();

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Identidad ─────────────────────────────────────────────
          Text('Identidad', style: VntlText.label.copyWith(color: colors.textTertiary)),
          const SizedBox(height: VntlSpacing.md),
          Row(
            children: [
              Expanded(
                child: VntlInput(
                  label: 'Nombre',
                  controller: _firstName,
                  validator: (v) => (v?.isEmpty ?? true) ? 'Requerido' : null,
                ),
              ),
              const SizedBox(width: VntlSpacing.md),
              Expanded(
                child: VntlInput(
                  label: 'Apellido',
                  controller: _lastName,
                  validator: (v) => (v?.isEmpty ?? true) ? 'Requerido' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: VntlSpacing.lg),
          VntlInput(
            label: 'Email',
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v?.isEmpty ?? true) return 'Requerido';
              if (!v!.contains('@')) return 'Email inválido';
              return null;
            },
          ),
          const SizedBox(height: VntlSpacing.lg),
          Row(
            children: [
              Expanded(
                child: VntlInput(
                  label: 'Teléfono (opcional)',
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_rounded,
                ),
              ),
              const SizedBox(width: VntlSpacing.md),
              Expanded(
                child: VntlInput(
                  label: 'Núm. empleado (opcional)',
                  controller: _employeeNumber,
                  prefixIcon: Icons.badge_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: VntlSpacing.xl),

          // ── Rol ───────────────────────────────────────────────────
          Text('Rol', style: VntlText.label.copyWith(color: colors.textTertiary)),
          const SizedBox(height: VntlSpacing.md),
          Row(
            children: UserRole.values.where((r) => r != UserRole.personalizado).map((r) {
              final selected = _role == r;
              return Padding(
                padding: const EdgeInsets.only(right: VntlSpacing.sm),
                child: GestureDetector(
                  onTap: () => setState(() => _role = r),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: VntlSpacing.md,
                      vertical: VntlSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color:
                          selected ? colors.primary.withValues(alpha: 0.12) : colors.glassSurface,
                      borderRadius: VntlRadius.mdBorderRadius,
                      border: Border.all(
                        color: selected ? colors.primary : colors.border,
                        width: selected ? 1 : 0.5,
                      ),
                    ),
                    child: Text(
                      r.label,
                      style: VntlText.label.copyWith(
                        color: selected ? colors.primary : colors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: VntlSpacing.xl),

          // ── Asignación ────────────────────────────────────────────
          Text('Asignación', style: VntlText.label.copyWith(color: colors.textTertiary)),
          const SizedBox(height: VntlSpacing.md),
          if (_sucursales.isNotEmpty) ...[
            _VntlDropdown<int?>(
              label: 'Sucursal',
              value: _sucursalId,
              items: [
                const DropdownMenuItem(value: null, child: Text('Sin asignar')),
                ..._sucursales.map((s) => DropdownMenuItem(value: s.id, child: Text(s.nombre))),
              ],
              onChanged: (v) => setState(() => _sucursalId = v),
            ),
            const SizedBox(height: VntlSpacing.lg),
          ],
          _VntlSwitch(
            label: 'Es vendedor',
            subtitle: 'Puede registrar ventas en caja',
            value: _isSeller,
            onChanged: (v) => setState(() => _isSeller = v),
          ),
          const SizedBox(height: VntlSpacing.xl),

          // ── Seguridad ─────────────────────────────────────────────
          if (!_isEditing) ...[
            Text('Acceso', style: VntlText.label.copyWith(color: colors.textTertiary)),
            const SizedBox(height: VntlSpacing.md),
            Container(
              padding: const EdgeInsets.all(VntlSpacing.md),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.08),
                borderRadius: VntlRadius.mdBorderRadius,
                border: Border.all(color: colors.primary.withValues(alpha: 0.2), width: 0.5),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: colors.primary),
                  const SizedBox(width: VntlSpacing.sm),
                  Expanded(
                    child: Text(
                      'El usuario recibirá un correo para crear su contraseña, asi como crear su PIN de vendedor.',
                      style: VntlText.caption.copyWith(color: colors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: VntlSpacing.xl),
          ],

          if (_isEditing) ...[
            Text('Seguridad', style: VntlText.label.copyWith(color: colors.textTertiary)),
            const SizedBox(height: VntlSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _SecurityActionButton(
                    icon: Icons.lock_reset_rounded,
                    label: 'Restablecer contraseña',
                    subtitle: 'Se enviará un correo al usuario',
                    colors: colors,
                    onTap: () => _handleSecurityAction(
                      context,
                      accion: 'password',
                    ),
                  ),
                ),
                const SizedBox(width: VntlSpacing.md),
                Expanded(
                  child: _SecurityActionButton(
                    icon: Icons.pin_rounded,
                    label: 'Restablecer PIN',
                    subtitle: 'Se enviará un correo al usuario',
                    colors: colors,
                    onTap: () => _handleSecurityAction(
                      context,
                      accion: 'pin',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: VntlSpacing.xl),
          ],

          // ── Acciones ──────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              VntlButton(
                label: 'Cancelar',
                variant: VntlButtonVariant.ghost,
                onPressed: ctrl.isLoading ? null : () => Navigator.pop(context),
              ),
              const SizedBox(width: VntlSpacing.sm),
              VntlButton(
                label: _isEditing ? 'Guardar cambios' : 'Crear usuario',
                loading: ctrl.isLoading,
                onPressed: ctrl.isLoading ? null : _submit,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Componentes locales
// ─────────────────────────────────────────────────────────────────────────────

class _VntlDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;

  const _VntlDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: VntlText.caption.copyWith(color: colors.textSecondary)),
        const SizedBox(height: VntlSpacing.xs),
        Container(
          decoration: BoxDecoration(
            color: colors.glassSurface,
            borderRadius: VntlRadius.mdBorderRadius,
            border: Border.all(color: colors.border, width: 0.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: VntlSpacing.md),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor: colors.surface,
              style: VntlText.body.copyWith(color: colors.textPrimary),
              icon: Icon(Icons.unfold_more_rounded, color: colors.textTertiary, size: 18),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _VntlSwitch extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final void Function(bool) onChanged;

  const _VntlSwitch({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: VntlSpacing.md,
        vertical: VntlSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.glassSurface,
        borderRadius: VntlRadius.mdBorderRadius,
        border: Border.all(color: colors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: VntlText.label),
                Text(subtitle, style: VntlText.caption.copyWith(color: colors.textSecondary)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: colors.primary,
          ),
        ],
      ),
    );
  }
}

class _SecurityActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VntlColorScheme colors;
  final VoidCallback onTap;

  const _SecurityActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(VntlSpacing.md),
        decoration: BoxDecoration(
          color: colors.glassSurface,
          borderRadius: VntlRadius.mdBorderRadius,
          border: Border.all(color: colors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(VntlSpacing.sm),
              decoration: BoxDecoration(
                color: colors.warningSurface,
                borderRadius: VntlRadius.smBorderRadius,
              ),
              child: Icon(icon, size: 18, color: colors.warning),
            ),
            const SizedBox(width: VntlSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: VntlText.label.copyWith(color: colors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: VntlText.caption.copyWith(color: colors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: colors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _AdminPasswordDialog extends StatefulWidget {
  final VntlColorScheme colors;
  const _AdminPasswordDialog({required this.colors});

  @override
  State<_AdminPasswordDialog> createState() => _AdminPasswordDialogState();
}

class _AdminPasswordDialogState extends State<_AdminPasswordDialog> {
  final _controller = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(VntlSpacing.xl),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: VntlRadius.lgBorderRadius,
          border: Border.all(color: colors.border, width: 0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.admin_panel_settings_rounded, color: colors.warning, size: 32),
            const SizedBox(height: VntlSpacing.md),
            Text('Confirma tu identidad', style: VntlText.h4),
            const SizedBox(height: VntlSpacing.sm),
            Text(
              'Por seguridad, ingresa tu contraseña de administrador para continuar.',
              style: VntlText.body.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: VntlSpacing.xl),
            VntlInput(
              label: 'Tu contraseña',
              hint: '••••••••',
              controller: _controller,
              obscureText: _obscure,
              prefixIcon: Icons.lock_rounded,
              suffix: GestureDetector(
                onTap: () => setState(() => _obscure = !_obscure),
                child: Icon(
                  _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  size: 18,
                  color: colors.textTertiary,
                ),
              ),
            ),
            const SizedBox(height: VntlSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: VntlButton(
                    label: 'Cancelar',
                    variant: VntlButtonVariant.ghost,
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ),
                const SizedBox(width: VntlSpacing.sm),
                Expanded(
                  child: VntlButton(
                    label: 'Confirmar',
                    onPressed: () => Navigator.pop(context, _controller.text),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
