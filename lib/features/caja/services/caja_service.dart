import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ventro_app/core/network/api_client.dart';
import 'package:ventro_app/features/caja/models/caja_model.dart';

class CajaService {
  final Dio _dio = ApiClient.instance;

  Future<List<CajaModel>> getCajas({int? sucursalId}) async {
    final response = await _dio.get('/cajas', queryParameters: {
      if (sucursalId != null) 'sucursal_id': sucursalId,
    });
    debugPrint('🔍 respuesta /cajas: ${response.data}');
    debugPrint('🔍 tipo: ${response.data.runtimeType}');
    final list = response.data as List<dynamic>;
    return list.map((e) => CajaModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<CajaModel> createCaja(Map<String, dynamic> data) async {
    final response = await _dio.post('/cajas', data: data);
    return CajaModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<CajaModel> updateCaja(int id, Map<String, dynamic> data) async {
    final response = await _dio.patch('/cajas/$id', data: data);
    return CajaModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<void> deleteCaja(int id) async {
    await _dio.delete('/cajas/$id');
  }
}
