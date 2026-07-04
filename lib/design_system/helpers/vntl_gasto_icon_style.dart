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

    // --- Ampliación: catálogo sugerido de categorías de gasto ---

    // Insumos y compras operativas (ampliación)
    'insumos': Icons.shopping_basket_rounded,
    'materia_prima': Icons.archive_rounded,
    'inventario_almacen': Icons.warehouse_rounded,
    'papeleria': Icons.description_rounded,
    'empaque': Icons.all_inbox_rounded,
    'limpieza': Icons.cleaning_services_rounded,
    'herramientas': Icons.build_rounded,
    'uniformes': Icons.checkroom_rounded,

    // Nómina y personal (ampliación)
    'honorarios': Icons.person_rounded,
    'comisiones': Icons.percent_rounded,
    'prestaciones': Icons.card_giftcard_rounded,
    'capacitacion': Icons.school_rounded,
    'viaticos': Icons.luggage_rounded,

    // Instalaciones (ampliación)
    'remodelaciones': Icons.format_paint_rounded,
    'seguridad_instalaciones': Icons.security_rounded,
    'jardineria': Icons.grass_rounded,

    // Servicios (ampliación)
    'hosting': Icons.dns_rounded,
    'software_licencias': Icons.vpn_key_rounded,
    'nube': Icons.cloud_rounded,

    // Transporte (ampliación)
    'peajes': Icons.toll_rounded,
    'mensajeria': Icons.send_rounded,
    'fletes': Icons.local_shipping_rounded,

    // Marketing y ventas (ampliación)
    'redes_sociales': Icons.tag_rounded,
    'diseno_grafico': Icons.palette_rounded,
    'fotografia_video': Icons.camera_alt_rounded,
    'eventos': Icons.event_rounded,
    'material_promocional': Icons.local_offer_rounded,

    // Tecnología
    'equipo_computo': Icons.laptop_rounded,
    'accesorios_tech': Icons.mouse_rounded,
    'refacciones': Icons.settings_rounded,
    'reparaciones_tech': Icons.build_circle_rounded,
    'desarrollo_software': Icons.code_rounded,

    // Administración
    'contabilidad': Icons.calculate_rounded,
    'asesoria_legal': Icons.balance_rounded,
    'tramites_gubernamentales': Icons.account_balance_rounded,
    'comisiones_bancarias': Icons.account_balance_wallet_rounded,
    'seguros': Icons.verified_user_rounded,

    // Finanzas
    'pago_creditos': Icons.credit_card_rounded,
    'intereses': Icons.percent_rounded,
    'comisiones_financieras': Icons.monetization_on_rounded,
    'diferencias_cambiarias': Icons.currency_exchange_rounded,

    // Alimentación
    'comidas': Icons.restaurant_rounded,
    'cafe': Icons.coffee_rounded,
    'agua_botella': Icons.local_drink_rounded,
    'snacks': Icons.fastfood_rounded,

    // Producción
    'maquinaria': Icons.precision_manufacturing_rounded,
    'mantenimiento_maquinaria': Icons.build_rounded,
    'consumibles': Icons.inventory_2_rounded,

    // Gastos extraordinarios
    'multas': Icons.report_problem_rounded,
    'donaciones': Icons.favorite_rounded,
    'perdidas': Icons.trending_down_rounded,
    'gastos_imprevistos': Icons.priority_high_rounded,
    'emergencias': Icons.emergency_rounded,

    // Otros
    'caja_chica': Icons.savings_rounded,
    'reembolsos': Icons.replay_rounded,
    'diversos': Icons.more_horiz_rounded,
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

    // --- Ampliación ---
    'insumos': ['insumos', 'cesta', 'canasta'],
    'materia_prima': ['materia prima', 'caja', 'paquete'],
    'inventario_almacen': ['inventario', 'almacén', 'estantes'],
    'papeleria': ['papelería', 'hoja', 'oficina'],
    'empaque': ['empaque', 'embalaje', 'caja abierta'],
    'limpieza': ['limpieza', 'aseo', 'gota de agua'],
    'herramientas': ['herramientas', 'llave inglesa'],
    'uniformes': ['uniformes', 'playera', 'camisa', 'ropa de trabajo'],

    'honorarios': ['honorarios', 'freelance', 'pago a persona'],
    'comisiones': ['comisiones', 'porcentaje', 'venta'],
    'prestaciones': ['prestaciones', 'beneficio', 'regalo'],
    'capacitacion': ['capacitación', 'curso', 'entrenamiento'],
    'viaticos': ['viáticos', 'viaje', 'maleta'],

    'remodelaciones': ['remodelación', 'pintura', 'obra'],
    'seguridad_instalaciones': ['seguridad', 'alarma', 'cámaras'],
    'jardineria': ['jardinería', 'jardín', 'plantas'],

    'hosting': ['hosting', 'dominio', 'servidor'],
    'software_licencias': ['software', 'licencia', 'llave de acceso'],
    'nube': ['nube', 'cloud', 'almacenamiento'],

    'peajes': ['peaje', 'caseta', 'carretera'],
    'mensajeria': ['mensajería', 'paquete', 'envío rápido'],
    'fletes': ['flete', 'camión', 'carga'],

    'redes_sociales': ['redes sociales', 'hashtag', 'instagram', 'facebook'],
    'diseno_grafico': ['diseño gráfico', 'paleta', 'branding'],
    'fotografia_video': ['fotografía', 'video', 'cámara'],
    'eventos': ['eventos', 'calendario', 'expo'],
    'material_promocional': ['material promocional', 'etiqueta', 'volante'],

    'equipo_computo': ['equipo de cómputo', 'laptop', 'computadora'],
    'accesorios_tech': ['accesorios', 'mouse', 'teclado'],
    'refacciones': ['refacciones', 'engranaje', 'partes'],
    'reparaciones_tech': ['reparaciones', 'herramientas cruzadas'],
    'desarrollo_software': ['desarrollo de software', 'código', 'programación'],

    'contabilidad': ['contabilidad', 'calculadora'],
    'asesoria_legal': ['asesoría legal', 'balanza', 'abogado'],
    'tramites_gubernamentales': ['trámites gubernamentales', 'gobierno', 'permiso'],
    'comisiones_bancarias': ['comisiones bancarias', 'banco'],
    'seguros': ['seguros', 'póliza', 'escudo'],

    'pago_creditos': ['pago de créditos', 'tarjeta', 'crédito'],
    'intereses': ['intereses', 'porcentaje', 'financiamiento'],
    'comisiones_financieras': ['comisiones financieras', 'moneda'],
    'diferencias_cambiarias': ['diferencias cambiarias', 'tipo de cambio', 'divisas'],

    'comidas': ['comidas', 'cubiertos', 'alimentos'],
    'cafe': ['café', 'taza'],
    'agua_botella': ['agua', 'botella'],
    'snacks': ['snacks', 'bolsa', 'botana'],

    'maquinaria': ['maquinaria', 'fábrica', 'máquina'],
    'mantenimiento_maquinaria': ['mantenimiento de maquinaria', 'llave inglesa'],
    'consumibles': ['consumibles', 'caja pequeña'],

    'multas': ['multas', 'alerta', 'infracción'],
    'donaciones': ['donaciones', 'corazón', 'caridad'],
    'perdidas': ['pérdidas', 'flecha hacia abajo'],
    'gastos_imprevistos': ['gastos imprevistos', 'signo de exclamación', 'urgente'],
    'emergencias': ['emergencias', 'luz de alerta'],

    'caja_chica': ['caja chica', 'monedero'],
    'reembolsos': ['reembolsos', 'flecha de regreso', 'devolución'],
    'diversos': ['diversos', 'tres puntos', 'varios'],
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
