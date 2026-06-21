import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/settings/controllers/settings_controller.dart';
import 'package:ventro_app/features/settings/models/sucursal_model.dart';

class SucursalFormSheet extends StatefulWidget {
  final SucursalModel? sucursal;
  const SucursalFormSheet({super.key, this.sucursal});

  @override
  State<SucursalFormSheet> createState() => _SucursalFormSheetState();
}

class _SucursalFormSheetState extends State<SucursalFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _telefonoCtrl;
  late final TextEditingController _telefonoAltCtrl;
  late final TextEditingController _sitioWebCtrl;
  late final TextEditingController _rfcCtrl;
  late final TextEditingController _direccionCtrl;
  late final TextEditingController _direccion2Ctrl;
  late final TextEditingController _ciudadCtrl;
  late final TextEditingController _estadoCtrl;
  late final TextEditingController _cpCtrl;
  late final TextEditingController _paisCtrl;

  bool get _isEditing => widget.sucursal != null;

  List<TextEditingController> get _allControllers => [
        _nombreCtrl,
        _emailCtrl,
        _telefonoCtrl,
        _telefonoAltCtrl,
        _sitioWebCtrl,
        _rfcCtrl,
        _direccionCtrl,
        _direccion2Ctrl,
        _ciudadCtrl,
        _estadoCtrl,
        _cpCtrl,
        _paisCtrl,
      ];

  @override
  void initState() {
    super.initState();
    final s = widget.sucursal;
    _nombreCtrl = TextEditingController(text: s?.nombre ?? '');
    _emailCtrl = TextEditingController(text: s?.email ?? '');
    _telefonoCtrl = TextEditingController(text: s?.telefono ?? '');
    _telefonoAltCtrl = TextEditingController(text: s?.telefonoAlternativo ?? '');
    _sitioWebCtrl = TextEditingController(text: s?.sitioWeb ?? '');
    _rfcCtrl = TextEditingController(text: s?.rfc ?? '');
    _direccionCtrl = TextEditingController(text: s?.direccion ?? '');
    _direccion2Ctrl = TextEditingController(text: s?.direccion2 ?? '');
    _ciudadCtrl = TextEditingController(text: s?.ciudad ?? '');
    _estadoCtrl = TextEditingController(text: s?.estado ?? '');
    _cpCtrl = TextEditingController(text: s?.codigoPostal ?? '');
    _paisCtrl = TextEditingController(text: s?.pais ?? 'México');
  }

  @override
  void dispose() {
    for (final c in _allControllers) c.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final colors = context.colors;

    if (!_formKey.currentState!.validate()) return;
    final ctrl = context.read<SettingsController>();
    final data = {
      'nombre': _nombreCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'telefono': _telefonoCtrl.text.trim(),
      'telefono_alternativo': _telefonoAltCtrl.text.trim(),
      'sitio_web': _sitioWebCtrl.text.trim(),
      'rfc': _rfcCtrl.text.trim(),
      'direccion': _direccionCtrl.text.trim(),
      'direccion_2': _direccion2Ctrl.text.trim(),
      'ciudad': _ciudadCtrl.text.trim(),
      'estado': _estadoCtrl.text.trim(),
      'codigo_postal': _cpCtrl.text.trim(),
      'pais': _paisCtrl.text.trim(),
    };
    final ok = _isEditing
        ? await ctrl.editSucursal(widget.sucursal!.id, data)
        : await ctrl.createSucursal(data);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEditing ? 'Sucursal actualizada' : 'Sucursal creada'),
        backgroundColor: colors.success,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ctrl.errorMessage ?? 'Error al guardar'),
        backgroundColor: colors.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ctrl = context.watch<SettingsController>();
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Datos generales ──────────────────────────────────────
          Text('Datos Generales', style: VntlText.label.copyWith(color: colors.textTertiary)),
          const SizedBox(height: VntlSpacing.md),
          VntlInput(
            label: 'Nombre de la Sucursal',
            hint: 'Sucursal Centro',
            controller: _nombreCtrl,
            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
          ),
          const SizedBox(height: VntlSpacing.lg),
          VntlInput(
            label: 'RFC (Opcional)',
            hint: 'ABC123456DEF',
            controller: _rfcCtrl,
          ),
          const SizedBox(height: VntlSpacing.xl),

          // ─── Contacto ─────────────────────────────────────────────
          Text('Contacto', style: VntlText.label.copyWith(color: colors.textTertiary)),
          const SizedBox(height: VntlSpacing.md),
          VntlInput(
            label: 'Email',
            hint: 'sucursal@mitienda.com',
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
          ),
          const SizedBox(height: VntlSpacing.lg),
          VntlInput(
            label: 'Teléfono',
            hint: '551 234 5678',
            controller: _telefonoCtrl,
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_rounded,
            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
          ),
          const SizedBox(height: VntlSpacing.lg),
          VntlInput(
            label: 'Teléfono Alternativo (Opcional)',
            hint: '551 234 5678',
            controller: _telefonoAltCtrl,
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_rounded,
          ),
          const SizedBox(height: VntlSpacing.lg),
          VntlInput(
            label: 'Sitio Web (Opcional)',
            hint: 'https://www.mitienda.com',
            controller: _sitioWebCtrl,
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: VntlSpacing.xl),

          // ─── Dirección ────────────────────────────────────────────
          Text('Dirección', style: VntlText.label.copyWith(color: colors.textTertiary)),
          const SizedBox(height: VntlSpacing.md),
          VntlInput(
            label: 'Dirección (Línea 1)',
            hint: 'Calle Principal #123',
            controller: _direccionCtrl,
            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
          ),
          const SizedBox(height: VntlSpacing.lg),
          VntlInput(
            label: 'Dirección (Línea 2) (Opcional)',
            hint: 'Colonia, Referencias',
            controller: _direccion2Ctrl,
          ),
          const SizedBox(height: VntlSpacing.lg),
          VntlInput(
            label: 'Ciudad',
            hint: 'Mérida',
            controller: _ciudadCtrl,
            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
          ),
          const SizedBox(height: VntlSpacing.lg),
          VntlInput(
            label: 'Estado',
            hint: 'Yucatán',
            controller: _estadoCtrl,
            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
          ),
          const SizedBox(height: VntlSpacing.lg),
          VntlInput(
            label: 'Código Postal',
            hint: '97000',
            controller: _cpCtrl,
            keyboardType: TextInputType.number,
            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
          ),
          const SizedBox(height: VntlSpacing.lg),
          VntlInput(
            label: 'País',
            hint: 'México',
            controller: _paisCtrl,
            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
          ),
          const SizedBox(height: VntlSpacing.xl),

          // ─── Acción ───────────────────────────────────────────────
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
                    : (_isEditing ? 'Guardar cambios' : 'Crear Sucursal'),
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
