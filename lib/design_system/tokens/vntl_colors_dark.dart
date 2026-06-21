import 'package:flutter/material.dart';
import 'vntl_color_scheme.dart';

class VntlColorsDark implements VntlColorScheme {
  const VntlColorsDark();

  @override
  Color get background => const Color(0xFF0A0A0A);
  @override
  Color get surface => const Color(0xFF111111);
  @override
  Color get surfaceSecondary => const Color(0xFF1A1A1A);
  @override
  Color get surfaceTertiary => const Color(0xFF222222);

  @override
  Color get glassSurface => const Color(0x0DFFFFFF);
  @override
  Color get glassBorder => const Color(0x14FFFFFF);
  @override
  Color get glassHighlight => const Color(0x1FFFFFFF);

  @override
  Color get primary => const Color(0xFF7C6AF7);
  @override
  Color get primaryLight => const Color(0xFF9D8FFA);
  @override
  Color get primaryDark => const Color(0xFF5E4FD4);
  @override
  Color get primarySurface => const Color(0x157C6AF7);

  @override
  Color get accent => const Color(0xFFFF6B6B);
  @override
  Color get accentLight => const Color(0xFFFF8E8E);
  @override
  Color get accentDark => const Color(0xFFE54F4F);
  @override
  Color get accentSurface => const Color(0x15FF6B6B);

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

  @override
  Color get textPrimary => const Color(0xFFEDEDED);
  @override
  Color get textSecondary => const Color(0xFF8A8A8A);
  @override
  Color get textTertiary => const Color(0xFF555555);
  @override
  Color get textDisabled => const Color(0xFF333333);

  @override
  Color get border => const Color(0xFF242424);
  @override
  Color get borderStrong => const Color(0xFF333333);

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
        colors: [Color(0xFF9D8FFA), Color(0xFF7C6AF7)],
      );
  @override
  LinearGradient get accentGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFF8E8E), Color(0xFFFF6B6B)],
      );

  @override
  Color get navVentas => const Color(0xFF4ADE80);
  @override
  Color get navProductos => const Color(0xFF60A5FA);
  @override
  Color get navCategorias => const Color(0xFFFBBF24);
  @override
  Color get navClientes => const Color(0xFFFF6B6B);
  @override
  Color get navReportes => const Color(0xFF9D8FFA);
  @override
  Color get navVentasSurface => const Color(0x1F4ADE80);
  @override
  Color get navProductosSurface => const Color(0x1F60A5FA);
  @override
  Color get navCategoriasSurface => const Color(0x1FFBBF24);
  @override
  Color get navClientesSurface => const Color(0x1FFF6B6B);
  @override
  Color get navReportesSurface => const Color(0x1F9D8FFA);

  @override
  Color get destructive => const Color(0xFFEF4444);
  @override
  Color get destructiveSurface => const Color(0x1FEF4444);
}
