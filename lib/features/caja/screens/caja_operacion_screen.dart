import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/caja/controllers/caja_controller.dart';
import 'package:ventro_app/features/caja/controllers/sesion_caja_controller.dart';
import 'package:ventro_app/features/caja/models/caja_model.dart';
import 'package:ventro_app/features/caja/widgets/abrir_caja_sheet.dart';
import 'package:ventro_app/features/caja/widgets/cerrar_caja_sheet.dart';

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
  }

  void _cambiarCaja() {
    context.read<SesionCajaController>().reset();
    setState(() => _cajaSeleccionada = null);
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
    await context.read<CajaController>().loadCajas();
  }

  @override
  Widget build(BuildContext context) {
    final cajaCtrl = context.watch<CajaController>();
    final sesionCtrl = context.watch<SesionCajaController>();

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

    final sesion = sesionCtrl.sesionActiva;

    if (sesion == null || !sesion.isAbierta) {
      return _SinSesionAbierta(
        caja: _cajaSeleccionada!,
        onAbrir: _abrirCaja,
        onCambiarCaja: _cambiarCaja,
      );
    }

    return _SesionActivaView(
      caja: _cajaSeleccionada!,
      sesion: sesion,
      onCerrar: _cerrarCaja,
      onCambiarCaja: _cambiarCaja,
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

    // Si solo hay una caja, se selecciona automáticamente sin mostrar el selector.
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
  final dynamic sesion; // SesionCajaModel
  final VoidCallback onCerrar;
  final VoidCallback onCambiarCaja;

  const _SesionActivaView({
    required this.caja,
    required this.sesion,
    required this.onCerrar,
    required this.onCambiarCaja,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Align(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(VntlSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                VntlButton(
                  label: 'Cambiar caja',
                  variant: VntlButtonVariant.ghost,
                  onPressed: onCambiarCaja,
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
            Container(
              padding: const EdgeInsets.all(VntlSpacing.xl * 1.5),
              width: double.infinity,
              decoration: BoxDecoration(
                color: colors.glassSurface,
                borderRadius: VntlRadius.lgBorderRadius,
                border: Border.all(color: colors.border, width: 0.5),
              ),
              child: Column(
                children: [
                  Icon(Icons.point_of_sale_rounded, size: 48, color: colors.textTertiary),
                  const SizedBox(height: VntlSpacing.lg),
                  Text('Pantalla de venta', style: VntlText.h4),
                  const SizedBox(height: VntlSpacing.sm),
                  Text(
                    'Próximamente',
                    style: VntlText.body.copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: VntlSpacing.xl),
            VntlButton(
              label: 'Cerrar Caja',
              icon: Icons.lock_rounded,
              variant: VntlButtonVariant.danger,
              onPressed: onCerrar,
            ),
          ],
        ),
      ),
    );
  }
}
