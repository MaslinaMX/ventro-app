import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/auth/controllers/auth_controller.dart';
import 'package:ventro_app/features/auth/models/user_model.dart';
import 'package:ventro_app/features/caja/controllers/caja_controller.dart';
import 'package:ventro_app/features/caja/models/caja_model.dart';
import 'package:ventro_app/features/settings/models/sucursal_model.dart';
import 'package:ventro_app/features/settings/services/settings_service.dart';

class CajaFormSheet extends StatefulWidget {
  final CajaModel? caja;
  const CajaFormSheet({super.key, this.caja});

  @override
  State<CajaFormSheet> createState() => _CajaFormSheetState();
}

class _CajaFormSheetState extends State<CajaFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;

  bool get _isEditing => widget.caja != null;

  bool _esAdmin = false;
  List<SucursalModel> _sucursales = [];
  int? _sucursalSeleccionadaId;
  String? _sucursalNombreFijo;
  bool _loadingSucursales = false;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.caja?.nombre ?? '');
    _initSucursalScope();
  }

  Future<void> _initSucursalScope() async {
    final user = context.read<AuthController>().user;
    _esAdmin = user?.role.isAdmin ?? false;

    if (_isEditing) {
      // Editando: la caja ya tiene su sucursal asignada, no se reasigna.
      _sucursalSeleccionadaId = widget.caja!.sucursalId;
      _sucursalNombreFijo = widget.caja!.sucursalNombre;
      setState(() {});
      return;
    }

    if (_esAdmin) {
      setState(() => _loadingSucursales = true);
      try {
        _sucursales = await SettingsService().getSucursales();
      } catch (_) {
        _sucursales = [];
      }
      _sucursalSeleccionadaId = _sucursales.isNotEmpty ? _sucursales.first.id : null;
      setState(() => _loadingSucursales = false);
    } else {
      _sucursalSeleccionadaId = user?.sucursalId;
      _sucursalNombreFijo = user?.sucursal;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  Future<void> _abrirSelectorSucursal() async {
    final colors = context.colors;
    final seleccionada = await VntlModal.show<int>(
      context,
      title: 'Selecciona Sucursal',
      width: 400,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: _sucursales
            .map((s) => ListTile(
                  title: Text(s.nombre, style: VntlText.body),
                  trailing: s.id == _sucursalSeleccionadaId
                      ? Icon(Icons.check_rounded, color: colors.primary)
                      : null,
                  onTap: () => Navigator.pop(context, s.id),
                ))
            .toList(),
      ),
    );
    if (seleccionada != null) {
      setState(() => _sucursalSeleccionadaId = seleccionada);
    }
  }

  Widget _buildSucursalSelector() {
    final colors = context.colors;
    final soloUnaSucursal = !_esAdmin || _isEditing || _sucursales.length <= 1;

    final nombreActual = !_esAdmin
        ? (_sucursalNombreFijo ?? '—')
        : (_isEditing
            ? (_sucursalNombreFijo ?? '—')
            : (_sucursales.isEmpty
                ? '—'
                : _sucursales
                    .firstWhere(
                      (s) => s.id == _sucursalSeleccionadaId,
                      orElse: () => _sucursales.first,
                    )
                    .nombre));

    return GestureDetector(
      onTap: soloUnaSucursal ? null : _abrirSelectorSucursal,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: VntlSpacing.md, vertical: VntlSpacing.sm + 2),
        decoration: BoxDecoration(
          color: colors.glassSurface,
          borderRadius: VntlRadius.mdBorderRadius,
          border: Border.all(color: colors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(Icons.storefront_rounded, size: 16, color: colors.textSecondary),
            const SizedBox(width: VntlSpacing.sm),
            Expanded(child: Text(nombreActual, style: VntlText.body)),
            if (!soloUnaSucursal)
              Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: colors.textTertiary),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_sucursalSeleccionadaId == null) {
      VntlToast.show(
        context,
        message: 'Selecciona una sucursal',
        type: VntlToastType.error,
      );
      return;
    }

    final ctrl = context.read<CajaController>();
    final data = {
      'nombre': _nombreCtrl.text.trim(),
      'sucursal_id': _sucursalSeleccionadaId,
    };

    final ok =
        _isEditing ? await ctrl.editCaja(widget.caja!.id, data) : await ctrl.createCaja(data);

    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      VntlToast.show(
        context,
        message: _isEditing ? 'Caja actualizada' : 'Caja creada',
        type: VntlToastType.success,
      );
    } else {
      VntlToast.show(
        context,
        message: ctrl.errorMessage ?? 'Error al guardar',
        type: VntlToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ctrl = context.watch<CajaController>();

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Datos de la Caja', style: VntlText.label.copyWith(color: colors.textTertiary)),
          const SizedBox(height: VntlSpacing.md),
          VntlInput(
            label: 'Nombre de la Caja',
            hint: 'Caja 1',
            controller: _nombreCtrl,
            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
          ),
          const SizedBox(height: VntlSpacing.lg),
          Text('Sucursal', style: VntlText.label.copyWith(color: colors.textTertiary)),
          const SizedBox(height: VntlSpacing.sm),
          _loadingSucursales
              ? const SizedBox(
                  height: 44,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : _buildSucursalSelector(),
          const SizedBox(height: VntlSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              VntlButton(
                label: 'Cancelar',
                variant: VntlButtonVariant.ghost,
                onPressed: ctrl.isSaving ? null : () => Navigator.pop(context),
              ),
              const SizedBox(width: VntlSpacing.sm),
              VntlButton(
                label: ctrl.isSaving
                    ? 'Guardando...'
                    : (_isEditing ? 'Guardar cambios' : 'Crear Caja'),
                loading: ctrl.isSaving,
                onPressed: ctrl.isSaving ? null : _submit,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
