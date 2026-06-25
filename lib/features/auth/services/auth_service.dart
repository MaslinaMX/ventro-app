import 'package:dio/dio.dart';
import 'package:ventro_app/core/network/api_client.dart';
import 'package:ventro_app/features/auth/models/user_model.dart';

class AuthService {
  // Login necesita su propia instancia sin interceptor de token
  final Dio _dio = ApiClient.instance;
  final Dio _publicDio = ApiClient.publicInstance;

  // POST /api/auth/register
  Future<AuthResponse> register({
    required String empresa,
    required String slug,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _publicDio.post('/auth/register', data: {
      'empresa': empresa,
      'slug': slug,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
    return AuthResponse.fromJson(response.data);
  }

  // POST /api/auth/lookup
  Future<Map<String, dynamic>> lookup(String email) async {
    final response = await _publicDio.post('/auth/lookup', data: {'email': email});
    return response.data;
  }

  // POST /api/auth/login
  Future<AuthResponse> login({
    required String email,
    required String password,
    required String tenantId,
  }) async {
    final response = await _publicDio.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
      options: Options(headers: {
        'X-Tenant-ID': tenantId,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }),
    );
    return AuthResponse.fromJson(response.data);
  }

  // GET /api/auth/me
  Future<UserModel> me() async {
    final response = await _dio.get('/auth/me');
    return UserModel.fromJson(response.data);
  }

  // PATCH /api/auth/me — onboarding
  Future<UserModel> completeOnboarding({
    required String firstName,
    required String lastName,
    required String phone,
    required String securityPin,
    String? employeeNumber,
  }) async {
    final response = await _dio.patch('/auth/me', data: {
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'security_pin': securityPin,
      if (employeeNumber != null) 'employee_number': employeeNumber,
    });
    return UserModel.fromJson(response.data['user']);
  }

  // POST /api/auth/logout
  Future<void> logout() async {
    await _dio.post('/auth/logout');
  }

  Future<UserModel> getMe() async {
    final response = await _dio.get('/auth/me');
    return UserModel.fromJson(response.data['user'] ?? response.data);
  }
}
