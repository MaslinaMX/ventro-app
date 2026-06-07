import 'package:flutter/material.dart';
import 'package:ventro_app/design_system/vntl.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: VntlColors.backgroundGradient,
        ),
        child: Center(
          child: SizedBox(
            width: 420,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: VntlColors.backgroundGradient,
                    borderRadius: VntlRadius.lgBorderRadius,
                  ),
                  child: const Icon(
                    Icons.point_of_sale_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: VntlSpacing.xl2),
                const Text('Ventro', style: VntlText.h1),
                const SizedBox(height: VntlSpacing.sm),
                Text(
                  'El punto de venta para tu negocio',
                  style: VntlText.body.copyWith(color: VntlColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: VntlSpacing.xl6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: VntlSpacing.md),
                  child: VntlCard(
                    child: Column(
                      children: [
                        VntlButton(
                          label: 'Crear mi negocio',
                          fullWidth: true,
                          size: VntlButtonSize.lg,
                          onPressed: () => Navigator.pushNamed(context, '/register'),
                        ),
                        const SizedBox(height: VntlSpacing.md),
                        VntlButton(
                          label: 'Ya tengo una cuenta',
                          fullWidth: true,
                          size: VntlButtonSize.lg,
                          variant: VntlButtonVariant.ghost,
                          onPressed: () => Navigator.pushNamed(context, '/lookup'),
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
