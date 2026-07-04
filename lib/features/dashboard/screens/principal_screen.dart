import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/auth/controllers/auth_controller.dart';
import 'package:ventro_app/features/auth/models/user_model.dart';
import 'package:ventro_app/features/dashboard/widgets/resumen_mes_card.dart';

class PrincipalScreen extends StatelessWidget {
  final VoidCallback onNavigateToGastos;
  final VoidCallback onNavigateToVentasTodas;

  const PrincipalScreen({
    super.key,
    required this.onNavigateToGastos,
    required this.onNavigateToVentasTodas,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final esAdmin = context.watch<AuthController>().user?.role.isAdmin ?? false;

    return Scaffold(
      backgroundColor: colors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(VntlSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (esAdmin)
              ResumenMesCard(
                onTapGastado: onNavigateToGastos,
                onTapVendido: onNavigateToVentasTodas,
              ),
            // Aquí se pueden ir agregando más widgets del dashboard
            // (accesos rápidos, últimas ventas, alertas de stock, etc.)
          ],
        ),
      ),
    );
  }
}
