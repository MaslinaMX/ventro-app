// lib/features/products/models/producto_variante_imagen_model.dart

class ProductoVarianteImagenModel {
  const ProductoVarianteImagenModel({
    required this.id,
    required this.varianteId,
    required this.path,
    required this.isPrimary,
  });

  final int id;
  final int varianteId;
  final String path;
  final bool isPrimary;

  factory ProductoVarianteImagenModel.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic value, bool fallback) => switch (value) {
          bool b => b,
          int i => i == 1,
          _ => fallback,
        };

    return ProductoVarianteImagenModel(
      id: json['id'] as int,
      varianteId: json['variante_id'] as int,
      path: json['path'] as String,
      isPrimary: parseBool(json['is_primary'], false),
    );
  }
}
