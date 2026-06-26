import 'package:dio/dio.dart';
import 'package:ventro_app/core/network/api_client.dart'; // ajusta este import a tu ruta real

import '../models/categoria_gasto_model.dart';

class CategoriaGastoService {
  final Dio _dio = ApiClient.instance;

  Future<List<CategoriaGastoModel>> getCategorias() async {
    final response = await _dio.get('/categorias-gasto');
    final data = _extractList(response.data);
    return data.map((json) => CategoriaGastoModel.fromJson(json)).toList();
  }

  Future<CategoriaGastoModel> createCategoria({
    required String nombre,
    String? icono,
    String? color,
  }) async {
    final response = await _dio.post('/categorias-gasto', data: {
      'nombre': nombre,
      if (icono != null) 'icono': icono,
      if (color != null) 'color': color,
    });
    return CategoriaGastoModel.fromJson(_extractMap(response.data));
  }

  Future<CategoriaGastoModel> updateCategoria(
    int id, {
    required String nombre,
    String? icono,
    String? color,
  }) async {
    final response = await _dio.put('/categorias-gasto/$id', data: {
      'nombre': nombre,
      if (icono != null) 'icono': icono,
      if (color != null) 'color': color,
    });
    return CategoriaGastoModel.fromJson(_extractMap(response.data));
  }

  Future<void> deleteCategoria(int id) async {
    await _dio.delete('/categorias-gasto/$id');
  }

  // --- Helpers de parsing ---
  // La API regresa el JSON plano (sin wrapper "data") en estos endpoints.

  List<Map<String, dynamic>> _extractList(dynamic raw) {
    return (raw as List).cast<Map<String, dynamic>>();
  }

  Map<String, dynamic> _extractMap(dynamic raw) {
    return raw as Map<String, dynamic>;
  }
}
