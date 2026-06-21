class VarianteStockInicial {
  const VarianteStockInicial({
    required this.sucursalId,
    this.sucursalNombre = '',
    this.cantidad = 0,
    this.cantidadMinima = 0,
  });

  final int sucursalId;
  final String sucursalNombre;
  final int cantidad;
  final int cantidadMinima;

  factory VarianteStockInicial.fromJson(Map<String, dynamic> json) {
    return VarianteStockInicial(
      sucursalId: json['sucursal_id'] as int,
      cantidad: json['cantidad'] as int,
      cantidadMinima: json['cantidad_minima'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sucursal_id': sucursalId,
      'cantidad': cantidad,
      'cantidad_minima': cantidadMinima,
    };
  }
}
