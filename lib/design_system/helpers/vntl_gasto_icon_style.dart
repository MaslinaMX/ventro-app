// lib/design_system/helpers/vntl_gasto_icon_style.dart

import 'package:flutter/material.dart';
import 'package:ventro_app/design_system/vntl.dart';

/// Estilo visual (ícono + color) para tipos de gasto.
///
/// Catálogo separado de VntlCategoryStyle porque ese está pensado para
/// categorías de producto (panadería/repostería) y no aplica a conceptos
/// de negocio como nómina, renta o servicios.
class VntlGastoIconStyle {
  const VntlGastoIconStyle({
    required this.background,
    required this.foreground,
    required this.icon,
  });

  final Color background;
  final Color foreground;
  final IconData icon;

  /// Catálogo curado de íconos para tipos de gasto.
  /// La clave (string) es lo que se guarda en BD y NUNCA debe cambiar,
  /// aunque se reordene o amplíe la lista — los tipos de gasto ya
  /// guardados dependen de que su clave siga existiendo.
  static const Map<String, IconData> iconos = {
    // Nómina y personal
    'payroll': Icons.payments_rounded,
    'people': Icons.groups_rounded,
    'badge': Icons.badge_rounded,
    'handshake': Icons.handshake_rounded,
    // Renta e instalaciones
    'rent': Icons.real_estate_agent_rounded,
    'building': Icons.apartment_rounded,
    'key': Icons.key_rounded,
    // Servicios (luz, agua, internet)
    'electricity': Icons.bolt_rounded,
    'water_bill': Icons.water_drop_rounded,
    'internet': Icons.wifi_rounded,
    'phone_bill': Icons.phone_rounded,
    'gas': Icons.local_fire_department_rounded,
    // Insumos y compras operativas
    'supplies': Icons.inventory_2_rounded,
    'ingredients': Icons.shopping_basket_rounded,
    'delivery': Icons.local_shipping_rounded,
    'cart_gasto': Icons.shopping_cart_rounded,
    // Mantenimiento y equipo
    'maintenance': Icons.handyman_rounded,
    'cleaning_gasto': Icons.cleaning_services_rounded,
    'equipment': Icons.precision_manufacturing_rounded,
    'repair': Icons.build_rounded,
    // Impuestos y trámites
    'taxes': Icons.account_balance_rounded,
    'document': Icons.description_rounded,
    'gavel': Icons.gavel_rounded,
    // Transporte
    'fuel': Icons.local_gas_station_rounded,
    'car': Icons.directions_car_rounded,
    'parking': Icons.local_parking_rounded,
    // Marketing y administración
    'marketing': Icons.campaign_rounded,
    'subscription': Icons.subscriptions_rounded,
    'insurance': Icons.security_rounded,
    'bank': Icons.account_balance_wallet_rounded,
    'receipt_gasto': Icons.receipt_long_rounded,
    // Genéricos
    'tag_gasto': Icons.label_rounded,
    'warning_gasto': Icons.warning_amber_rounded,
    'circle_gasto': Icons.circle_rounded,
    'star_gasto': Icons.star_rounded,
  };

  /// Tags en español por clave, usados para la búsqueda.
  static const Map<String, List<String>> _tags = {
    'payroll': ['nómina', 'sueldo', 'pago empleados'],
    'people': ['personal', 'empleados', 'equipo'],
    'badge': ['empleado', 'identificación', 'gafete'],
    'handshake': ['acuerdo', 'contrato', 'proveedor'],
    'rent': ['renta', 'alquiler', 'arrendamiento'],
    'building': ['local', 'edificio', 'sucursal'],
    'key': ['llave', 'acceso', 'local'],
    'electricity': ['luz', 'electricidad', 'cfe'],
    'water_bill': ['agua', 'recibo de agua'],
    'internet': ['internet', 'wifi', 'telecom'],
    'phone_bill': ['teléfono', 'celular', 'línea'],
    'gas': ['gas', 'estufa', 'tanque'],
    'supplies': ['insumos', 'materiales', 'inventario'],
    'ingredients': ['ingredientes', 'materia prima', 'compras'],
    'delivery': ['envío', 'flete', 'paquetería'],
    'cart_gasto': ['compra', 'carrito', 'pedido'],
    'maintenance': ['mantenimiento', 'reparación', 'servicio técnico'],
    'cleaning_gasto': ['limpieza', 'aseo'],
    'equipment': ['equipo', 'maquinaria', 'herramienta'],
    'repair': ['reparación', 'arreglo', 'compostura'],
    'taxes': ['impuestos', 'sat', 'declaración'],
    'document': ['trámite', 'documento', 'permiso'],
    'gavel': ['legal', 'abogado', 'multa'],
    'fuel': ['gasolina', 'combustible'],
    'car': ['vehículo', 'auto', 'transporte'],
    'parking': ['estacionamiento', 'parking'],
    'marketing': ['publicidad', 'marketing', 'promoción'],
    'subscription': ['suscripción', 'software', 'licencia'],
    'insurance': ['seguro', 'póliza'],
    'bank': ['banco', 'comisión', 'financiero'],
    'receipt_gasto': ['recibo', 'ticket', 'factura'],
    'tag_gasto': ['etiqueta', 'genérico', 'otros'],
    'warning_gasto': ['urgente', 'imprevisto', 'emergencia'],
    'circle_gasto': ['círculo', 'punto'],
    'star_gasto': ['destacado', 'importante'],
  };

  /// Busca íconos cuya clave o tags coincidan parcialmente con [query].
  /// Si [query] está vacío, regresa el catálogo completo en orden.
  static List<MapEntry<String, IconData>> buscar(String query) {
    final entries = iconos.entries.toList();
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return entries;

    return entries.where((e) {
      if (e.key.toLowerCase().contains(q)) return true;
      final tags = _tags[e.key] ?? const [];
      return tags.any((t) => t.toLowerCase().contains(q));
    }).toList();
  }

  /// Reusa la misma paleta de colores que VntlCategoryStyle — esa paleta
  /// es genérica (no tiene nada de panadería) y conviene mantener una
  /// sola fuente de verdad para los colores seleccionables en toda la app.
  static List<String> get colores => VntlCategoryStyle.colores;

  static Color _hexToColor(String hex) {
    final clean = hex.replaceFirst('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }

  static VntlGastoIconStyle forCategoria(
    BuildContext context,
    int? categoriaId, {
    String? iconoKey,
    String? colorHex,
  }) {
    final colors = context.colors;

    if (categoriaId == null) {
      return VntlGastoIconStyle(
        background: colors.primarySurface,
        foreground: colors.primary,
        icon: Icons.receipt_long_rounded,
      );
    }

    if (iconoKey != null && colorHex != null && iconos.containsKey(iconoKey)) {
      final base = _hexToColor(colorHex);
      return VntlGastoIconStyle(
        background: base.withValues(alpha: 0.18),
        foreground: base,
        icon: iconos[iconoKey]!,
      );
    }

    final paleta = <(Color, Color)>[
      (colors.primarySurface, colors.primary),
      (colors.accentSurface, colors.accent),
      (colors.successSurface, colors.success),
      (colors.warningSurface, colors.warning),
      (colors.infoSurface, colors.info),
      (colors.errorSurface, colors.error),
    ];
    final iconosFallback = iconos.values.toList();

    final index = categoriaId % paleta.length;
    final iconoIndex = categoriaId % iconosFallback.length;
    final (bg, fg) = paleta[index];

    return VntlGastoIconStyle(background: bg, foreground: fg, icon: iconosFallback[iconoIndex]);
  }
}
