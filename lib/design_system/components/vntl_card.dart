import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ventro_app/design_system/vntl.dart';

// ✅ Ventro Design System V1 — VntlCard
enum VntlCardVariant { glass, solid, outline }

class VntlCard extends StatelessWidget {
  final Widget child;
  final VntlCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const VntlCard({
    super.key,
    required this.child,
    this.variant = VntlCardVariant.glass,
    this.padding,
    this.onTap,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? VntlRadius.lgBorderRadius;

    Widget card = switch (variant) {
      VntlCardVariant.glass => _GlassCard(
          radius: radius,
          padding: padding,
          child: child,
        ),
      VntlCardVariant.solid => _SolidCard(
          radius: radius,
          padding: padding,
          child: child,
        ),
      VntlCardVariant.outline => _OutlineCard(
          radius: radius,
          padding: padding,
          child: child,
        ),
    };

    if (width != null || height != null) {
      card = SizedBox(width: width, height: height, child: card);
    }

    if (onTap != null) {
      card = GestureDetector(onTap: onTap, child: card);
    }

    return card;
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final BorderRadius radius;
  final EdgeInsetsGeometry? padding;

  const _GlassCard({
    required this.child,
    required this.radius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: VntlColors.glassSurface,
            borderRadius: radius,
            border: Border.all(color: VntlColors.glassBorder, width: 0.5),
          ),
          padding: padding ?? const EdgeInsets.all(VntlSpacing.lg),
          child: child,
        ),
      ),
    );
  }
}

class _SolidCard extends StatelessWidget {
  final Widget child;
  final BorderRadius radius;
  final EdgeInsetsGeometry? padding;

  const _SolidCard({
    required this.child,
    required this.radius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: VntlColors.surfaceSecondary,
        borderRadius: radius,
        border: Border.all(color: VntlColors.border, width: 0.5),
      ),
      padding: padding ?? const EdgeInsets.all(VntlSpacing.lg),
      child: child,
    );
  }
}

class _OutlineCard extends StatelessWidget {
  final Widget child;
  final BorderRadius radius;
  final EdgeInsetsGeometry? padding;

  const _OutlineCard({
    required this.child,
    required this.radius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: radius,
        border: Border.all(color: VntlColors.borderStrong, width: 1),
      ),
      padding: padding ?? const EdgeInsets.all(VntlSpacing.lg),
      child: child,
    );
  }
}
