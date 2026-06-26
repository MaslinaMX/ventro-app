import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:ventro_app/features/tickets/models/configuracion_ticket_model.dart';
import 'package:ventro_app/features/tickets/services/configuracion_ticket_service.dart';

enum ConfigTicketStatus { idle, loading, saving, success, error }

class ConfiguracionTicketController extends ChangeNotifier {
  final ConfiguracionTicketService _service = ConfiguracionTicketService();

  ConfigTicketStatus _status = ConfigTicketStatus.idle;
  String? _errorMessage;
  ConfiguracionTicketModel? _configuracion;

  ConfigTicketStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == ConfigTicketStatus.loading;
  bool get isSaving => _status == ConfigTicketStatus.saving;
  ConfiguracionTicketModel? get configuracion => _configuracion;

  Future<void> cargar() async {
    _status = ConfigTicketStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _configuracion = await _service.getConfiguracion();
      _status = ConfigTicketStatus.success;
    } on DioException catch (e) {
      _status = ConfigTicketStatus.error;
      _errorMessage = _parseError(e);
    }
    notifyListeners();
  }

  Future<bool> guardar({bool? mostrarLogo, String? mensajePersonalizado}) async {
    _status = ConfigTicketStatus.saving;
    _errorMessage = null;
    notifyListeners();
    try {
      _configuracion = await _service.updateConfiguracion(
        mostrarLogo: mostrarLogo,
        mensajePersonalizado: mensajePersonalizado,
      );
      _status = ConfigTicketStatus.success;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _status = ConfigTicketStatus.error;
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    }
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
