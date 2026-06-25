import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/caja/models/caja_model.dart';
import 'package:ventro_app/features/ventas/controllers/venta_controller.dart';

class SelectorCajaVenta extends StatefulWidget {
  const SelectorCajaVenta({super.key});

  @override
  State<SelectorCajaVenta> createState() => _SelectorCajaVentaState();
}

class _SelectorCajaVentaState extends State<SelectorCajaVenta> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      context.read<VentaController>().cargarCajasAbiertas();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ctrl = context.watch<VentaController>();

    if (ctrl.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (ctrl.cajasAbiertas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_clock_rounded, size: 48, color: colors.textTertiary),
            const SizedBox(height: VntlSpacing.lg),
            Text('No hay cajas abiertas', style: VntlText.h3),
            const SizedBox(height: VntlSpacing.sm),
            Text(
              'Abre una caja desde el módulo de Caja para empezar a vender.',
              style: VntlText.body.copyWith(color: colors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: VntlSpacing.xl),
            VntlButton(
              label: 'Reintentar',
              icon: Icons.refresh_rounded,
              variant: VntlButtonVariant.ghost,
              onPressed: ctrl.cargarCajasAbiertas,
            ),
          ],
        ),
      );
    }

    return Align(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(VntlSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Selecciona una caja', style: VntlText.h3),
            const SizedBox(height: VntlSpacing.xs),
            Text(
              'Elige la caja desde la que vas a vender',
              style: VntlText.body.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: VntlSpacing.xl),
            Wrap(
              spacing: VntlSpacing.md,
              runSpacing: VntlSpacing.md,
              children: ctrl.cajasAbiertas
                  .map((c) => _CajaAbiertaCard(
                        caja: c,
                        onTap: () => ctrl.seleccionarCaja(c.id),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CajaAbiertaCard extends StatelessWidget {
  final CajaModel caja;
  final VoidCallback onTap;

  const _CajaAbiertaCard({required this.caja, required this.onTap});

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
          border: Border.all(color: colors.success, width: 1.5),
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
                    color: colors.success.withValues(alpha: 0.15),
                    borderRadius: VntlRadius.mdBorderRadius,
                  ),
                  child: Icon(Icons.point_of_sale_rounded, color: colors.success, size: 22),
                ),
                Icon(Icons.circle, size: 8, color: colors.success),
              ],
            ),
            const SizedBox(height: VntlSpacing.md),
            Text(caja.nombre, style: VntlText.h4),
            const SizedBox(height: VntlSpacing.xs),
            Text(
              'Abierta por ${caja.abiertaPorNombre ?? '—'}',
              style: VntlText.caption.copyWith(color: colors.success),
            ),
          ],
        ),
      ),
    );
  }
}
