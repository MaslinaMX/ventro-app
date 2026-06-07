import 'package:flutter/material.dart';
import 'vntl_colors.dart';

// ✅ Ventro Design System V1 — Typography
class VntlText {
  VntlText._();

  static const String _font = 'Campton';

  // Display
  static const TextStyle display = TextStyle(
    fontFamily: _font,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    color: VntlColors.textPrimary,
    letterSpacing: -1.0,
    height: 1.1,
  );

  // Headings
  static const TextStyle h1 = TextStyle(
    fontFamily: _font,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: VntlColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: _font,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: VntlColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: _font,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: VntlColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle h4 = TextStyle(
    fontFamily: _font,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: VntlColors.textPrimary,
    height: 1.4,
  );

  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _font,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: VntlColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle body = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: VntlColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _font,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: VntlColors.textSecondary,
    height: 1.5,
  );

  // Label
  static const TextStyle label = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: VntlColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: _font,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: VntlColors.textSecondary,
    letterSpacing: 0.5,
    height: 1.4,
  );

  // Caption
  static const TextStyle caption = TextStyle(
    fontFamily: _font,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: VntlColors.textTertiary,
    height: 1.4,
  );

  // Monospace — para precios, números
  static const TextStyle mono = TextStyle(
    fontFamily: 'monospace',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: VntlColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle monoLarge = TextStyle(
    fontFamily: 'monospace',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: VntlColors.textPrimary,
    height: 1.2,
  );
}
