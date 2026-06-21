class InventarioStockModel {
  final int varianteId;
  final String varianteNombre;
  final String? sku;
  final String? codigoBarras;
  final String? imagen;
  final int productoId;
  final String productoNombre;
  final double cantidad;
  final double cantidadMinima;
  final bool bajoStock;

  const InventarioStockModel({
    required this.varianteId,
    required this.varianteNombre,
    this.sku,
    this.codigoBarras,
    this.imagen,
    required this.productoId,
    required this.productoNombre,
    required this.cantidad,
    required this.cantidadMinima,
    required this.bajoStock,
  });

  /// Label para mostrar en listas/dropdowns, ej: "20 Pieza"
  String get label => varianteNombre;

  factory InventarioStockModel.fromJson(Map<String, dynamic> j) {
    return InventarioStockModel(
      varianteId: j['variante_id'],
      varianteNombre: j['variante_nombre'] ?? '',
      sku: j['sku'],
      codigoBarras: j['codigo_barras'],
      imagen: j['imagen'],
      productoId: j['producto_id'],
      productoNombre: j['producto_nombre'] ?? '',
      cantidad: double.tryParse('${j['cantidad'] ?? 0}') ?? 0,
      cantidadMinima: double.tryParse('${j['cantidad_minima'] ?? 0}') ?? 0,
      bajoStock: j['bajo_stock'] ?? false,
    );
  }
}
