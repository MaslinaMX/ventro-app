import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/caja/controllers/caja_controller.dart';
import 'package:ventro_app/features/caja/controllers/sesion_caja_controller.dart';
import 'package:ventro_app/features/caja/models/caja_model.dart';
import 'package:ventro_app/features/caja/models/corte_caja_model.dart';
import 'package:ventro_app/features/caja/screens/corte_x_screen.dart';
import 'package:ventro_app/features/caja/widgets/abrir_caja_sheet.dart';
import 'package:ventro_app/features/caja/widgets/cerrar_caja_sheet.dart';
import 'package:ventro_app/features/ventas/controllers/venta_controller.dart';
import 'package:ventro_app/features/ventas/models/venta_dia_model.dart';

class CajaOperacionScreen extends StatefulWidget {
  const CajaOperacionScreen({super.key});

  @override
  State<CajaOperacionScreen> createState() => _CajaOperacionScreenState();
}

class _CajaOperacionScreenState extends State<CajaOperacionScreen> {
  bool _loaded = false;
  CajaModel? _cajaSeleccionada;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      context.read<CajaController>().loadCajas();
    }
  }

  Future<void> _seleccionarCaja(CajaModel caja) async {
    setState(() => _cajaSeleccionada = caja);
    await context.read<SesionCajaController>().cargarSesionActiva(caja.id);
    await context.read<VentaController>().cargarVentasDeLaSesion();
  }

  void _cambiarCaja() {
    context.read<SesionCajaController>().reset();
    setState(() => _cajaSeleccionada = null);
  }

  void _verCorteX() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const CorteXScreen()));
  }

  Future<void> _abrirCaja() async {
    if (_cajaSeleccionada == null) return;
    await VntlModal.show(
      context,
      title: 'Abrir ${_cajaSeleccionada!.nombre}',
      subtitle: 'Captura el efectivo inicial para comenzar el turno',
      width: 420,
      content: AbrirCajaSheet(caja: _cajaSeleccionada!),
    );
    if (!mounted) return;
    await context.read<CajaController>().loadCajas();
  }

  Future<void> _cerrarCaja() async {
    await VntlModal.show(
      context,
      title: 'Cerrar ${_cajaSeleccionada!.nombre}',
      subtitle: 'Cuenta el efectivo y confirma el cierre del turno',
      width: 420,
      content: const CerrarCajaSheet(),
    );
    if (!mounted) return;
    context.read<SesionCajaController>().reset();
    setState(() => _cajaSeleccionada = null);
    await context.read<CajaController>().loadCajas();
  }

  @override
  Widget build(BuildContext context) {
    final cajaCtrl = context.watch<CajaController>();
    final sesionCtrl = context.watch<SesionCajaController>();
    final sesion = sesionCtrl.sesionActiva;
    final ventaCtrl = context.watch<VentaController>();

    if (cajaCtrl.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_cajaSeleccionada == null) {
      return _SelectorCajas(
        cajas: cajaCtrl.cajas,
        onSeleccionar: _seleccionarCaja,
      );
    }

    if (sesionCtrl.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (sesion == null || !sesion.isAbierta) {
      return _SinSesionAbierta(
        caja: _cajaSeleccionada!,
        onAbrir: _abrirCaja,
        onCambiarCaja: _cambiarCaja,
      );
    }

    final resumenCaja =
        ventaCtrl.ventasDeLaSesion.where((c) => c.cajaId == _cajaSeleccionada!.id).firstOrNull;

    return _SesionActivaView(
      caja: _cajaSeleccionada!,
      sesion: sesion,
      onCerrar: _cerrarCaja,
      onCambiarCaja: _cambiarCaja,
      onVerCorteX: _verCorteX,
      totalesPorMetodo: resumenCaja?.totalesPorMetodo ?? [],
      totalSesion: resumenCaja?.totalSesion ?? 0,
      efectivoEsperado: resumenCaja?.efectivoEsperado ?? 0,
      efectivoCobradoBruto: resumenCaja?.efectivoCobradoBruto ?? 0, // ← nuevo
      ventas: resumenCaja?.ventas ?? [],
    );
  }
}

// ─── Selector de cajas (tarjetas) ──────────────────────────────────────────────
class _SelectorCajas extends StatelessWidget {
  final List<CajaModel> cajas;
  final ValueChanged<CajaModel> onSeleccionar;

  const _SelectorCajas({required this.cajas, required this.onSeleccionar});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (cajas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.point_of_sale_rounded, size: 48, color: colors.textTertiary),
            const SizedBox(height: VntlSpacing.lg),
            Text('Sin cajas configuradas', style: VntlText.h3),
            const SizedBox(height: VntlSpacing.sm),
            Text(
              'Pide a un administrador que configure una caja en Settings.',
              style: VntlText.body.copyWith(color: colors.textSecondary),
            ),
          ],
        ),
      );
    }

    if (cajas.length == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) => onSeleccionar(cajas.first));
      return const Center(child: CircularProgressIndicator());
    }

    return Align(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(VntlSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Selecciona tu caja', style: VntlText.h3),
            const SizedBox(height: VntlSpacing.xs),
            Text(
              'Elige con cuál vas a trabajar este turno',
              style: VntlText.body.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: VntlSpacing.xl),
            Wrap(
              spacing: VntlSpacing.md,
              runSpacing: VntlSpacing.md,
              children:
                  cajas.map((c) => _CajaTarjeta(caja: c, onTap: () => onSeleccionar(c))).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CajaTarjeta extends StatelessWidget {
  final CajaModel caja;
  final VoidCallback onTap;

  const _CajaTarjeta({required this.caja, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
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
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: caja.tieneSesionAbierta
                        ? colors.success.withValues(alpha: 0.15)
                        : colors.primarySurface,
                    borderRadius: VntlRadius.mdBorderRadius,
                  ),
                  child: Icon(
                    Icons.point_of_sale_rounded,
                    color: caja.tieneSesionAbierta ? colors.success : colors.error,
                    size: 22,
                  ),
                ),
                Icon(Icons.circle,
                    size: 8, color: caja.tieneSesionAbierta ? colors.success : colors.error),
              ],
            ),
            const SizedBox(height: VntlSpacing.md),
            Text(caja.nombre, style: VntlText.h4),
            const SizedBox(height: VntlSpacing.xs),
            Text(
              caja.tieneSesionAbierta
                  ? 'Abierta por ${caja.abiertaPorNombre}'
                  : 'Tocar para entrar',
              style: VntlText.caption.copyWith(
                color: caja.tieneSesionAbierta ? colors.success : colors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sin sesión abierta ─────────────────────────────────────────────────────────
class _SinSesionAbierta extends StatelessWidget {
  final CajaModel caja;
  final VoidCallback onAbrir;
  final VoidCallback onCambiarCaja;

  const _SinSesionAbierta({
    required this.caja,
    required this.onAbrir,
    required this.onCambiarCaja,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_clock_rounded, size: 48, color: colors.textTertiary),
          const SizedBox(height: VntlSpacing.lg),
          Text(caja.nombre, style: VntlText.h3),
          const SizedBox(height: VntlSpacing.sm),
          Text(
            'Esta caja está cerrada. Ábrela para comenzar a vender.',
            style: VntlText.body.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: VntlSpacing.xl),
          Center(
            child: IntrinsicWidth(
              child: VntlButton(
                label: 'Abrir Caja',
                icon: Icons.lock_open_rounded,
                onPressed: onAbrir,
              ),
            ),
          ),
          const SizedBox(height: VntlSpacing.md),
          Center(
            child: IntrinsicWidth(
              child: VntlButton(
                label: 'Cambiar de caja',
                variant: VntlButtonVariant.ghost,
                onPressed: onCambiarCaja,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sesión activa ───────────────────────────────────────────────────────────────
class _SesionActivaView extends StatelessWidget {
  final CajaModel caja;
  final dynamic sesion;
  final VoidCallback onCerrar;
  final VoidCallback onCambiarCaja;
  final VoidCallback onVerCorteX;
  final List<TotalMetodoPagoModel> totalesPorMetodo;
  final double totalSesion;
  final double efectivoEsperado;
  final List<VentaResumenModel> ventas;
  final double efectivoCobradoBruto;

  const _SesionActivaView({
    required this.caja,
    required this.sesion,
    required this.onCerrar,
    required this.onCambiarCaja,
    required this.onVerCorteX,
    required this.totalesPorMetodo,
    required this.totalSesion,
    required this.efectivoEsperado,
    required this.efectivoCobradoBruto,
    required this.ventas,
  });

  static const String _kEfectivo = 'efectivo';

  bool _esEfectivo(String nombre) => nombre.trim().toLowerCase() == _kEfectivo;

  /// Suma el total bruto (incluye ventas canceladas) del método "Efectivo".
  double get _efectivoBruto {
    for (final m in totalesPorMetodo) {
      if (_esEfectivo(m.metodo)) return m.total;
    }
    return 0;
  }

  /// Suma lo devuelto en efectivo por cancelaciones (totales o parciales).
  double get _efectivoDevuelto {
    double total = 0;
    for (final v in ventas) {
      if (v.estado != 'cancelada') continue;
      final dev = v.devolucion;
      if (dev != null && _esEfectivo(dev.metodo)) {
        total += dev.montoDevuelto;
      }
    }
    return total;
  }

  /// Suma de todo lo que no es efectivo (no afecta el efectivo esperado).
  double get _otrosMetodosTotal {
    double total = 0;
    for (final m in totalesPorMetodo) {
      if (!_esEfectivo(m.metodo)) total += m.total;
    }
    return total;
  }

  /// Total vendido neto: viene ya calculado del backend, cada método con
  /// su devolución restada correctamente (prorrateada contra el método
  /// original de cobro).
  double get _totalNeto {
    return totalesPorMetodo.fold(0.0, (s, m) => s + m.total);
  }

  /// Una cancelación es "total" cuando se devolvió el 100% del monto de la
  /// venta. Si se devolvió menos, fue una devolución parcial y una parte de
  /// la venta original sigue contando como venta real.
  bool _esCancelacionTotal(VentaResumenModel v) {
    final dev = v.devolucion;
    if (dev == null) return true;
    return dev.montoDevuelto >= v.total - 0.01;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final canceladas = ventas.where((v) => v.estado == 'cancelada').toList();

    return Align(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(VntlSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(caja.nombre, style: VntlText.h3),
                      const SizedBox(height: VntlSpacing.xs),
                      Row(
                        children: [
                          Icon(Icons.circle, size: 8, color: colors.success),
                          const SizedBox(width: VntlSpacing.xs),
                          Text(
                            'Sesión abierta · ${sesion.usuarioNombre ?? '—'}',
                            style: VntlText.caption.copyWith(color: colors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: VntlSpacing.sm,
                  children: [
                    VntlButton(
                      label: 'Cambiar caja',
                      icon: Icons.swap_horiz_rounded,
                      variant: VntlButtonVariant.ghost,
                      size: VntlButtonSize.sm,
                      onPressed: onCambiarCaja,
                    ),
                    VntlButton(
                      label: 'Generar Corte X',
                      icon: Icons.receipt_long_rounded,
                      variant: VntlButtonVariant.secondary,
                      size: VntlButtonSize.sm,
                      onPressed: onVerCorteX,
                    ),
                    VntlButton(
                      label: 'Cerrar Caja',
                      icon: Icons.lock_rounded,
                      variant: VntlButtonVariant.danger,
                      size: VntlButtonSize.sm,
                      onPressed: onCerrar,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: VntlSpacing.xl),
            Container(
              padding: const EdgeInsets.all(VntlSpacing.lg),
              decoration: BoxDecoration(
                color: colors.glassSurface,
                borderRadius: VntlRadius.lgBorderRadius,
                border: Border.all(
                  color: caja.tieneSesionAbierta ? colors.success : colors.border,
                  width: caja.tieneSesionAbierta ? 1.5 : 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Efectivo inicial',
                      style: VntlText.label.copyWith(color: colors.textTertiary)),
                  const SizedBox(height: VntlSpacing.xs),
                  Text('\$${sesion.montoInicial.toStringAsFixed(2)}', style: VntlText.h2),
                ],
              ),
            ),
            const SizedBox(height: VntlSpacing.xl),
            _DesgloseEfectivoEsperado(
              montoInicial: sesion.montoInicial,
              efectivoBruto: efectivoCobradoBruto,
              efectivoDevuelto: _efectivoDevuelto,
              efectivoEsperado: efectivoEsperado,
              otrosMetodosTotal: _otrosMetodosTotal,
            ),
            const SizedBox(height: VntlSpacing.xl),
            Container(
              padding: const EdgeInsets.all(VntlSpacing.lg),
              width: double.infinity,
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Resumen por método de pago', style: VntlText.h4),
                          const SizedBox(height: VntlSpacing.xs),
                          Text(
                            'Ya descontadas las devoluciones',
                            style: VntlText.caption.copyWith(color: colors.textTertiary),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Total vendido',
                              style: VntlText.caption.copyWith(color: colors.textTertiary)),
                          Text(
                            '\$${_totalNeto.toStringAsFixed(2)}',
                            style: VntlText.h3.copyWith(color: colors.primary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: VntlSpacing.lg),
                  if (totalesPorMetodo.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: VntlSpacing.lg),
                      child: Center(
                        child: Text(
                          'Aún no hay ventas en esta sesión.',
                          style: VntlText.body.copyWith(color: colors.textTertiary),
                        ),
                      ),
                    )
                  else ...[
                    Wrap(
                      spacing: VntlSpacing.md,
                      runSpacing: VntlSpacing.md,
                      children:
                          totalesPorMetodo.map((m) => _MetodoPagoTotalCard(metodo: m)).toList(),
                    ),
                  ],
                ],
              ),
            ),
            if (canceladas.isNotEmpty) ...[
              const SizedBox(height: VntlSpacing.xl),
              Container(
                padding: const EdgeInsets.all(VntlSpacing.lg),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colors.glassSurface,
                  borderRadius: VntlRadius.lgBorderRadius,
                  border: Border.all(color: colors.error.withValues(alpha: 0.3), width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Ventas canceladas', style: VntlText.h4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: VntlSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.error.withValues(alpha: 0.12),
                            borderRadius: VntlRadius.smBorderRadius,
                          ),
                          child: Text(
                            '${canceladas.length}',
                            style: VntlText.label.copyWith(color: colors.error),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: VntlSpacing.lg),
                    ...canceladas.map((v) => Padding(
                          padding: const EdgeInsets.only(bottom: VntlSpacing.sm),
                          child: _VentaCanceladaTile(
                            venta: v,
                            esTotal: _esCancelacionTotal(v),
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Ítem de venta cancelada (distingue total vs. parcial) ────────────────────
class _VentaCanceladaTile extends StatelessWidget {
  final VentaResumenModel venta;
  final bool esTotal;

  const _VentaCanceladaTile({required this.venta, required this.esTotal});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dev = venta.devolucion;

    if (esTotal || dev == null) {
      // Cancelación total: se ve tachado completo, como antes.
      return Container(
        padding: const EdgeInsets.all(VntlSpacing.md),
        decoration: BoxDecoration(
          color: colors.surfaceSecondary,
          borderRadius: VntlRadius.smBorderRadius,
          border: Border.all(color: colors.error.withValues(alpha: 0.2), width: 0.5),
        ),
        child: Row(
          children: [
            Icon(Icons.cancel_rounded, size: 16, color: colors.error),
            const SizedBox(width: VntlSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venta.numeroTicketCompleto,
                    style: VntlText.label.copyWith(
                      color: colors.error,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  if (dev != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Devuelto: \$${dev.montoDevuelto.toStringAsFixed(2)} en ${dev.metodo}',
                      style: VntlText.caption.copyWith(color: colors.textTertiary),
                    ),
                    if (dev.motivo != null)
                      Text(
                        'Motivo: ${dev.motivo!}',
                        style: VntlText.caption.copyWith(color: colors.textTertiary),
                      ),
                  ],
                ],
              ),
            ),
            Text(
              '\$${venta.total.toStringAsFixed(2)}',
              style: VntlText.label.copyWith(
                color: colors.error,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ],
        ),
      );
    }

    // Cancelación parcial: la venta se conserva en parte, no se tacha
    // completa. Se desglosa vendido / devuelto / conservado.
    final conservado = venta.total - dev.montoDevuelto;
    return Container(
      padding: const EdgeInsets.all(VntlSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: VntlRadius.smBorderRadius,
        border: Border.all(color: colors.warning.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.undo_rounded, size: 16, color: colors.warning),
              const SizedBox(width: VntlSpacing.sm),
              Expanded(
                child: Text(
                  venta.numeroTicketCompleto,
                  style: VntlText.label.copyWith(color: colors.warning),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: VntlSpacing.xs, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.warning.withValues(alpha: 0.12),
                  borderRadius: VntlRadius.smBorderRadius,
                ),
                child: Text(
                  'Devolución parcial',
                  style: VntlText.caption.copyWith(color: colors.warning),
                ),
              ),
            ],
          ),
          const SizedBox(height: VntlSpacing.sm),
          _filaMonto(context, 'Vendido', venta.total, colors.textSecondary),
          _filaMonto(context, 'Devuelto en ${dev.metodo}', -dev.montoDevuelto, colors.error),
          Divider(color: colors.border, height: VntlSpacing.md),
          _filaMonto(context, 'Conservado como venta', conservado, colors.success, destacado: true),
          if (dev.motivo != null) ...[
            const SizedBox(height: VntlSpacing.xs),
            Text(
              'Motivo: ${dev.motivo!}',
              style: VntlText.caption.copyWith(color: colors.textTertiary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _filaMonto(BuildContext context, String label, double valor, Color color,
      {bool destacado = false}) {
    final colors = context.colors;
    final prefijo = valor < 0 ? '- ' : '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: VntlText.caption.copyWith(color: colors.textTertiary)),
          Text(
            '$prefijo\$${valor.abs().toStringAsFixed(2)}',
            style: (destacado ? VntlText.label : VntlText.caption).copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

// ─── Desglose de efectivo esperado ─────────────────────────────────────────────
/// Explica de dónde sale el "efectivo esperado en caja": parte del efectivo
/// inicial, suma lo cobrado en efectivo (incluye ventas luego canceladas) y
/// resta lo devuelto en efectivo por cancelaciones. Las ventas con tarjeta u
/// otros métodos no afectan este cálculo porque no pasan por la caja física.
class _DesgloseEfectivoEsperado extends StatelessWidget {
  final double montoInicial;
  final double efectivoBruto;
  final double efectivoDevuelto;
  final double efectivoEsperado;
  final double otrosMetodosTotal;

  const _DesgloseEfectivoEsperado({
    required this.montoInicial,
    required this.efectivoBruto,
    required this.efectivoDevuelto,
    required this.efectivoEsperado,
    required this.otrosMetodosTotal,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(VntlSpacing.lg),
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.glassSurface,
        borderRadius: VntlRadius.lgBorderRadius,
        border: Border.all(color: colors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('¿De dónde sale el efectivo esperado?', style: VntlText.h4),
          const SizedBox(height: VntlSpacing.lg),
          _fila(
            context,
            icon: Icons.account_balance_wallet_rounded,
            iconColor: colors.textTertiary,
            label: 'Efectivo inicial',
            valor: montoInicial,
            valorColor: colors.textPrimary,
          ),
          const SizedBox(height: VntlSpacing.sm),
          _fila(
            context,
            icon: Icons.add_rounded,
            iconColor: colors.success,
            label: 'Cobrado en efectivo',
            valor: efectivoBruto,
            valorColor: colors.success,
            prefijo: '+ ',
          ),
          const SizedBox(height: VntlSpacing.sm),
          _fila(
            context,
            icon: Icons.remove_rounded,
            iconColor: colors.error,
            label: 'Devuelto por cancelaciones',
            valor: efectivoDevuelto,
            valorColor: colors.error,
            prefijo: '- ',
          ),
          const SizedBox(height: VntlSpacing.md),
          Divider(color: colors.border, height: 0.5),
          const SizedBox(height: VntlSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Efectivo esperado en caja', style: VntlText.label),
              Text(
                '\$${efectivoEsperado.toStringAsFixed(2)}',
                style: VntlText.h3.copyWith(color: colors.success),
              ),
            ],
          ),
          if (otrosMetodosTotal > 0) ...[
            const SizedBox(height: VntlSpacing.lg),
            Container(
              padding: const EdgeInsets.all(VntlSpacing.md),
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                borderRadius: VntlRadius.smBorderRadius,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.credit_card_rounded, size: 16, color: colors.textTertiary),
                  const SizedBox(width: VntlSpacing.sm),
                  Expanded(
                    child: Text(
                      'Las ventas con tarjeta u otros métodos (\$${otrosMetodosTotal.toStringAsFixed(2)}) no suman ni restan aquí, porque ese dinero no pasa por la caja física.',
                      style: VntlText.caption.copyWith(color: colors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _fila(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required double valor,
    required Color valorColor,
    String prefijo = '',
  }) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: VntlSpacing.xs),
            Text(label, style: VntlText.body.copyWith(color: colors.textSecondary)),
          ],
        ),
        Text(
          '$prefijo\$${valor.toStringAsFixed(2)}',
          style: VntlText.label.copyWith(color: valorColor),
        ),
      ],
    );
  }
}

class _MetodoPagoTotalCard extends StatelessWidget {
  final TotalMetodoPagoModel metodo;

  const _MetodoPagoTotalCard({required this.metodo});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = VntlPaymentStyle.forMetodo(
      context,
      metodo.id ?? 0,
      iconoKey: metodo.icono,
      colorHex: metodo.color,
    );

    return Container(
      width: 160,
      padding: const EdgeInsets.all(VntlSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: VntlRadius.mdBorderRadius,
        border: Border.all(color: style.foreground, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(style.icon, size: 14, color: style.foreground),
              const SizedBox(width: VntlSpacing.xs),
              Expanded(
                child: Text(
                  metodo.metodo,
                  style: VntlText.caption.copyWith(color: colors.textTertiary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: VntlSpacing.xs),
          Text(
            '\$${metodo.total.toStringAsFixed(2)}',
            style: VntlText.h4.copyWith(color: style.foreground),
          ),
        ],
      ),
    );
  }
}
