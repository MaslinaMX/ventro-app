import 'package:flutter/material.dart';
import 'vntl_color_scheme.dart';

class VntlColorsLight implements VntlColorScheme {
  const VntlColorsLight();

  @override
  Color get background => const Color(0xFFF5F5F5);
  @override
  Color get surface => const Color(0xFFFFFFFF);
  @override
  Color get surfaceSecondary => const Color(0xFFF0F0F0);
  @override
  Color get surfaceTertiary => const Color(0xFFE8E8E8);

  @override
  Color get glassSurface => const Color(0x0D000000);
  @override
  Color get glassBorder => const Color(0x14000000);
  @override
  Color get glassHighlight => const Color(0x1F000000);

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
  Color get success => const Color(0xFF16A34A);
  @override
  Color get successSurface => const Color(0x1516A34A);
  @override
  Color get warning => const Color(0xFFD97706);
  @override
  Color get warningSurface => const Color(0x15D97706);
  @override
  Color get error => const Color(0xFFDC2626);
  @override
  Color get errorSurface => const Color(0x15DC2626);
  @override
  Color get info => const Color(0xFF2563EB);
  @override
  Color get infoSurface => const Color(0x152563EB);

  @override
  Color get textPrimary => const Color(0xFF111111);
  @override
  Color get textSecondary => const Color(0xFF555555);
  @override
  Color get textTertiary => const Color(0xFF888888);
  @override
  Color get textDisabled => const Color(0xFFBBBBBB);

  @override
  Color get border => const Color(0xFFE0E0E0);
  @override
  Color get borderStrong => const Color(0xFFCCCCCC);

  @override
  LinearGradient get backgroundGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF5F5F5), Color(0xFFEFEFEF)],
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
  Color get navVentas => const Color(0xFF16A34A);
  @override
  Color get navProductos => const Color(0xFF2563EB);
  @override
  Color get navCategorias => const Color(0xFFD97706);
  @override
  Color get navClientes => const Color(0xFFDC2626);
  @override
  Color get navReportes => const Color(0xFF7C6AF7);
  @override
  Color get navVentasSurface => const Color(0x1F16A34A);
  @override
  Color get navProductosSurface => const Color(0x1F2563EB);
  @override
  Color get navCategoriasSurface => const Color(0x1FD97706);
  @override
  Color get navClientesSurface => const Color(0x1FDC2626);
  @override
  Color get navReportesSurface => const Color(0x1F7C6AF7);

  @override
  Color get destructive => const Color(0xFFDC2626);
  @override
  Color get destructiveSurface => const Color(0x1FDC2626);
}
