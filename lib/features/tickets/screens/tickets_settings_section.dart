import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/settings/controllers/settings_controller.dart';
import 'package:ventro_app/features/tickets/controllers/configuracion_ticket_controller.dart';

class TicketsSettingsSection extends StatefulWidget {
  const TicketsSettingsSection({super.key});

  @override
  State<TicketsSettingsSection> createState() => _TicketsSettingsSectionState();
}

class _TicketsSettingsSectionState extends State<TicketsSettingsSection> {
  bool _loaded = false;
  late TextEditingController _mensajeCtrl;
  bool _mostrarLogo = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _mensajeCtrl = TextEditingController();
      _init();
    }
  }

  Future<void> _init() async {
    final ctrl = context.read<ConfiguracionTicketController>();
    await ctrl.cargar();
    if (!mounted) return;
    final config = ctrl.configuracion;
    if (config != null) {
      setState(() {
        _mostrarLogo = config.mostrarLogo;
        _mensajeCtrl.text = config.mensajePersonalizado ?? '';
      });
    }
    context.read<SettingsController>().loadGeneral();
  }

  @override
  void dispose() {
    _mensajeCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final ctrl = context.read<ConfiguracionTicketController>();
    final ok = await ctrl.guardar(
      mostrarLogo: _mostrarLogo,
      mensajePersonalizado: _mensajeCtrl.text.trim().isEmpty ? null : _mensajeCtrl.text.trim(),
    );
    if (!mounted) return;
    VntlToast.show(
      context,
      message: ok ? 'Configuración guardada' : (ctrl.errorMessage ?? 'Error al guardar'),
      type: ok ? VntlToastType.success : VntlToastType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ctrl = context.watch<ConfiguracionTicketController>();
    final settingsCtrl = context.watch<SettingsController>();

    if (ctrl.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Align(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(VntlSpacing.xl),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final twoColumns = constraints.maxWidth >= 720;
            final form = _buildForm(colors, ctrl);
            final preview = _buildPreview(colors, settingsCtrl);

            if (!twoColumns) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [form, const SizedBox(height: VntlSpacing.xl), preview],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: form),
                const SizedBox(width: VntlSpacing.xl),
                SizedBox(width: 320, child: preview),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildForm(dynamic colors, ConfiguracionTicketController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tickets', style: VntlText.h3),
        const SizedBox(height: VntlSpacing.xs),
        Text(
          'Personaliza cómo se ven los tickets de venta.',
          style: VntlText.body.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: VntlSpacing.xl),
        VntlSwitch(
          value: _mostrarLogo,
          label: 'Mostrar logo en el ticket',
          tooltip: 'Si tu negocio tiene un logo configurado en Settings → General, '
              'aparecerá en la parte superior del ticket.',
          onChanged: (v) => setState(() => _mostrarLogo = v),
        ),
        const SizedBox(height: VntlSpacing.xl),
        VntlInput(
          label: 'Mensaje personalizado (opcional)',
          hint: 'Gracias por tu compra :)',
          controller: _mensajeCtrl,
          maxLines: 2,
          maxLength: 255,
        ),
        const SizedBox(height: VntlSpacing.xl),
        VntlButton(
          label: ctrl.isSaving ? 'Guardando...' : 'Guardar cambios',
          loading: ctrl.isSaving,
          onPressed: ctrl.isSaving ? null : _guardar,
        ),
      ],
    );
  }

  Widget _buildPreview(dynamic colors, SettingsController settingsCtrl) {
    final tenant = settingsCtrl.tenant;
    final sucursal = settingsCtrl.sucursalMain;
    const numeroTicketEjemplo = '1332220001';

    return Container(
      padding: const EdgeInsets.all(VntlSpacing.lg),
      decoration: BoxDecoration(
        color: colors.glassSurface,
        borderRadius: VntlRadius.lgBorderRadius,
        border: Border.all(color: colors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Vista previa', style: VntlText.label.copyWith(color: colors.textTertiary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: VntlSpacing.sm, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.surfaceSecondary,
                  borderRadius: VntlRadius.smBorderRadius,
                ),
                child: Text(
                  'Thermal 80mm',
                  style: VntlText.caption.copyWith(color: colors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: VntlSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(VntlSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: VntlRadius.smBorderRadius,
              border: Border.all(color: Colors.black12),
            ),
            child: DefaultTextStyle(
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: Colors.black,
                height: 1.4,
              ),
              child: Column(
                children: [
                  if (_mostrarLogo) ...[
                    if (tenant?.logo != null)
                      Image.network(tenant!.logo!, height: 40)
                    else
                      const Icon(Icons.storefront_rounded, size: 32, color: Colors.black54),
                    const SizedBox(height: VntlSpacing.sm),
                  ],

                  // ─── Datos fiscales del negocio ────────────────────────────
                  Text(
                    (tenant?.razonSocial?.isNotEmpty == true
                            ? tenant!.razonSocial!
                            : tenant?.name ?? 'Mi Negocio')
                        .toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (sucursal?.direccion != null)
                    Text(sucursal!.direccion!.toUpperCase(), textAlign: TextAlign.center),
                  if (sucursal?.ciudad != null ||
                      sucursal?.estado != null ||
                      sucursal?.codigoPostal != null)
                    Text(
                      [
                        sucursal?.ciudad,
                        if (sucursal?.estado != null) sucursal!.estado,
                        if (sucursal?.codigoPostal != null) sucursal!.codigoPostal,
                      ].whereType<String>().join(', ').toUpperCase(),
                      textAlign: TextAlign.center,
                    ),
                  if (sucursal?.rfc != null)
                    Text('RFC: ${sucursal!.rfc!.toUpperCase()}', textAlign: TextAlign.center),
                  if (sucursal?.telefono != null)
                    Text('TEL: ${sucursal!.telefono}', textAlign: TextAlign.center),

                  const SizedBox(height: VntlSpacing.sm),
                  const _DashedDivider(),
                  const SizedBox(height: VntlSpacing.sm),

                  // ─── Productos ──────────────────────────────────────────────
                  _filaTicket('1 x Producto A', '\$10.00', '\$100.00'),
                  _filaTicket('2 x Producto B', '\$50.00', '\$100.00'),

                  const SizedBox(height: VntlSpacing.sm),
                  const _DashedDivider(),
                  const SizedBox(height: VntlSpacing.sm),

                  // ─── Totales ────────────────────────────────────────────────
                  _filaTotal('SUBTOTAL', '\$134.00'),
                  _filaTotal('IVA 16%', '\$16.00'),
                  _filaTotal('TOTAL', '\$150.00'),
                  _filaTotal('EFECTIVO', '\$200.00'),
                  _filaTotal('CAMBIO', '\$50.00'),

                  const SizedBox(height: VntlSpacing.md),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Cajero: JOE DOE'),
                  ),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Caja: Nombre Caja'),
                  ),

                  const SizedBox(height: VntlSpacing.lg),
                  BarcodeWidget(
                    barcode: Barcode.code128(),
                    data: numeroTicketEjemplo,
                    width: 220,
                    height: 50,
                    drawText: false,
                  ),
                  const SizedBox(height: VntlSpacing.xs),
                  const Text(
                    numeroTicketEjemplo,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '25/06/2026 22:14:32',
                    style: TextStyle(color: Colors.black54, fontSize: 10),
                  ),

                  if (_mensajeCtrl.text.trim().isNotEmpty) ...[
                    const SizedBox(height: VntlSpacing.md),
                    Text(
                      _mensajeCtrl.text.trim(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filaTicket(String nombre, String precioUnitario, String importe) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(nombre)),
          Expanded(flex: 1, child: Text(precioUnitario, textAlign: TextAlign.right)),
          Expanded(flex: 1, child: Text(importe, textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _filaTotal(String label, String valor) {
    const style = TextStyle(
      fontFamily: 'monospace',
      fontSize: 11,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(valor, style: style),
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 1),
      painter: _DashedLinePainter(),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black26
      ..strokeWidth = 1;
    const dashWidth = 4.0, dashSpace = 3.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
