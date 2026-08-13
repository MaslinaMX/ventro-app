import 'package:flutter/material.dart';
import 'package:ventro_app/core/utils/phone_formatter.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/clientes/controllers/clientes_controller.dart';
import 'package:ventro_app/features/clientes/models/cliente_model.dart';

/// Pantalla completa para crear/editar un cliente. Pantalla completa en
/// vez de modal — más mobile-friendly, misma decisión que el resto de
/// formularios largos en la app.
class ClienteFormScreen extends StatefulWidget {
  final ClienteModel? cliente;

  const ClienteFormScreen({super.key, this.cliente});

  @override
  State<ClienteFormScreen> createState() => _ClienteFormScreenState();
}

class _ClienteFormScreenState extends State<ClienteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = ClientesController();

  late TipoCliente _tipo;
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _telefonoCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _direccionCtrl;
  late final TextEditingController _ciudadCtrl;
  late final TextEditingController _estadoCtrl;
  late final TextEditingController _cpCtrl;
  late final TextEditingController _rfcCtrl;
  late final TextEditingController _razonSocialCtrl;
  late final TextEditingController _regimenFiscalCtrl;
  late final TextEditingController _usoCfdiCtrl;
  late final TextEditingController _notasCtrl;
  late bool _activo;

  bool _guardando = false;

  bool get _esNuevo => widget.cliente == null;

  @override
  void initState() {
    super.initState();
    final c = widget.cliente;
    _tipo = c?.tipo ?? TipoCliente.personaFisica;
    _nombreCtrl = TextEditingController(text: c?.nombre ?? '');
    _telefonoCtrl = TextEditingController(text: c?.telefono ?? '');
    _emailCtrl = TextEditingController(text: c?.email ?? '');
    _direccionCtrl = TextEditingController(text: c?.direccion ?? '');
    _ciudadCtrl = TextEditingController(text: c?.ciudad ?? '');
    _estadoCtrl = TextEditingController(text: c?.estado ?? '');
    _cpCtrl = TextEditingController(text: c?.codigoPostal ?? '');
    _rfcCtrl = TextEditingController(text: c?.rfc ?? '');
    _razonSocialCtrl = TextEditingController(text: c?.razonSocial ?? '');
    _regimenFiscalCtrl = TextEditingController(text: c?.regimenFiscal ?? '');
    _usoCfdiCtrl = TextEditingController(text: c?.usoCfdi ?? '');
    _notasCtrl = TextEditingController(text: c?.notas ?? '');
    _activo = c?.activo ?? true;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    _emailCtrl.dispose();
    _direccionCtrl.dispose();
    _ciudadCtrl.dispose();
    _estadoCtrl.dispose();
    _cpCtrl.dispose();
    _rfcCtrl.dispose();
    _razonSocialCtrl.dispose();
    _regimenFiscalCtrl.dispose();
    _usoCfdiCtrl.dispose();
    _notasCtrl.dispose();
    _controller.dispose();
    super.dispose();
  }

  String? _vacioComoNull(String texto) => texto.trim().isEmpty ? null : texto.trim();

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    final cliente = ClienteModel(
      id: widget.cliente?.id ?? 0,
      nombre: _nombreCtrl.text.trim(),
      tipo: _tipo,
      telefono: _vacioComoNull(_telefonoCtrl.text)?.soloDigitosTelefono,
      email: _vacioComoNull(_emailCtrl.text),
      direccion: _vacioComoNull(_direccionCtrl.text),
      ciudad: _vacioComoNull(_ciudadCtrl.text),
      estado: _vacioComoNull(_estadoCtrl.text),
      codigoPostal: _vacioComoNull(_cpCtrl.text),
      rfc: _vacioComoNull(_rfcCtrl.text)?.toUpperCase(),
      razonSocial: _vacioComoNull(_razonSocialCtrl.text),
      regimenFiscal: _vacioComoNull(_regimenFiscalCtrl.text),
      usoCfdi: _vacioComoNull(_usoCfdiCtrl.text),
      notas: _vacioComoNull(_notasCtrl.text),
      activo: _activo,
    );

    final ok = await _controller.guardarCliente(cliente);

    if (!mounted) return;
    setState(() => _guardando = false);

    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_controller.errorMessage ?? 'No se pudo guardar el cliente.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: context.backgroundGradient),
        child: Column(
          children: [
            VntlAppBar(
              title: _esNuevo ? 'Nuevo cliente' : 'Editar cliente',
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.arrow_back_rounded, color: colors.textSecondary, size: 20),
              ),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: ListView(
                      padding: const EdgeInsets.all(VntlSpacing.lg),
                      children: [
                        _SeccionTitulo('Datos generales'),
                        const SizedBox(height: VntlSpacing.md),
                        VntlInput(
                          hint: 'Nombre completo o comercial',
                          controller: _nombreCtrl,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'El nombre es obligatorio' : null,
                        ),
                        const SizedBox(height: VntlSpacing.md),
                        _TipoClienteSelector(
                          valor: _tipo,
                          onChanged: (t) => setState(() => _tipo = t),
                        ),
                        const SizedBox(height: VntlSpacing.xl),
                        _SeccionTitulo('Contacto'),
                        const SizedBox(height: VntlSpacing.md),
                        VntlInput(
                          hint: 'Teléfono',
                          controller: _telefonoCtrl,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [PhoneInputFormatter()],
                        ),
                        const SizedBox(height: VntlSpacing.md),
                        VntlInput(
                          hint: 'Correo electrónico',
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return null;
                            final valido = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
                            return valido ? null : 'Correo no válido';
                          },
                        ),
                        const SizedBox(height: VntlSpacing.xl),
                        _SeccionTitulo('Dirección'),
                        const SizedBox(height: VntlSpacing.md),
                        VntlInput(hint: 'Dirección', controller: _direccionCtrl),
                        const SizedBox(height: VntlSpacing.md),
                        Row(
                          children: [
                            Expanded(child: VntlInput(hint: 'Ciudad', controller: _ciudadCtrl)),
                            const SizedBox(width: VntlSpacing.md),
                            Expanded(child: VntlInput(hint: 'Estado', controller: _estadoCtrl)),
                          ],
                        ),
                        const SizedBox(height: VntlSpacing.md),
                        VntlInput(
                          hint: 'Código postal',
                          controller: _cpCtrl,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: VntlSpacing.xl),
                        _SeccionTitulo('Facturación'),
                        const SizedBox(height: VntlSpacing.md),
                        VntlInput(
                          hint: 'RFC',
                          controller: _rfcCtrl,
                        ),
                        const SizedBox(height: VntlSpacing.md),
                        VntlInput(hint: 'Razón social', controller: _razonSocialCtrl),
                        const SizedBox(height: VntlSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: VntlInput(
                                hint: 'Régimen fiscal (clave SAT)',
                                controller: _regimenFiscalCtrl,
                              ),
                            ),
                            const SizedBox(width: VntlSpacing.md),
                            Expanded(
                              child:
                                  VntlInput(hint: 'Uso CFDI (clave SAT)', controller: _usoCfdiCtrl),
                            ),
                          ],
                        ),
                        const SizedBox(height: VntlSpacing.xl),
                        _SeccionTitulo('Notas'),
                        const SizedBox(height: VntlSpacing.md),
                        VntlInput(
                          hint: 'Notas adicionales (opcional)',
                          controller: _notasCtrl,
                          maxLines: 3,
                        ),
                        const SizedBox(height: VntlSpacing.xl),
                        if (!_esNuevo)
                          SwitchListTile(
                            activeThumbColor: colors.primary,
                            contentPadding: EdgeInsets.zero,
                            title: Text('Cliente activo',
                                style: VntlText.body.copyWith(color: colors.textPrimary)),
                            subtitle: Text(
                              'Desactiva en vez de eliminar si ya tiene ventas asociadas',
                              style: VntlText.caption.copyWith(color: colors.textTertiary),
                            ),
                            value: _activo,
                            onChanged: (v) => setState(() => _activo = v),
                          ),
                        const SizedBox(height: VntlSpacing.xl2),
                        VntlButton(
                          label: _esNuevo ? 'Crear cliente' : 'Guardar cambios',
                          onPressed: _guardando ? null : _guardar,
                          loading: _guardando,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeccionTitulo extends StatelessWidget {
  final String texto;
  const _SeccionTitulo(this.texto);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Text(
      texto,
      style: VntlText.h4.copyWith(color: colors.textPrimary, fontWeight: FontWeight.bold),
    );
  }
}

class _TipoClienteSelector extends StatelessWidget {
  final TipoCliente valor;
  final ValueChanged<TipoCliente> onChanged;

  const _TipoClienteSelector({required this.valor, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: VntlRadius.mdBorderRadius,
        border: Border.all(color: colors.border, width: 0.5),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: TipoCliente.values.map((tipo) {
          final seleccionado = tipo == valor;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(tipo),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: VntlSpacing.sm),
                decoration: BoxDecoration(
                  color: seleccionado ? colors.primarySurface : Colors.transparent,
                  borderRadius: VntlRadius.smBorderRadius,
                ),
                alignment: Alignment.center,
                child: Text(
                  tipo.label,
                  style: VntlText.body.copyWith(
                    color: seleccionado ? colors.primary : colors.textSecondary,
                    fontWeight: seleccionado ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
