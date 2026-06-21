import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:ventro_app/features/account/models/account_model.dart';
import 'package:ventro_app/features/account/services/account_service.dart';

enum AccountStatus { idle, loading, success, error }

class AccountController extends ChangeNotifier {
  final AccountService _service = AccountService();

  AccountStatus _status = AccountStatus.idle;
  AccountModel? _account;
  String? _errorMessage;

  AccountStatus get status => _status;
  AccountModel? get account => _account;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AccountStatus.loading;

  Future<void> load() async {
    _status = AccountStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _account = await _service.getAccount();
      _status = AccountStatus.success;
    } on DioException catch (e) {
      _status = AccountStatus.error;
      _errorMessage = _parseError(e);
    }

    notifyListeners();
  }

  String _parseError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final message = data['message'];
      if (message != null) return message.toString();
    }
    return 'Error de conexión. Intenta de nuevo.';
  }

  void reset() {
    _status = AccountStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
