import 'package:ventro_app/features/products/models/producto_variante_model.dart';

/// Una variante inactiva junto con el nombre de su producto padre y la
/// fecha aproximada de desactivación (updated_at del backend).
class VarianteInactiva {
  final ProductoVarianteModel variante;
  final String productoNombre;
  final DateTime? desactivadaEn;

  const VarianteInactiva({
    required this.variante,
    required this.productoNombre,
    this.desactivadaEn,
  });

  factory VarianteInactiva.fromJson(Map<String, dynamic> json) {
    return VarianteInactiva(
      variante: ProductoVarianteModel.fromJson(json),
      productoNombre: (json['producto'] as Map<String, dynamic>?)?['nombre'] as String? ?? '',
      desactivadaEn:
          json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
    );
  }
}

/// Página de resultados del endpoint GET /productos/variantes/inactivas,
/// que regresa la paginación estándar de Laravel (data, current_page, etc.)
class VariantesInactivasPage {
  final List<VarianteInactiva> items;
  final int currentPage;
  final int lastPage;
  final int total;

  const VariantesInactivasPage({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  bool get hasMore => currentPage < lastPage;

  factory VariantesInactivasPage.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as List<dynamic>? ?? [])
        .map((j) => VarianteInactiva.fromJson(j as Map<String, dynamic>))
        .toList();

    return VariantesInactivasPage(
      items: data,
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      total: json['total'] as int? ?? data.length,
    );
  }
}
