import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:ventro_app/features/metodos_pago/models/metodo_pago_model.dart';
import 'package:ventro_app/features/metodos_pago/services/metodo_pago_service.dart';

enum MetodoPagoStatus { idle, loading, saving, success, error }

class MetodoPagoController extends ChangeNotifier {
  final MetodoPagoService _service = MetodoPagoService();

  MetodoPagoStatus _status = MetodoPagoStatus.idle;
  String? _errorMessage;
  List<MetodoPagoModel> _metodosPago = [];

  MetodoPagoStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == MetodoPagoStatus.loading;
  bool get isSaving => _status == MetodoPagoStatus.saving;
  List<MetodoPagoModel> get metodosPago => _metodosPago;

  Future<void> loadMetodosPago() async {
    _status = MetodoPagoStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _metodosPago = await _service.getMetodosPago();
      _status = MetodoPagoStatus.success;
    } on DioException catch (e) {
      _status = MetodoPagoStatus.error;
      _errorMessage = _parseError(e);
    }
    notifyListeners();
  }

  Future<bool> createMetodoPago(Map<String, dynamic> data) async {
    _status = MetodoPagoStatus.saving;
    _errorMessage = null;
    notifyListeners();
    try {
      final nuevo = await _service.createMetodoPago(data);
      _metodosPago = [..._metodosPago, nuevo];
      _status = MetodoPagoStatus.success;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _status = MetodoPagoStatus.error;
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> editMetodoPago(int id, Map<String, dynamic> data) async {
    _status = MetodoPagoStatus.saving;
    _errorMessage = null;
    notifyListeners();
    try {
      final updated = await _service.updateMetodoPago(id, data);
      _metodosPago = [
        for (final m in _metodosPago) m.id == id ? updated : m,
      ];
      _status = MetodoPagoStatus.success;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _status = MetodoPagoStatus.error;
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMetodoPago(int id) async {
    _status = MetodoPagoStatus.saving;
    _errorMessage = null;
    notifyListeners();
    try {
      await _service.deleteMetodoPago(id);
      _metodosPago = _metodosPago.where((m) => m.id != id).toList();
      _status = MetodoPagoStatus.success;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _status = MetodoPagoStatus.error;
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  String _parseError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
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

  void resetStatus() {
    _status = MetodoPagoStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
