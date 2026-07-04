import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/auth/controllers/auth_controller.dart';
import 'package:ventro_app/features/auth/models/user_model.dart';
import 'package:ventro_app/features/dashboard/controllers/dashboard_controller.dart';

class ResumenMesCard extends StatefulWidget {
  final VoidCallback? onTapVendido;
  final VoidCallback? onTapGastado;

  const ResumenMesCard({
    super.key,
    this.onTapVendido,
    this.onTapGastado,
  });

  @override
  State<ResumenMesCard> createState() => _ResumenMesCardState();
}

class _ResumenMesCardState extends State<ResumenMesCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardController>().cargarResumenMes();
    });
  }

  Future<void> _onTapVendido(bool esAdmin) async {
    if (esAdmin) {
      widget.onTapVendido?.call();
      return;
    }

    await VntlDialog.confirm(
      context,
      title: 'Acceso restringido',
      message: 'Solo un administrador puede ver el listado completo de ventas.',
      confirmLabel: 'Entendido',
      cancelLabel: 'Cerrar',
    );
  }

  Future<void> _onTapGastado(bool esAdmin) async {
    if (esAdmin) {
      widget.onTapGastado?.call();
      return;
    }

    await VntlDialog.confirm(
      context,
      title: 'Acceso restringido',
      message: 'Solo un administrador puede ver el listado de gastos.',
      confirmLabel: 'Entendido',
      cancelLabel: 'Cerrar',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ctrl = context.watch<DashboardController>();
    final resumen = ctrl.resumenMes;
    final esAdmin = context.watch<AuthController>().user?.role.isAdmin ?? false;

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
          Text('Este mes', style: VntlText.h4),
          const SizedBox(height: VntlSpacing.lg),
          if (ctrl.cargando)
            const Center(child: CircularProgressIndicator())
          else if (resumen == null)
            Text(
              ctrl.errorMessage ?? 'No se pudo cargar el resumen',
              style: VntlText.body.copyWith(color: colors.textTertiary),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _Metrica(
                        label: 'Vendido',
                        valor: resumen.vendido,
                        color: colors.success,
                        icon: Icons.trending_up_rounded,
                        onTap: () => _onTapVendido(esAdmin),
                        restringido: !esAdmin,
                      ),
                    ),
                    const SizedBox(width: VntlSpacing.md),
                    Expanded(
                      child: _Metrica(
                        label: 'Gastado',
                        valor: resumen.gastado,
                        color: colors.error,
                        icon: Icons.trending_down_rounded,
                        onTap: () => _onTapGastado(esAdmin),
                        restringido: !esAdmin,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: VntlSpacing.lg),
                Divider(color: colors.border, height: 0.5),
                const SizedBox(height: VntlSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Diferencia', style: VntlText.label),
                    Text(
                      '\$${resumen.neto.toStringAsFixed(2)}',
                      style: VntlText.h3.copyWith(
                        color: resumen.neto >= 0 ? colors.primary : colors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _Metrica extends StatelessWidget {
  final String label;
  final double valor;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  /// Cuando es true, la tarjeta sigue siendo tappable (para explicar la
  /// restricción con un diálogo), pero muestra un candado en vez de la
  /// flecha de navegación, para no sugerir que llevará a otra pantalla.
  final bool restringido;

  const _Metrica({
    required this.label,
    required this.valor,
    required this.color,
    required this.icon,
    this.onTap,
    this.restringido = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final contenido = Container(
      padding: const EdgeInsets.all(VntlSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: VntlRadius.mdBorderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: VntlSpacing.xs),
              Expanded(
                child: Text(label, style: VntlText.caption.copyWith(color: colors.textTertiary)),
              ),
              if (onTap != null)
                Icon(
                  restringido ? Icons.lock_outline_rounded : Icons.chevron_right_rounded,
                  size: 14,
                  color: colors.textTertiary,
                ),
            ],
          ),
          const SizedBox(height: VntlSpacing.xs),
          Text('\$${valor.toStringAsFixed(2)}', style: VntlText.h3.copyWith(color: color)),
        ],
      ),
    );

    if (onTap == null) return contenido;
    return GestureDetector(onTap: onTap, child: contenido);
  }
}
