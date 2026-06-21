import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:ventro_app/core/storage/secure_storage.dart';
import 'package:ventro_app/features/auth/models/auth_model.dart';
import 'package:ventro_app/features/auth/services/auth_service.dart';

enum AuthStatus { idle, loading, success, error }

class AuthController extends ChangeNotifier {
  final AuthService _service = AuthService();

  AuthStatus _status = AuthStatus.idle;
  UserModel? _user;
  String? _errorMessage;
  String? _tenantId;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  String? get tenantId => _tenantId;
  bool get isLoading => _status == AuthStatus.loading;

  AuthController() {
    _loadSessionOnInit();
  }

  Future<void> _loadSessionOnInit() async {
    final token = await SecureStorage.getToken();
    if (token == null) return;
    try {
      final user = await _service.getMe();
      _user = user;
      _tenantId = await SecureStorage.getTenantId();
      notifyListeners();
    } catch (_) {
      await SecureStorage.clear();
    }
  }

  // ─── Register ────────────────────────────────────────────────────────────────
  Future<bool> register({
    required String empresa,
    required String slug,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    _setLoading();
    try {
      final response = await _service.register(
        empresa: empresa,
        slug: slug,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      await SecureStorage.saveSession(
        token: response.token,
        tenantId: response.tenantId,
        onboardingComplete: false,
      );

      _user = response.user;
      _tenantId = response.tenantId;
      _setSuccess();
      return true;
    } on DioException catch (e) {
      _setError(_parseError(e));
      return false;
    }
  }

  // ─── Onboarding ──────────────────────────────────────────────────────────────
  Future<bool> completeOnboarding({
    required String firstName,
    required String lastName,
    required String phone,
    required String securityPin,
    String? employeeNumber,
  }) async {
    _setLoading();
    try {
      final user = await _service.completeOnboarding(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        securityPin: securityPin,
        employeeNumber: employeeNumber,
      );

      await SecureStorage.setOnboardingComplete();
      _user = user;
      _setSuccess();
      return true;
    } on DioException catch (e) {
      _setError(_parseError(e));
      return false;
    }
  }

  // ─── Lookup ──────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> lookup(String email) async {
    _setLoading();
    try {
      final result = await _service.lookup(email);
      _setSuccess();
      return result;
    } on DioException catch (e) {
      _setError(_parseError(e));
      return null;
    }
  }

  // ─── Login ───────────────────────────────────────────────────────────────────
  Future<bool> login({
    required String email,
    required String password,
    required String tenantId,
  }) async {
    _setLoading();
    try {
      final response = await _service.login(
        email: email,
        password: password,
        tenantId: tenantId,
      );

      await SecureStorage.saveSession(
        token: response.token,
        tenantId: response.tenantId,
        onboardingComplete: true,
      );

      _user = response.user;
      _tenantId = response.tenantId;
      _setSuccess();
      return true;
    } on DioException catch (e) {
      _setError(_parseError(e));
      return false;
    }
  }

  // ─── Logout ──────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      await _service.logout();
    } catch (_) {}
    await SecureStorage.clear();
    _user = null;
    _tenantId = null;
    _status = AuthStatus.idle;
    notifyListeners();
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────
  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setSuccess() {
    _status = AuthStatus.success;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  void resetStatus() {
    _status = AuthStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  String _parseError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      // Errores de validación Laravel
      final errors = data['errors'];
      if (errors is Map) {
        final first = (errors.values.first as List).first;
        return first.toString();
      }
      final message = data['message'];
      if (message != null) return message.toString();
    }
    return 'Error de conexión. Intenta de nuevo.';
  }

  Future<void> loadSession() async {
    final token = await SecureStorage.getToken();
    if (token == null) return;

    try {
      final user = await _service.getMe();
      _user = user;
      _tenantId = await SecureStorage.getTenantId();
      notifyListeners();
    } catch (_) {
      await SecureStorage.clear();
    }
  }
}
