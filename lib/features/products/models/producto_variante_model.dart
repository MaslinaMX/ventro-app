import 'package:ventro_app/features/products/models/producto_variante_imagen_model.dart';
import 'package:ventro_app/features/products/models/variante_stock_inicial.dart';

class ProductoVarianteModel {
  final int id;
  final int productoId;
  final String nombre;
  final String? sku;
  final String? codigoBarras;
  final double precio;
  final double? precioComparacion;
  final double? costoNeto;
  final double iva;
  final double ieps;
  final bool impuestosIncluidos;
  final bool isDefault;
  final bool allowOnline;
  final bool allowOutOfStock;
  final String? satKey;
  final List<ProductoVarianteImagenModel> imagenes;
  final bool activo;
  final List<VarianteStockInicial> stocksIniciales;

  const ProductoVarianteModel({
    required this.id,
    required this.productoId,
    required this.nombre,
    this.sku,
    this.codigoBarras,
    required this.precio,
    this.precioComparacion,
    this.costoNeto,
    this.iva = 16,
    this.ieps = 0,
    this.impuestosIncluidos = true,
    this.isDefault = false,
    this.allowOnline = false,
    this.allowOutOfStock = false,
    this.satKey,
    this.imagenes = const [],
    this.activo = true,
    this.stocksIniciales = const [],
  });

  ProductoVarianteImagenModel? get imagenPrincipal {
    if (imagenes.isEmpty) return null;
    return imagenes.firstWhere((i) => i.isPrimary, orElse: () => imagenes.first);
  }

  factory ProductoVarianteModel.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic value, bool fallback) => switch (value) {
          bool b => b,
          int i => i == 1,
          _ => fallback,
        };

    return ProductoVarianteModel(
      id: json['id'] as int,
      productoId: json['producto_id'] as int,
      nombre: json['nombre'] as String,
      sku: json['sku'] as String?,
      codigoBarras: json['codigo_barras'] as String?,
      precio: double.parse(json['precio'].toString()),
      precioComparacion: json['precio_comparacion'] != null
          ? double.parse(json['precio_comparacion'].toString())
          : null,
      costoNeto: json['cost_net'] != null ? double.parse(json['cost_net'].toString()) : null,
      iva: double.parse((json['iva'] ?? 16).toString()),
      ieps: double.parse((json['ieps'] ?? 0).toString()),
      impuestosIncluidos: parseBool(json['impuestos_incluidos'], true),
      isDefault: parseBool(json['is_default'], false),
      allowOnline: parseBool(json['allow_online'], false),
      allowOutOfStock: parseBool(json['allow_out_of_stock'], false),
      satKey: json['sat_key'] as String?,
      imagenes: (json['imagenes'] as List<dynamic>? ?? [])
          .map((i) => ProductoVarianteImagenModel.fromJson(i as Map<String, dynamic>))
          .toList(),
      activo: parseBool(json['activo'], true),
      stocksIniciales: (json['stock'] as List<dynamic>? ?? [])
          .map((s) => VarianteStockInicial.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Precio que paga el cliente (con impuestos), sin importar si el precio
  /// capturado ya los incluía o no. Úsalo siempre para mostrar precio al público.
  double get precioFinal {
    if (impuestosIncluidos) return precio;
    return precio * (1 + (iva + ieps) / 100);
  }

  /// Precio base sin impuestos, para costeo y reportes internos.
  double get precioBase {
    if (!impuestosIncluidos) return precio;
    final factor = 1 + (iva + ieps) / 100;
    return factor == 0 ? precio : precio / factor;
  }

  /// Payload completo que espera POST /productos al crear el producto entero,
  /// incluyendo el inventario inicial por sucursal.
  Map<String, dynamic> toPayloadCompleto() {
    return {
      'nombre': nombre,
      if (sku != null && sku!.isNotEmpty) 'sku': sku,
      if (codigoBarras != null && codigoBarras!.isNotEmpty) 'codigo_barras': codigoBarras,
      'precio': precio,
      if (costoNeto != null) 'cost_net': costoNeto,
      'iva': iva,
      'ieps': ieps,
      'impuestos_incluidos': impuestosIncluidos,
      'is_default': isDefault,
      'allow_online': allowOnline,
      'allow_out_of_stock': allowOutOfStock,
      if (satKey != null && satKey!.isNotEmpty) 'sat_key': satKey,
      'stocks': stocksIniciales.map((s) => s.toJson()).toList(),
    };
  }

  /// Payload para actualizar los datos generales de una variante existente
  /// (PUT /productos/{id}/variantes/{varianteId}). No incluye stock: ese
  /// campo se gestiona desde la sección de Inventario, no desde este form.
  Map<String, dynamic> toUpdateJson() {
    return {
      'nombre': nombre,
      if (sku != null && sku!.isNotEmpty) 'sku': sku,
      if (codigoBarras != null && codigoBarras!.isNotEmpty) 'codigo_barras': codigoBarras,
      'precio': precio,
      if (costoNeto != null) 'cost_net': costoNeto,
      'iva': iva,
      'ieps': ieps,
      'impuestos_incluidos': impuestosIncluidos,
      'is_default': isDefault,
      'allow_online': allowOnline,
      'allow_out_of_stock': allowOutOfStock,
      if (satKey != null && satKey!.isNotEmpty) 'sat_key': satKey,
    };
  }

  /// Payload para actualizar una variante ya existente (flujo de edición,
  /// pendiente de construir).
  Map<String, dynamic> toCreateJson({required int stock, int? cantidadMinima}) {
    return {
      'nombre': nombre,
      if (sku != null && sku!.isNotEmpty) 'sku': sku,
      if (codigoBarras != null && codigoBarras!.isNotEmpty) 'codigo_barras': codigoBarras,
      'precio': precio,
      if (costoNeto != null) 'cost_net': costoNeto,
      'iva': iva,
      'ieps': ieps,
      'impuestos_incluidos': impuestosIncluidos,
      'is_default': isDefault,
      'allow_online': allowOnline,
      'allow_out_of_stock': allowOutOfStock,
      if (satKey != null && satKey!.isNotEmpty) 'sat_key': satKey,
      'stock': stock,
      if (cantidadMinima != null) 'cantidad_minima': cantidadMinima,
    };
  }

  /// Payload de la variante única que se crea cuando el producto NO tiene
  /// variantes (tiene_variantes = false). Usa [nombreProducto] como nombre
  /// de la variante y fuerza isDefault: true.
  static Map<String, dynamic> payloadVarianteUnica({
    required String nombreProducto,
    required double precio,
    double? costoNeto,
    String? sku,
    String? codigoBarras,
    double iva = 16,
    double ieps = 0,
    bool impuestosIncluidos = true,
    bool allowOnline = false,
    bool allowOutOfStock = false,
    String? satKey,
    required List<VarianteStockInicial> stocks,
  }) {
    return {
      'nombre': nombreProducto,
      if (sku != null && sku.isNotEmpty) 'sku': sku,
      if (codigoBarras != null && codigoBarras.isNotEmpty) 'codigo_barras': codigoBarras,
      'precio': precio,
      if (costoNeto != null) 'cost_net': costoNeto,
      'iva': iva,
      'ieps': ieps,
      'impuestos_incluidos': impuestosIncluidos,
      'is_default': true,
      'allow_online': allowOnline,
      'allow_out_of_stock': allowOutOfStock,
      if (satKey != null && satKey.isNotEmpty) 'sat_key': satKey,
      'stocks': stocks.map((s) => s.toJson()).toList(),
    };
  }
}
