import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:ventro_app/features/dashboard/models/resumen_mes_model.dart';
import 'package:ventro_app/features/dashboard/services/dashboard_service.dart';

class DashboardController extends ChangeNotifier {
  final DashboardService _service = DashboardService();

  bool _cargando = false;
  String? _errorMessage;
  ResumenMesModel? _resumenMes;

  bool get cargando => _cargando;
  String? get errorMessage => _errorMessage;
  ResumenMesModel? get resumenMes => _resumenMes;

  Future<void> cargarResumenMes() async {
    _cargando = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _resumenMes = await _service.getResumenMes();
    } on DioException catch (e) {
      _errorMessage = _parseError(e);
    }
    _cargando = false;
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
}
