import 'categoria_model.dart';
import 'producto_variante_model.dart';

class ProductoModel {
  final int id;
  final int categoriaId;
  final String nombre;
  final String? descripcion;
  final bool activo;
  final bool tieneVariantes;
  final CategoriaModel? categoria;
  final List<ProductoVarianteModel> variantes;

  const ProductoModel({
    required this.id,
    required this.categoriaId,
    required this.nombre,
    this.descripcion,
    this.activo = true,
    this.tieneVariantes = true,
    this.categoria,
    this.variantes = const [],
  });

  factory ProductoModel.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic value, bool fallback) => switch (value) {
          bool b => b,
          int i => i == 1,
          _ => fallback,
        };

    return ProductoModel(
      id: json['id'] as int,
      categoriaId: json['categoria_id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      activo: parseBool(json['activo'], true),
      tieneVariantes: parseBool(json['tiene_variantes'], true),
      categoria: json['categoria'] != null
          ? CategoriaModel.fromJson(json['categoria'] as Map<String, dynamic>)
          : null,
      variantes: (json['variantes'] as List<dynamic>? ?? [])
          .map((v) => ProductoVarianteModel.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'categoria_id': categoriaId,
      'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
      'tiene_variantes': tieneVariantes,
      'activo': activo,
    };
  }

  bool get tieneMultiplesVariantes => variantes.length > 1;

  double? get precioDesde {
    if (variantes.isEmpty) return null;
    return variantes.map((v) => v.precioFinal).reduce((a, b) => a < b ? a : b);
  }
}
