import 'package:flutter/material.dart';
import 'vntl_color_scheme.dart';

class VntlColorsDark implements VntlColorScheme {
  const VntlColorsDark();

  // ── Fondos base ──────────────────────────────────────────────
  @override
  Color get background => const Color(0xFF0A0A0A);

  @override
  Color get surface => const Color(0xFF111111);

  @override
  Color get surfaceSecondary => const Color(0xFF1A1A1A);

  @override
  Color get surfaceTertiary => const Color(0xFF222222);

  // ── Glassmorphism ────────────────────────────────────────────
  @override
  Color get glassSurface => const Color(0x0DFFFFFF);

  @override
  Color get glassBorder => const Color(0x14FFFFFF);

  @override
  Color get glassHighlight => const Color(0x1FFFFFFF);

  // ── Primary — verde menta ────────────────────────────────────
  @override
  Color get primary => const Color(0xFF2A9D7F);

  @override
  Color get primaryLight => const Color(0xFF52B89B);

  @override
  Color get primaryDark => const Color(0xFF1F7A63);

  @override
  Color get primarySurface => const Color(0x152A9D7F);

  // ── Accent — coral/rojo ──────────────────────────────────────
  @override
  Color get accent => const Color(0xFFFF6B6B);

  @override
  Color get accentLight => const Color(0xFFFF8E8E);

  @override
  Color get accentDark => const Color(0xFFE54F4F);

  @override
  Color get accentSurface => const Color(0x15FF6B6B);

  // ── Estados semánticos ───────────────────────────────────────
  @override
  Color get success => const Color(0xFF4ADE80);

  @override
  Color get successSurface => const Color(0x154ADE80);

  @override
  Color get warning => const Color(0xFFFBBF24);

  @override
  Color get warningSurface => const Color(0x15FBBF24);

  @override
  Color get error => const Color(0xFFFF6B6B);

  @override
  Color get errorSurface => const Color(0x15FF6B6B);

  @override
  Color get info => const Color(0xFF60A5FA);

  @override
  Color get infoSurface => const Color(0x1560A5FA);

  // ── Texto ────────────────────────────────────────────────────
  @override
  Color get textPrimary => const Color(0xFFEDEDED);

  @override
  Color get textSecondary => const Color(0xFF8A8A8A);

  @override
  Color get textTertiary => const Color(0xFF555555);

  @override
  Color get textDisabled => const Color(0xFF333333);

  // ── Bordes ───────────────────────────────────────────────────
  @override
  Color get border => const Color(0xFF242424);

  @override
  Color get borderStrong => const Color(0xFF333333);

  // ── Gradientes ───────────────────────────────────────────────
  @override
  LinearGradient get backgroundGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0A0A0A), Color(0xFF0F0F0F)],
      );

  @override
  LinearGradient get primaryGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF52B89B), Color(0xFF2A9D7F)],
      );

  @override
  LinearGradient get accentGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFF8E8E), Color(0xFFFF6B6B)],
      );

  // ── Nav: Operación diaria → menta / ámbar ────────────────────
  @override
  Color get navVentas => const Color(0xFF2A9D7F);

  @override
  Color get navCaja => const Color(0xFF2A9D7F);

  @override
  Color get navPedidos => const Color(0xFFD97706);

  // ── Nav: Catálogo → azul ──────────────────────────────────────
  @override
  Color get navProductos => const Color(0xFF2563EB);

  @override
  Color get navInventario => const Color(0xFF2563EB);

  @override
  Color get navCotizaciones => const Color(0xFF2563EB);

  // ── Nav: Cadena de suministro → púrpura ──────────────────────
  @override
  Color get navProveedores => const Color(0xFF7C6AF7);

  @override
  Color get navCompras => const Color(0xFF7C6AF7);

  // ── Nav: Personas y análisis → rosa / índigo ─────────────────
  @override
  Color get navClientes => const Color(0xFFDB2777);

  @override
  Color get navReportes => const Color(0xFF6366F1);

  // ── Nav surfaces (fondo 12% alpha para ítem activo) ──────────
  @override
  Color get navVentasSurface => const Color(0x1F2A9D7F);

  @override
  Color get navCajaSurface => const Color(0x1F2A9D7F);

  @override
  Color get navPedidosSurface => const Color(0x1FD97706);

  @override
  Color get navProductosSurface => const Color(0x1F2563EB);

  @override
  Color get navInventarioSurface => const Color(0x1F2563EB);

  @override
  Color get navCotizacionesSurface => const Color(0x1F2563EB);

  @override
  Color get navProveedoresSurface => const Color(0x1F7C6AF7);

  @override
  Color get navComprasSurface => const Color(0x1F7C6AF7);

  @override
  Color get navClientesSurface => const Color(0x1FDB2777);

  @override
  Color get navReportesSurface => const Color(0x1F6366F1);

  // ── Acciones destructivas ───────────────────────────────────
  @override
  Color get destructive => const Color(0xFFEF4444);

  @override
  Color get destructiveSurface => const Color(0x1FEF4444);
}
