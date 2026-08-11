import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:ventro_app/features/caja/models/caja_model.dart';
import 'package:ventro_app/features/caja/services/caja_service.dart';

enum CajaStatus { idle, loading, saving, success, error }

class CajaController extends ChangeNotifier {
  final CajaService _service = CajaService();

  CajaStatus _status = CajaStatus.idle;
  String? _errorMessage;
  List<CajaModel> _cajas = [];

  CajaStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == CajaStatus.loading;
  bool get isSaving => _status == CajaStatus.saving;
  List<CajaModel> get cajas => _cajas;

  Future<void> loadCajas() async {
    _status = CajaStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _cajas = await _service.getCajas();
      _status = CajaStatus.success;
    } on DioException catch (e) {
      _status = CajaStatus.error;
      _errorMessage = _parseError(e);
    } catch (e) {
      _status = CajaStatus.error;
      _errorMessage = 'Error al cargar cajas: $e';
    }
    notifyListeners();
  }

  Future<bool> createCaja(Map<String, dynamic> data) async {
    _status = CajaStatus.saving;
    _errorMessage = null;
    notifyListeners();
    try {
      final nueva = await _service.createCaja(data);
      _cajas = [..._cajas, nueva];
      _status = CajaStatus.success;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _status = CajaStatus.error;
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> editCaja(int id, Map<String, dynamic> data) async {
    _status = CajaStatus.saving;
    _errorMessage = null;
    notifyListeners();
    try {
      final updated = await _service.updateCaja(id, data);
      _cajas = [
        for (final c in _cajas) c.id == id ? updated : c,
      ];
      _status = CajaStatus.success;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _status = CajaStatus.error;
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCaja(int id) async {
    _status = CajaStatus.saving;
    _errorMessage = null;
    notifyListeners();
    try {
      await _service.deleteCaja(id);
      _cajas = _cajas.where((c) => c.id != id).toList();
      _status = CajaStatus.success;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _status = CajaStatus.error;
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
    _status = CajaStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
