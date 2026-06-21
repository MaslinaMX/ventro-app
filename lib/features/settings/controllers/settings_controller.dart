import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:ventro_app/features/settings/models/tenant_model.dart';
import 'package:ventro_app/features/settings/models/sucursal_model.dart';
import 'package:ventro_app/features/settings/services/settings_service.dart';

enum SettingsStatus { idle, loading, saving, success, error }

class SettingsController extends ChangeNotifier {
  final SettingsService _service = SettingsService();

  SettingsStatus _status = SettingsStatus.idle;
  TenantModel? _tenant;
  SucursalModel? _sucursalMain;
  String? _errorMessage;

  SettingsStatus get status => _status;
  TenantModel? get tenant => _tenant;
  SucursalModel? get sucursalMain => _sucursalMain;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == SettingsStatus.loading;
  bool get isSaving => _status == SettingsStatus.saving;

  Future<void> loadGeneral() async {
    _status = SettingsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _tenant = await _service.getTenant();
      final sucursales = await _service.getSucursales();
      debugPrint('🔍 sucursales recibidas: ${sucursales.length}');

      if (sucursales.isEmpty) {
        _errorMessage = 'No hay sucursales registradas';
        _status = SettingsStatus.error;
        notifyListeners();
        return;
      }

      _sucursalMain = sucursales.firstWhere(
        (s) => s.isMain,
        orElse: () => sucursales.first,
      );
      _status = SettingsStatus.success;
    } on DioException catch (e) {
      debugPrint('❌ loadGeneral (Dio): ${e.response?.statusCode} → ${e.response?.data}');
      _status = SettingsStatus.error;
      _errorMessage = _parseError(e);
    } catch (e, st) {
      debugPrint('❌ loadGeneral (otro): $e\n$st');
      _status = SettingsStatus.error;
      _errorMessage = 'Error inesperado cargando sucursales';
    }

    notifyListeners();
  }

  // ─── Guardar General ──────────────────────────────────────────────────────
  Future<bool> saveGeneral({
    required String name,
    String? razonSocial,
    String? logo,
    String? email,
    String? telefono,
    String? telefonoAlternativo,
    String? sitioWeb,
    String? direccion,
    String? direccion2,
    String? ciudad,
    String? estado,
    String? codigoPostal,
    String? pais,
  }) async {
    _status = SettingsStatus.saving;
    _errorMessage = null;
    notifyListeners();

    try {
      _tenant = await _service.updateTenant(
        name: name,
        razonSocial: razonSocial,
        logo: logo,
      );

      _sucursalMain = await _service.updateSucursal(_sucursalMain!.id, {
        'nombre': name,
        'email': email,
        'telefono': telefono,
        'telefono_alternativo': telefonoAlternativo,
        'sitio_web': sitioWeb,
        'direccion': direccion,
        'direccion_2': direccion2,
        'ciudad': ciudad,
        'estado': estado,
        'codigo_postal': codigoPostal,
        'pais': pais,
      });

      _status = SettingsStatus.success;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _status = SettingsStatus.error;
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────
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
    _status = SettingsStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> uploadLogo(Uint8List bytes, String fileName) async {
    _status = SettingsStatus.saving;
    _errorMessage = null;
    notifyListeners();

    try {
      final url = await _service.uploadLogo(bytes, fileName);
      _tenant = TenantModel(
        id: _tenant!.id,
        name: _tenant!.name,
        razonSocial: _tenant!.razonSocial,
        logo: url,
        email: _tenant!.email,
        plan: _tenant!.plan,
        status: _tenant!.status,
      );
      _status = SettingsStatus.success;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _status = SettingsStatus.error;
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  // ─── Sucursales ───────────────────────────────────────────────────────────
  List<SucursalModel> _sucursales = [];
  List<SucursalModel> get sucursales => _sucursales;

  Future<void> loadSucursales() async {
    _status = SettingsStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _sucursales = await _service.getSucursales();
      _status = SettingsStatus.success;
    } on DioException catch (e) {
      _status = SettingsStatus.error;
      _errorMessage = _parseError(e);
    }
    notifyListeners();
  }

  Future<bool> createSucursal(Map<String, dynamic> data) async {
    _status = SettingsStatus.saving;
    _errorMessage = null;
    notifyListeners();
    try {
      final nueva = await _service.createSucursal(data);
      _sucursales = [..._sucursales, nueva];
      _status = SettingsStatus.success;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _status = SettingsStatus.error;
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> editSucursal(int id, Map<String, dynamic> data) async {
    _status = SettingsStatus.saving;
    _errorMessage = null;
    notifyListeners();
    try {
      final updated = await _service.updateSucursal(id, data);
      _sucursales = [
        for (final s in _sucursales) s.id == id ? updated : s,
      ];
      _status = SettingsStatus.success;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _status = SettingsStatus.error;
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSucursal(int id) async {
    _status = SettingsStatus.saving;
    _errorMessage = null;
    notifyListeners();
    try {
      await _service.deleteSucursal(id);
      _sucursales = _sucursales.where((s) => s.id != id).toList();
      _status = SettingsStatus.success;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _status = SettingsStatus.error;
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    }
  }
}
