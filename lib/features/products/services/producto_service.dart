import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:ventro_app/core/network/api_client.dart'; // ajusta este import a tu ruta real
import 'package:ventro_app/features/products/models/producto_variante_imagen_model.dart';
import 'package:ventro_app/features/products/models/variantes_inactivas_page.dart';

import '../models/categoria_model.dart';
import '../models/producto_model.dart';
import '../models/producto_variante_model.dart';

class ProductoService {
  final Dio _dio = ApiClient.instance;

  // --- Categorías ---

  Future<List<CategoriaModel>> getCategorias() async {
    final response = await _dio.get('/categorias');
    final data = _extractList(response.data);
    return data.map((json) => CategoriaModel.fromJson(json)).toList();
  }

  Future<CategoriaModel> createCategoria({
    required String nombre,
    String? descripcion,
    int? parentId,
    String? icono,
    String? color,
  }) async {
    final response = await _dio.post('/categorias', data: {
      'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
      if (parentId != null) 'parent_id': parentId,
      if (icono != null) 'icono': icono,
      if (color != null) 'color': color,
    });
    return CategoriaModel.fromJson(_extractMap(response.data));
  }

  // --- Productos ---
  Future<List<ProductoModel>> getProductos() async {
    final response = await _dio.get('/productos');
    final raw = response.data;
    final list = (raw is Map && raw.containsKey('data'))
        ? (raw['data'] as List).cast<Map<String, dynamic>>()
        : (raw as List).cast<Map<String, dynamic>>();

    // ignore: avoid_print
    if (list.isNotEmpty) ;

    return list.map((json) => ProductoModel.fromJson(json)).toList();
  }

  Future<ProductoVarianteModel> getVariante(int productoId, int varianteId) async {
    final response = await _dio.get('/productos/$productoId/variantes/$varianteId');
    return ProductoVarianteModel.fromJson(_extractMap(response.data));
  }

  Future<ProductoModel> getProducto(int id) async {
    final response = await _dio.get('/productos/$id');
    return ProductoModel.fromJson(_extractMap(response.data));
  }

  /// Crea el producto junto con todas sus variantes (y el inventario inicial
  /// de cada una) en una sola llamada, tal como lo espera el backend.
  Future<ProductoModel> createProducto({
    required String nombre,
    required int categoriaId,
    String? descripcion,
    required bool tieneVariantes,
    required List<ProductoVarianteModel> variantes,
  }) async {
    final payload = {
      'nombre': nombre,
      'categoria_id': categoriaId,
      if (descripcion != null) 'descripcion': descripcion,
      'tiene_variantes': tieneVariantes,
      'variantes': variantes.map((v) => v.toPayloadCompleto()).toList(),
    };

    final response = await _dio.post('/productos', data: payload);
    return ProductoModel.fromJson(_extractMap(response.data));
  }

  Future<ProductoModel> updateProducto(int id, ProductoModel producto) async {
    final response = await _dio.put('/productos/$id', data: producto.toCreateJson());
    return ProductoModel.fromJson(_extractMap(response.data));
  }

  Future<void> deleteProducto(int id) async {
    await _dio.delete('/productos/$id');
  }

  Future<ProductoModel> reactivarProducto(int id) async {
    final response = await _dio.patch('/productos/$id/reactivar');
    return ProductoModel.fromJson(_extractMap(response.data));
  }

  // --- Variantes (flujo de edición, pendiente) ---

  Future<ProductoVarianteModel> createVariante(
    int productoId,
    ProductoVarianteModel variante, {
    required int stock,
  }) async {
    final sucursalId =
        variante.stocksIniciales.isEmpty ? null : variante.stocksIniciales.first.sucursalId;

    final response = await _dio.post(
      '/productos/$productoId/variantes',
      data: variante.toCreateJson(stock: stock),
      options:
          sucursalId != null ? Options(headers: {'X-Sucursal-ID': sucursalId.toString()}) : null,
    );
    return ProductoVarianteModel.fromJson(_extractMap(response.data));
  }

  Future<ProductoVarianteModel> updateVariante(
    int productoId,
    int varianteId,
    ProductoVarianteModel variante,
  ) async {
    final response = await _dio.put(
      '/productos/$productoId/variantes/$varianteId',
      data: variante.toUpdateJson(), // sin stock — el stock se edita aparte, en Inventario
    );
    return ProductoVarianteModel.fromJson(_extractMap(response.data));
  }

  Future<void> deleteVariante(int productoId, int varianteId) async {
    await _dio.delete('/productos/$productoId/variantes/$varianteId');
  }

  // --- Helpers de parsing ---
  // Tu API regresa el JSON plano (sin wrapper "data") en estos endpoints.

  List<Map<String, dynamic>> _extractList(dynamic raw) {
    return (raw as List).cast<Map<String, dynamic>>();
  }

  Map<String, dynamic> _extractMap(dynamic raw) {
    return raw as Map<String, dynamic>;
  }

  Future<ProductoVarianteImagenModel> subirImagenVariante(
    int productoId,
    int varianteId,
    Uint8List bytes,
    String filename, {
    bool isPrimary = true,
  }) async {
    final formData = FormData.fromMap({
      'imagen': MultipartFile.fromBytes(bytes, filename: filename),
      'is_primary': isPrimary ? '1' : '0',
    });
    final response = await _dio.post(
      '/productos/$productoId/variantes/$varianteId/imagenes',
      data: formData,
    );
    return ProductoVarianteImagenModel.fromJson(_extractMap(response.data));
  }

  Future<void> eliminarImagenVariante(int productoId, int varianteId, int imagenId) async {
    await _dio.delete('/productos/$productoId/variantes/$varianteId/imagenes/$imagenId');
  }

  Future<CategoriaModel> updateCategoria(
    int id, {
    required String nombre,
    String? descripcion,
    String? icono,
    String? color,
  }) async {
    final response = await _dio.put('/categorias/$id', data: {
      'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
      if (icono != null) 'icono': icono,
      if (color != null) 'color': color,
    });
    return CategoriaModel.fromJson(_extractMap(response.data));
  }

  Future<void> deleteCategoria(int id) async {
    await _dio.delete('/categorias/$id');
  }

  /// Lista variantes inactivas de todos los productos, paginado.
  /// [page] inicia en 1. [search] filtra por nombre/sku/código de barras
  /// de la variante o por nombre del producto.
  Future<VariantesInactivasPage> getVariantesInactivas({
    int page = 1,
    String? search,
  }) async {
    final response = await _dio.get('/productos/variantes/inactivas', queryParameters: {
      'page': page,
      if (search != null && search.isNotEmpty) 'search': search,
    });
    return VariantesInactivasPage.fromJson(_extractMap(response.data));
  }

  Future<ProductoVarianteModel> reactivarVariante(int productoId, int varianteId) async {
    final response = await _dio.patch(
      '/productos/$productoId/variantes/$varianteId/reactivar',
    );
    return ProductoVarianteModel.fromJson(_extractMap(response.data));
  }
}
