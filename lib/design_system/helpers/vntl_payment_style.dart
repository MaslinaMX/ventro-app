import 'package:flutter/material.dart';

/// Catálogo curado de íconos y colores para métodos de pago.
class VntlPaymentStyle {
  static const Map<String, IconData> iconos = {
    'efectivo': Icons.payments_rounded,
    'tarjeta': Icons.credit_card_rounded,
    'transferencia': Icons.swap_horiz_rounded,
    'banco': Icons.account_balance_rounded,
    'billetera': Icons.account_balance_wallet_rounded,
    'qr': Icons.qr_code_rounded,
    'telefono': Icons.smartphone_rounded,
    'vale': Icons.card_giftcard_rounded,
    'cheque': Icons.receipt_long_rounded,
    'puntos': Icons.stars_rounded,
    'credito_tienda': Icons.storefront_rounded,
    'otro': Icons.more_horiz_rounded,
  };

  static const List<String> colores = [
    '#22C55E',
    '#16A34A',
    '#3B82F6',
    '#2563EB',
    '#6366F1',
    '#4F46E5',
    '#A855F7',
    '#9333EA',
    '#EC4899',
    '#DB2777',
    '#EF4444',
    '#DC2626',
    '#F97316',
    '#EA580C',
    '#F59E0B',
    '#D97706',
    '#EAB308',
    '#84CC16',
    '#14B8A6',
    '#06B6D4',
  ];

  static Color colorFromHex(String hex) {
    return Color(int.parse('FF${hex.replaceFirst('#', '')}', radix: 16));
  }

  /// Resuelve ícono y color final para un método de pago, con fallback
  /// determinístico por id si no tiene icono/color guardado.
  static ({IconData icon, Color background, Color foreground}) forMetodo(
    BuildContext context,
    int id, {
    String? iconoKey,
    String? colorHex,
  }) {
    final icon = iconos[iconoKey] ?? Icons.payments_rounded;
    final hex = colorHex ?? colores[id % colores.length];
    final color = colorFromHex(hex);
    return (icon: icon, background: color.withValues(alpha: 0.15), foreground: color);
  }
}
