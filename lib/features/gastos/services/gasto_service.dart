import 'package:dio/dio.dart';
import 'package:ventro_app/core/network/api_client.dart'; // ajusta este import a tu ruta real

import '../models/gasto_model.dart';

class GastoService {
  final Dio _dio = ApiClient.instance;

  Future<List<GastoModel>> getGastos({int? sucursalId}) async {
    final response = await _dio.get('/gastos', queryParameters: {
      if (sucursalId != null) 'sucursal_id': sucursalId,
    });
    final data = _extractList(response.data);
    return data.map((json) => GastoModel.fromJson(json)).toList();
  }

  Future<GastoModel> getGasto(int id) async {
    final response = await _dio.get('/gastos/$id');
    return GastoModel.fromJson(_extractMap(response.data));
  }

  Future<GastoModel> createGasto(GastoModel gasto) async {
    final response = await _dio.post('/gastos', data: gasto.toCreateJson());
    return GastoModel.fromJson(_extractMap(response.data));
  }

  /// Edita un gasto existente. El motivo es obligatorio — el backend
  /// rechaza la edición sin él (422) y solo admin_empresa/admin_sucursal
  /// pueden llamar esto (403 para los demás roles).
  Future<GastoModel> updateGasto(
    int id,
    GastoModel gasto, {
    required String motivo,
  }) async {
    final payload = gasto.toCreateJson()..['motivo'] = motivo;
    final response = await _dio.put('/gastos/$id', data: payload);
    return GastoModel.fromJson(_extractMap(response.data));
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
