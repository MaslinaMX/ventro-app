import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:ventro_app/core/network/api_client.dart';
import 'package:ventro_app/features/settings/models/tenant_model.dart';
import 'package:ventro_app/features/settings/models/sucursal_model.dart';

class SettingsService {
  final Dio _dio = ApiClient.instance;

  // ─── Tenant ────────────────────────────────────────────────────────────────
  Future<TenantModel> getTenant() async {
    final response = await _dio.get('/tenant');
    return TenantModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<TenantModel> updateTenant({
    String? name,
    String? razonSocial,
    String? logo,
  }) async {
    final response = await _dio.patch('/tenant', data: {
      if (name != null) 'name': name,
      if (razonSocial != null) 'razon_social': razonSocial,
      if (logo != null) 'logo': logo,
    });
    return TenantModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<List<SucursalModel>> getSucursales() async {
    final response = await _dio.get('/sucursales');
    final list = response.data as List<dynamic>;
    return list.map((e) => SucursalModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<SucursalModel> updateSucursal(int id, Map<String, dynamic> data) async {
    final response = await _dio.patch('/sucursales/$id', data: data);
    return SucursalModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<SucursalModel> createSucursal(Map<String, dynamic> data) async {
    final response = await _dio.post('/sucursales', data: data);
    return SucursalModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<void> deleteSucursal(int id) async {
    await _dio.delete('/sucursales/$id');
  }

  Future<String> uploadLogo(Uint8List bytes, String fileName) async {
    final formData = FormData.fromMap({
      'logo': MultipartFile.fromBytes(bytes, filename: fileName),
    });
    final response = await _dio.post('/tenant/logo', data: formData);
    return Map<String, dynamic>.from(response.data)['logo'] as String;
  }
}
