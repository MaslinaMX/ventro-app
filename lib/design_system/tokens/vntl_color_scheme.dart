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
  // ─── Nav sections (agrupadas por categoría funcional) ────────────────────
  // Operación diaria
  Color get navVentas;
  Color get navCaja;
  Color get navPedidos;
  // Catálogo
  Color get navProductos;
  Color get navInventario;
  Color get navCotizaciones;
  // Cadena de suministro
  Color get navProveedores;
  Color get navCompras;
  // Personas y análisis
  Color get navClientes;
  Color get navReportes;

  Color get navVentasSurface;
  Color get navCajaSurface;
  Color get navPedidosSurface;
  Color get navProductosSurface;
  Color get navInventarioSurface;
  Color get navCotizacionesSurface;
  Color get navProveedoresSurface;
  Color get navComprasSurface;
  Color get navClientesSurface;
  Color get navReportesSurface;
  // ─── Destructivo ──────────────────────────────────────────────────────────
  Color get destructive;
  Color get destructiveSurface;
}
