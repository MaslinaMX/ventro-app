import 'package:flutter/material.dart';

abstract class VntlColorScheme {
  // ─── Base ─────────────────────────────────────────────────────────────────
  Color get background;
  Color get surface;
  Color get surfaceSecondary;
  Color get surfaceTertiary;

  // ─── Glass ────────────────────────────────────────────────────────────────
  Color get glassSurface;
  Color get glassBorder;
  Color get glassHighlight;

  // ─── Primary ──────────────────────────────────────────────────────────────
  Color get primary;
  Color get primaryLight;
  Color get primaryDark;
  Color get primarySurface;

  // ─── Accent ───────────────────────────────────────────────────────────────
  Color get accent;
  Color get accentLight;
  Color get accentDark;
  Color get accentSurface;

  // ─── Semánticos ───────────────────────────────────────────────────────────
  Color get success;
  Color get successSurface;
  Color get warning;
  Color get warningSurface;
  Color get error;
  Color get errorSurface;
  Color get info;
  Color get infoSurface;

  // ─── Texto ────────────────────────────────────────────────────────────────
  Color get textPrimary;
  Color get textSecondary;
  Color get textTertiary;
  Color get textDisabled;

  // ─── Bordes ───────────────────────────────────────────────────────────────
  Color get border;
  Color get borderStrong;

  // ─── Gradientes ───────────────────────────────────────────────────────────
  LinearGradient get backgroundGradient;
  LinearGradient get primaryGradient;
  LinearGradient get accentGradient;

  // ─── Nav sections ─────────────────────────────────────────────────────────
  Color get navVentas;
  Color get navProductos;
  Color get navCategorias;
  Color get navClientes;
  Color get navReportes;
  Color get navVentasSurface;
  Color get navProductosSurface;
  Color get navCategoriasSurface;
  Color get navClientesSurface;
  Color get navReportesSurface;

  // ─── Destructivo ──────────────────────────────────────────────────────────
  Color get destructive;
  Color get destructiveSurface;
}
