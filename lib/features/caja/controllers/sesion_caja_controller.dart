import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:ventro_app/features/caja/models/corte_caja_model.dart';
import 'package:ventro_app/features/caja/models/sesion_caja_model.dart';
import 'package:ventro_app/features/caja/services/sesion_caja_service.dart';
import 'dart:js_interop';
import 'package:printing/printing.dart';
import 'package:web/web.dart' as web;

enum SesionCajaStatus { idle, loading, saving, success, error }

class SesionCajaController extends ChangeNotifier {
  final SesionCajaService _service = SesionCajaService();

  Map<String, dynamic>? _corteZ;
  CorteCajaModel? get corteZ => _corteZ != null ? CorteCajaModel.fromJson(_corteZ!) : null;

  SesionCajaStatus _status = SesionCajaStatus.idle;
  String? _errorMessage;
  SesionCajaModel? _sesionActiva;
  Map<String, dynamic>? _corteX;

  SesionCajaStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == SesionCajaStatus.loading;
  bool get isSaving => _status == SesionCajaStatus.saving;
  SesionCajaModel? get sesionActiva => _sesionActiva;
  CorteCajaModel? get corteX => _corteX != null ? CorteCajaModel.fromJson(_corteX!) : null;

  Map<String, dynamic>? _previewCierre;
  double? get previewEfectivoInicial =>
      _previewCierre != null ? double.parse(_previewCierre!['monto_inicial'].toString()) : null;
  double? get previewEfectivoEsperado =>
      _previewCierre != null ? double.parse(_previewCierre!['efectivo_esperado'].toString()) : null;
  double? get previewTotalVentas =>
      _previewCierre != null ? double.parse(_previewCierre!['total_ventas'].toString()) : null;
  int? get previewCantidadVentas => _previewCierre?['cantidad_ventas'];
  bool _cargandoPreview = false;
  bool get cargandoPreview => _cargandoPreview;

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

  Future<bool> generarCorteZ({
    required String employeeNumber,
    required String pin,
    required double montoFinalContado,
  }) async {
    if (_sesionActiva == null) return false;
    _status = SesionCajaStatus.saving;
    _errorMessage = null;
    notifyListeners();
    try {
      _corteZ = await _service.corteZ(
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
      _errorMessage = 'Error inesperado al generar el corte Z';
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

  Future<void> abrirCortePdf(int corteId) async {
    try {
      if (kIsWeb) {
        // Abrir la ventana INMEDIATAMENTE, antes del await
        final nuevaVentana = web.window.open('', '_blank');

        final bytes = await _service.descargarCortePdf(corteId);

        final blobParts = [Uint8List.fromList(bytes).toJS].toJS;
        final blob = web.Blob(blobParts, web.BlobPropertyBag(type: 'application/pdf'));
        final url = web.URL.createObjectURL(blob);

        nuevaVentana?.location.href = url;
      } else {
        final bytes = await _service.descargarCortePdf(corteId);
        await Printing.layoutPdf(onLayout: (_) async => Uint8List.fromList(bytes));
      }
    } catch (e) {
      _errorMessage = 'No se pudo abrir el corte';
      notifyListeners();
    }
  }

  Future<void> cargarPreviewCierre() async {
    if (_sesionActiva == null) return;
    _cargandoPreview = true;
    notifyListeners();
    try {
      _previewCierre = await _service.previewCierre(_sesionActiva!.id);
    } on DioException catch (e) {
      _errorMessage = _parseError(e);
    }
    _cargandoPreview = false;
    notifyListeners();
  }
}
