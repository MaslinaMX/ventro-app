// ✅ V2

import 'package:dio/dio.dart';
import 'package:ventro_app/core/network/api_client.dart';

class ActivationService {
  final Dio _dio = ApiClient.publicInstance;

  Future<Map<String, String>> validateToken(String token, String tenantId) async {
    final res = await _dio.get(
      '/auth/activate/$token',
      options: Options(headers: {'X-Tenant-ID': tenantId}),
    );
    return {
      'name': res.data['name'] as String,
      'email': res.data['email'] as String,
    };
  }

  Future<void> activate({
    required String token,
    required String password,
    required String tenantId,
  }) async {
    await _dio.post(
      '/auth/activate',
      data: {
        'token': token,
        'password': password,
        'password_confirmation': password,
      },
      options: Options(headers: {'X-Tenant-ID': tenantId}),
    );
  }
}
