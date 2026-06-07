import 'package:flutter/material.dart';

// ✅ Ventro Design System V2 — Colors (Linear-inspired)
class VntlColors {
  VntlColors._();

  // ─── Base — Negro neutro ──────────────────────────────────────────────────────
  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF111111);
  static const Color surfaceSecondary = Color(0xFF1A1A1A);
  static const Color surfaceTertiary = Color(0xFF222222);

  // ─── Glass ───────────────────────────────────────────────────────────────────
  static const Color glassSurface = Color(0x0DFFFFFF);
  static const Color glassBorder = Color(0x14FFFFFF);
  static const Color glassHighlight = Color(0x1FFFFFFF);

  // ─── Primary — Violeta acento ────────────────────────────────────────────────
  static const Color primary = Color(0xFF7C6AF7);
  static const Color primaryLight = Color(0xFF9D8FFA);
  static const Color primaryDark = Color(0xFF5E4FD4);
  static const Color primarySurface = Color(0x157C6AF7);

  // ─── Accent — Coral suave ────────────────────────────────────────────────────
  static const Color accent = Color(0xFFFF6B6B);
  static const Color accentLight = Color(0xFFFF8E8E);
  static const Color accentDark = Color(0xFFE54F4F);
  static const Color accentSurface = Color(0x15FF6B6B);

  // ─── Semánticos ──────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF4ADE80);
  static const Color successSurface = Color(0x154ADE80);
  static const Color warning = Color(0xFFFBBF24);
  static const Color warningSurface = Color(0x15FBBF24);
  static const Color error = Color(0xFFFF6B6B);
  static const Color errorSurface = Color(0x15FF6B6B);
  static const Color info = Color(0xFF60A5FA);
  static const Color infoSurface = Color(0x1560A5FA);

  // ─── Texto ───────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFEDEDED);
  static const Color textSecondary = Color(0xFF8A8A8A);
  static const Color textTertiary = Color(0xFF555555);
  static const Color textDisabled = Color(0xFF333333);

  // ─── Bordes ──────────────────────────────────────────────────────────────────
  static const Color border = Color(0xFF242424);
  static const Color borderStrong = Color(0xFF333333);

  // ─── Gradientes ──────────────────────────────────────────────────────────────
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A0A0A), Color(0xFF0F0F0F)],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF9D8FFA), Color(0xFF7C6AF7)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF8E8E), Color(0xFFFF6B6B)],
  );

  // ─── Nav sections ─────────────────────────────────────────────────────────────
  static const Color navVentas = Color(0xFF4ADE80); // esmeralda
  static const Color navProductos = Color(0xFF60A5FA); // azul
  static const Color navCategorias = Color(0xFFFBBF24); // amber
  static const Color navClientes = Color(0xFFFF6B6B); // coral
  static const Color navReportes = Color(0xFF9D8FFA); // violeta

// Surfaces (12% opacidad)
  static const Color navVentasSurface = Color(0x1F4ADE80);
  static const Color navProductosSurface = Color(0x1F60A5FA);
  static const Color navCategoriasSurface = Color(0x1FFBBF24);
  static const Color navClientesSurface = Color(0x1FFF6B6B);
  static const Color navReportesSurface = Color(0x1F9D8FFA);

// ─── Destructivo ─────────────────────────────────────────────────────────────
  static const Color destructive = Color(0xFFEF4444);
  static const Color destructiveSurface = Color(0x1FEF4444);
}
