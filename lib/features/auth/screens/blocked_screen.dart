import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/core/network/api_client.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/auth/controllers/auth_controller.dart';

class BlockedScreen extends StatelessWidget {
  final TenantBlockReason reason;
  final String message;

  const BlockedScreen({
    super.key,
    required this.reason,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final (icon, title, subtitle, color) = switch (reason) {
      TenantBlockReason.blocked => (
          Icons.lock_rounded,
          'Cuenta bloqueada',
          message,
          colors.error,
        ),
      TenantBlockReason.cancelled => (
          Icons.cancel_rounded,
          'Suscripción cancelada',
          message,
          colors.textSecondary,
        ),
      TenantBlockReason.trialExpired => (
          Icons.hourglass_empty_rounded,
          'Periodo de prueba expirado',
          message,
          colors.warning,
        ),
      _ => (
          Icons.warning_rounded,
          'Acceso restringido',
          message,
          colors.error,
        ),
    };

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: context.backgroundGradient),
        child: Center(
          child: SizedBox(
            width: 420,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: VntlRadius.lgBorderRadius,
                    border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
                  ),
                  child: Icon(icon, size: 40, color: color),
                ),
                const SizedBox(height: VntlSpacing.xl2),
                Text(title, style: VntlText.h2, textAlign: TextAlign.center),
                const SizedBox(height: VntlSpacing.md),
                Text(
                  subtitle,
                  style: VntlText.body.copyWith(color: colors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: VntlSpacing.xl3),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: VntlSpacing.xl),
                  child: VntlCard(
                    child: Column(
                      children: [
                        if (reason == TenantBlockReason.trialExpired ||
                            reason == TenantBlockReason.blocked) ...[
                          Text(
                            'Para reactivar tu cuenta realiza tu pago y contáctanos.',
                            style: VntlText.body.copyWith(color: colors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: VntlSpacing.xl),
                        ],
                        VntlButton(
                          label: 'Cerrar sesión',
                          fullWidth: true,
                          variant: VntlButtonVariant.ghost,
                          onPressed: () async {
                            await context.read<AuthController>().logout();
                            if (context.mounted) {
                              Navigator.pushReplacementNamed(context, '/');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
