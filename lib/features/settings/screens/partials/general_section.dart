import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/core/utils/image_picker_service.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/settings/controllers/settings_controller.dart';

class GeneralSection extends StatefulWidget {
  final bool sidebarCollapsed;

  const GeneralSection({super.key, required this.sidebarCollapsed});

  @override
  State<GeneralSection> createState() => _GeneralSectionState();
}

class _GeneralSectionState extends State<GeneralSection> {
  final _formKey = GlobalKey<FormState>();

  // Tenant
  final _nameCtrl = TextEditingController();
  final _razonSocialCtrl = TextEditingController();

  // Sucursal
  final _emailCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _telefonoAltCtrl = TextEditingController();
  final _sitioWebCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _direccion2Ctrl = TextEditingController();
  final _ciudadCtrl = TextEditingController();
  final _estadoCtrl = TextEditingController();
  final _cpCtrl = TextEditingController();
  final _paisCtrl = TextEditingController();

  // Logo pendiente
  Uint8List? _pendingLogoBytes;
  String? _pendingLogoFileName;

  bool _loaded = false;
  bool _isDirty = false;

  bool get _isNarrow {
    final screenWidth = MediaQuery.of(context).size.width;
    final sidebarWidth = widget.sidebarCollapsed ? 64.0 : 220.0;
    return (screenWidth - sidebarWidth) < 600;
  }

  List<TextEditingController> get _allControllers => [
        _nameCtrl,
        _razonSocialCtrl,
        _emailCtrl,
        _telefonoCtrl,
        _telefonoAltCtrl,
        _sitioWebCtrl,
        _direccionCtrl,
        _direccion2Ctrl,
        _ciudadCtrl,
        _estadoCtrl,
        _cpCtrl,
        _paisCtrl,
      ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      context.read<SettingsController>().loadGeneral().then((_) => _fillForm());
    }
  }

  void _fillForm() {
    if (!mounted) return;
    final ctrl = context.read<SettingsController>();
    final tenant = ctrl.tenant;
    final s = ctrl.sucursalMain;
    if (tenant == null || s == null) return;

    _nameCtrl.text = tenant.name;
    _razonSocialCtrl.text = tenant.razonSocial ?? '';
    _emailCtrl.text = s.email ?? '';
    _telefonoCtrl.text = s.telefono ?? '';
    _telefonoAltCtrl.text = s.telefonoAlternativo ?? '';
    _sitioWebCtrl.text = s.sitioWeb ?? '';
    _direccionCtrl.text = s.direccion ?? '';
    _direccion2Ctrl.text = s.direccion2 ?? '';
    _ciudadCtrl.text = s.ciudad ?? '';
    _estadoCtrl.text = s.estado ?? '';
    _cpCtrl.text = s.codigoPostal ?? '';
    _paisCtrl.text = s.pais ?? 'México';
  }

  void _onChanged(String _) {
    if (!_isDirty) setState(() => _isDirty = true);
  }

  @override
  void dispose() {
    for (final c in _allControllers) c.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await ImagePickerService.pickImage();
    if (result == null) return;
    final (bytes, fileName) = result;
    setState(() {
      _pendingLogoBytes = bytes;
      _pendingLogoFileName = fileName;
      _isDirty = true;
    });
  }

  Future<void> _save() async {
    final colors = context.colors;
    if (!_formKey.currentState!.validate()) return;

    final ctrl = context.read<SettingsController>();

    if (_pendingLogoBytes != null && _pendingLogoFileName != null) {
      final logoOk = await ctrl.uploadLogo(_pendingLogoBytes!, _pendingLogoFileName!);
      if (!logoOk) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(ctrl.errorMessage ?? 'Error al subir logo'),
            backgroundColor: colors.error,
          ));
        }
        return;
      }
      setState(() {
        _pendingLogoBytes = null;
        _pendingLogoFileName = null;
      });
    }

    final success = await ctrl.saveGeneral(
      name: _nameCtrl.text.trim(),
      razonSocial: _razonSocialCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      telefono: _telefonoCtrl.text.trim(),
      telefonoAlternativo: _telefonoAltCtrl.text.trim(),
      sitioWeb: _sitioWebCtrl.text.trim(),
      direccion: _direccionCtrl.text.trim(),
      direccion2: _direccion2Ctrl.text.trim(),
      ciudad: _ciudadCtrl.text.trim(),
      estado: _estadoCtrl.text.trim(),
      codigoPostal: _cpCtrl.text.trim(),
      pais: _paisCtrl.text.trim(),
    );

    if (!mounted) return;
    if (success) setState(() => _isDirty = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        success ? 'Cambios guardados correctamente' : ctrl.errorMessage ?? 'Error al guardar',
      ),
      backgroundColor: success ? colors.success : colors.error,
    ));
  }

  Widget _row(Widget left, Widget right) {
    if (_isNarrow) {
      return Column(children: [
        left,
        const SizedBox(height: VntlSpacing.lg),
        right,
      ]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: VntlSpacing.lg),
        Expanded(child: right),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<SettingsController>();
    final colors = context.colors;

    if (ctrl.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // ─── Formulario ───────────────────────────────────────────────────
        Expanded(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(VntlSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Logo ──────────────────────────────────────────
                  _SettingsSectionCard(
                    title: 'Logo de la Tienda',
                    child: GestureDetector(
                      onTap: ctrl.isSaving ? null : _pickImage,
                      child: Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: colors.glassSurface,
                          borderRadius: VntlRadius.lgBorderRadius,
                          border: Border.all(
                            color: colors.primary.withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: _pendingLogoBytes != null
                            ? ClipRRect(
                                borderRadius: VntlRadius.lgBorderRadius,
                                child: Image.memory(_pendingLogoBytes!, fit: BoxFit.contain),
                              )
                            : ctrl.tenant?.logo != null
                                ? ClipRRect(
                                    borderRadius: VntlRadius.lgBorderRadius,
                                    child: Image.network(
                                      ctrl.tenant!.logo!,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.broken_image_rounded,
                                              size: 36, color: colors.textTertiary),
                                          const SizedBox(height: VntlSpacing.sm),
                                          Text('No se pudo cargar el logo',
                                              style: VntlText.caption
                                                  .copyWith(color: colors.textTertiary)),
                                        ],
                                      ),
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.image_rounded, size: 36, color: colors.primary),
                                      const SizedBox(height: VntlSpacing.sm),
                                      Text('Agrega tu logo',
                                          style: VntlText.label.copyWith(color: colors.primary)),
                                      const SizedBox(height: VntlSpacing.xs),
                                      Text('JPG, PNG — Máx. 2MB',
                                          style: VntlText.caption
                                              .copyWith(color: colors.textTertiary)),
                                    ],
                                  ),
                      ),
                    ),
                  ),

                  const SizedBox(height: VntlSpacing.xl),

                  // ─── Datos de Contacto ────────────────────────────
                  _SettingsSectionCard(
                    title: 'Datos de Contacto',
                    child: Column(
                      children: [
                        VntlInput(
                          label: 'Nombre de la Tienda',
                          hint: 'Mi Tienda',
                          controller: _nameCtrl,
                          onChanged: _onChanged,
                          validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                        ),
                        const SizedBox(height: VntlSpacing.lg),
                        VntlInput(
                          label: 'Razón Social (Opcional)',
                          hint: 'Razón Social S.A. de C.V.',
                          controller: _razonSocialCtrl,
                          onChanged: _onChanged,
                        ),
                        const SizedBox(height: VntlSpacing.lg),
                        _row(
                          VntlInput(
                            label: 'Email de la Tienda',
                            hint: 'contacto@mitienda.com',
                            controller: _emailCtrl,
                            onChanged: _onChanged,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                          ),
                          VntlInput(
                            label: 'Teléfono',
                            hint: '551 234 5678',
                            controller: _telefonoCtrl,
                            onChanged: _onChanged,
                            keyboardType: TextInputType.phone,
                            prefixIcon: Icons.phone_rounded,
                            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                          ),
                        ),
                        const SizedBox(height: VntlSpacing.lg),
                        _row(
                          VntlInput(
                            label: 'Teléfono Alternativo (Opcional)',
                            hint: '551 234 5678',
                            controller: _telefonoAltCtrl,
                            onChanged: _onChanged,
                            keyboardType: TextInputType.phone,
                            prefixIcon: Icons.phone_rounded,
                          ),
                          VntlInput(
                            label: 'Sitio Web (Opcional)',
                            hint: 'https://www.mitienda.com',
                            controller: _sitioWebCtrl,
                            onChanged: _onChanged,
                            keyboardType: TextInputType.url,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: VntlSpacing.xl),

                  // ─── Dirección ────────────────────────────────────
                  _SettingsSectionCard(
                    title: 'Dirección de la Tienda',
                    child: Column(
                      children: [
                        VntlInput(
                          label: 'Dirección (Línea 1)',
                          hint: 'Calle Principal #123',
                          controller: _direccionCtrl,
                          onChanged: _onChanged,
                          validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                        ),
                        const SizedBox(height: VntlSpacing.lg),
                        VntlInput(
                          label: 'Dirección (Línea 2) (Opcional)',
                          hint: 'Colonia, Referencias',
                          controller: _direccion2Ctrl,
                          onChanged: _onChanged,
                        ),
                        const SizedBox(height: VntlSpacing.lg),
                        _row(
                          VntlInput(
                            label: 'Ciudad',
                            hint: 'Mérida',
                            controller: _ciudadCtrl,
                            onChanged: _onChanged,
                            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                          ),
                          VntlInput(
                            label: 'Estado',
                            hint: 'Yucatán',
                            controller: _estadoCtrl,
                            onChanged: _onChanged,
                            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                          ),
                        ),
                        const SizedBox(height: VntlSpacing.lg),
                        _row(
                          VntlInput(
                            label: 'Código Postal',
                            hint: '97000',
                            controller: _cpCtrl,
                            onChanged: _onChanged,
                            keyboardType: TextInputType.number,
                            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                          ),
                          VntlInput(
                            label: 'País',
                            hint: 'México',
                            controller: _paisCtrl,
                            onChanged: _onChanged,
                            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: VntlSpacing.xl),
                ],
              ),
            ),
          ),
        ),

        // ─── Botón flotante guardar ────────────────────────────────────────
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: _isDirty
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: VntlSpacing.xl,
                    vertical: VntlSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    border: Border(
                      top: BorderSide(color: colors.border, width: 0.5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.edit_rounded, size: 16, color: colors.textSecondary),
                      const SizedBox(width: VntlSpacing.sm),
                      Text(
                        'Tienes cambios sin guardar',
                        style: VntlText.label.copyWith(color: colors.textSecondary),
                      ),
                      const Spacer(),
                      VntlButton(
                        label: ctrl.isSaving ? 'Guardando...' : 'Guardar cambios',
                        onPressed: ctrl.isSaving ? null : _save,
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ─── Section Card ─────────────────────────────────────────────────────────────
class _SettingsSectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SettingsSectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(VntlSpacing.xl),
      decoration: BoxDecoration(
        color: colors.glassSurface,
        borderRadius: VntlRadius.lgBorderRadius,
        border: Border.all(color: colors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: VntlText.h4),
          const SizedBox(height: VntlSpacing.xl),
          child,
        ],
      ),
    );
  }
}
