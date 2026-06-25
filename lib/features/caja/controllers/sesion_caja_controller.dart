import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:ventro_app/features/caja/models/sesion_caja_model.dart';
import 'package:ventro_app/features/caja/services/sesion_caja_service.dart';

enum SesionCajaStatus { idle, loading, saving, success, error }

class SesionCajaController extends ChangeNotifier {
  final SesionCajaService _service = SesionCajaService();

  SesionCajaStatus _status = SesionCajaStatus.idle;
  String? _errorMessage;
  SesionCajaModel? _sesionActiva;
  Map<String, dynamic>? _corteX;

  SesionCajaStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == SesionCajaStatus.loading;
  bool get isSaving => _status == SesionCajaStatus.saving;
  SesionCajaModel? get sesionActiva => _sesionActiva;
  Map<String, dynamic>? get corteX => _corteX;

  Future<void> cargarSesionActiva(int cajaId) async {
    _status = SesionCajaStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _sesionActiva = await _service.getSesionActiva(cajaId);
      _status = SesionCajaStatus.success;
    } on DioException catch (e) {
      _status = SesionCajaStatus.error;
      _errorMessage = _parseError(e);
    } catch (e) {
      _status = SesionCajaStatus.error;
      _errorMessage = 'Error inesperado al cargar la sesión de caja';
      debugPrint('❌ cargarSesionActiva (otro): $e');
    }
    notifyListeners();
  }

  Future<bool> abrirCaja({
    required int cajaId,
    required String employeeNumber,
    required String pin,
    required double montoInicial,
  }) async {
    _status = SesionCajaStatus.saving;
    _errorMessage = null;
    notifyListeners();
    try {
      _sesionActiva = await _service.abrir(
        cajaId: cajaId,
        employeeNumber: employeeNumber,
        pin: pin,
        montoInicial: montoInicial,
      );
      _status = SesionCajaStatus.success;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _status = SesionCajaStatus.error;
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    } catch (e) {
      _status = SesionCajaStatus.error;
      _errorMessage = 'Error inesperado al abrir caja';
      notifyListeners();
      return false;
    }
  }

  Future<bool> cerrarCaja({
    required String employeeNumber,
    required String pin,
    required double montoFinalContado,
  }) async {
    if (_sesionActiva == null) return false;
    _status = SesionCajaStatus.saving;
    _errorMessage = null;
    notifyListeners();
    try {
      _sesionActiva = await _service.cerrar(
        sesionId: _sesionActiva!.id,
        employeeNumber: employeeNumber,
        pin: pin,
        montoFinalContado: montoFinalContado,
      );
      _status = SesionCajaStatus.success;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _status = SesionCajaStatus.error;
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    } catch (e) {
      _status = SesionCajaStatus.error;
      _errorMessage = 'Error inesperado al cerrar caja';
      notifyListeners();
      return false;
    }
  }

  Future<bool> cargarCorteX({required String employeeNumber, required String pin}) async {
    if (_sesionActiva == null) return false;
    _errorMessage = null;
    try {
      _corteX = await _service.corteX(
        sesionId: _sesionActiva!.id,
        employeeNumber: employeeNumber,
        pin: pin,
      );
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error inesperado al cargar el corte';
      notifyListeners();
      return false;
    }
  }

  /// Limpia la sesión activa localmente (ej. al cambiar de caja seleccionada).
  void reset() {
    _sesionActiva = null;
    _corteX = null;
    _status = SesionCajaStatus.idle;
    _errorMessage = null;
    notifyListeners();
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
}
