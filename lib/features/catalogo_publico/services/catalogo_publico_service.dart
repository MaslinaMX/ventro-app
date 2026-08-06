// V1

import 'package:dio/dio.dart';
import 'package:ventro_app/core/config/env.dart';
import 'package:ventro_app/features/catalogo_publico/models/negocio_publico_model.dart';
import 'package:ventro_app/features/products/models/producto_model.dart';

/// Service del catálogo público. A diferencia de ProductoService (autenticado,
/// usa X-Sucursal-ID y sesión), este habla con /api/catalogo mandando el
/// slug del tenant explícito en el header X-Tenant-Slug — sin auth, sin sesión.
/// No usa ApiClient.instanceForTenant() porque ese método manda X-Tenant-ID
/// (el id interno del tenant), y aquí solo contamos con el slug público.
class CatalogoPublicoService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: Env.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  Future<List<ProductoModel>> getProductos(String slug, {String? search, int? categoriaId}) async {
    final response = await _dio.get(
      '/catalogo',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (categoriaId != null) 'categoria_id': categoriaId,
      },
      options: Options(headers: {'X-Tenant-Slug': slug}),
    );

    final data = response.data['data'] as List<dynamic>;
    return data.map((json) => ProductoModel.fromJson(json)).toList();
  }

  Future<NegocioPublicoModel> getNegocio(String slug) async {
    final response = await _dio.get(
      '/catalogo/negocio',
      options: Options(headers: {'X-Tenant-Slug': slug}),
    );

    return NegocioPublicoModel.fromJson(response.data as Map<String, dynamic>);
  }
}
