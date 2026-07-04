import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/ventas/services/venta_service.dart';
import 'package:web/web.dart' as web;

class VentaConfirmadaSheet extends StatefulWidget {
  final int ventaId;
  final String numeroTicket;
  final double total;

  const VentaConfirmadaSheet({
    super.key,
    required this.ventaId,
    required this.numeroTicket,
    required this.total,
  });

  @override
  State<VentaConfirmadaSheet> createState() => _VentaConfirmadaSheetState();
}

class _VentaConfirmadaSheetState extends State<VentaConfirmadaSheet> {
  final VentaService _service = VentaService();
  bool _enviandoEmail = false;
  bool _generandoPdf = false;
  bool _mostrarFormEmail = false;
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _abrirTicket() async {
    setState(() => _generandoPdf = true);
    try {
      final bytes = await _service.descargarTicketPdf(widget.ventaId);
      if (!mounted) return;

      if (kIsWeb) {
        // Web: abre el PDF en una nueva pestaña para previsualizar e imprimir desde ahí.
        final blobParts = [Uint8List.fromList(bytes).toJS].toJS;
        final blob = web.Blob(blobParts, web.BlobPropertyBag(type: 'application/pdf'));
        final url = web.URL.createObjectURL(blob);
        web.window.open(url, '_blank');
      } else {
        // Desktop / móvil: usa el plugin printing con soporte nativo real.
        await Printing.layoutPdf(
          onLayout: (_) async => Uint8List.fromList(bytes),
          name: 'ticket-${widget.numeroTicket}.pdf',
        );
      }
    } catch (e) {
      if (mounted) {
        VntlToast.show(context, message: 'No se pudo abrir el ticket', type: VntlToastType.error);
      }
    } finally {
      if (mounted) setState(() => _generandoPdf = false);
    }
  }

  Future<void> _enviarEmail() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      VntlToast.show(context, message: 'Ingresa un correo válido', type: VntlToastType.error);
      return;
    }

    setState(() => _enviandoEmail = true);
    try {
      await _service.enviarTicketPorEmail(widget.ventaId, email);
      if (!mounted) return;
      VntlToast.show(context, message: 'Ticket enviado a $email', type: VntlToastType.success);
      setState(() => _mostrarFormEmail = false);
    } catch (_) {
      if (!mounted) return;
      VntlToast.show(context, message: 'No se pudo enviar el ticket', type: VntlToastType.error);
    } finally {
      if (mounted) setState(() => _enviandoEmail = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: colors.success.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_rounded, color: colors.success, size: 36),
        ),
        const SizedBox(height: VntlSpacing.lg),
        Text('Venta completada', style: VntlText.h3),
        const SizedBox(height: VntlSpacing.xs),
        Text(
          'Ticket #${widget.numeroTicket}',
          style: VntlText.body.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: VntlSpacing.xs),
        Text(
          '\$${widget.total.toStringAsFixed(2)}',
          style: VntlText.h2.copyWith(color: colors.primary),
        ),
        const SizedBox(height: VntlSpacing.xl),
        if (!_mostrarFormEmail) ...[
          SizedBox(
            width: double.infinity,
            child: VntlButton(
              label: 'Imprimir ticket',
              icon: Icons.print_rounded,
              loading: _generandoPdf,
              onPressed: _generandoPdf ? null : _abrirTicket,
            ),
          ),
          const SizedBox(height: VntlSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: VntlButton(
              label: 'Enviar por email',
              icon: Icons.email_rounded,
              variant: VntlButtonVariant.secondary,
              onPressed: () => setState(() => _mostrarFormEmail = true),
            ),
          ),
        ] else ...[
          VntlInput(
            label: 'Correo del cliente',
            hint: 'cliente@correo.com',
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
          ),
          const SizedBox(height: VntlSpacing.md),
          Row(
            children: [
              Expanded(
                child: VntlButton(
                  label: 'Cancelar',
                  variant: VntlButtonVariant.ghost,
                  onPressed:
                      _enviandoEmail ? null : () => setState(() => _mostrarFormEmail = false),
                ),
              ),
              const SizedBox(width: VntlSpacing.sm),
              Expanded(
                child: VntlButton(
                  label: _enviandoEmail ? 'Enviando...' : 'Enviar',
                  loading: _enviandoEmail,
                  onPressed: _enviandoEmail ? null : _enviarEmail,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: VntlSpacing.md),
        VntlButton(
          label: 'Nueva venta',
          variant: VntlButtonVariant.ghost,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
