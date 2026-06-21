import 'package:dio/dio.dart';
import 'package:ventro_app/core/config/env.dart';
import 'package:ventro_app/core/storage/secure_storage.dart';

enum TenantBlockReason { blocked, cancelled, trialExpired, none }

class ApiClient {
  static final Dio _instance = _createInstance();
  static final Dio _publicInstance = _createPublicInstance();

  static Dio get instance => _instance;
  static Dio get publicInstance => _publicInstance;

  // Callback global para manejar bloqueos — se setea desde main.dart
  static void Function(TenantBlockReason reason, String message)? onTenantBlocked;

  static Dio _createInstance() {
    final dio = Dio(BaseOptions(
      baseUrl: Env.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await SecureStorage.getToken();
        final tenantId = await SecureStorage.getTenantId();
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        if (tenantId != null) options.headers['X-Tenant-ID'] = tenantId;
        return handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 403) {
          final data = error.response?.data;
          if (data is Map) {
            final code = data['code'] as String?;
            final message = data['message'] as String? ?? 'Acceso restringido';
            final reason = switch (code) {
              'ACCOUNT_BLOCKED' => TenantBlockReason.blocked,
              'ACCOUNT_CANCELLED' => TenantBlockReason.cancelled,
              'TRIAL_EXPIRED' => TenantBlockReason.trialExpired,
              _ => TenantBlockReason.none,
            };
            if (reason != TenantBlockReason.none) {
              onTenantBlocked?.call(reason, message);
            }
          }
        }
        return handler.next(error);
      },
    ));

    return dio;
  }

  static Dio _createPublicInstance() {
    return Dio(BaseOptions(
      baseUrl: Env.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
  }

  static Dio instanceForTenant(String tenantId) {
    final dio = Dio(BaseOptions(
      baseUrl: Env.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Tenant-ID': tenantId,
      },
    ));
    return dio;
  }
}
