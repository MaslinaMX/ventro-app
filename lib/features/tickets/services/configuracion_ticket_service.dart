import 'package:dio/dio.dart';
import 'package:ventro_app/core/network/api_client.dart';
import 'package:ventro_app/features/tickets/models/configuracion_ticket_model.dart';

class ConfiguracionTicketService {
  final Dio _dio = ApiClient.instance;

  Future<ConfiguracionTicketModel> getConfiguracion() async {
    final response = await _dio.get('/configuracion-tickets');
    return ConfiguracionTicketModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<ConfiguracionTicketModel> updateConfiguracion({
    bool? mostrarLogo,
    String? mensajePersonalizado,
  }) async {
    final response = await _dio.patch('/configuracion-tickets', data: {
      if (mostrarLogo != null) 'mostrar_logo': mostrarLogo,
      'mensaje_personalizado': mensajePersonalizado,
    });
    return ConfiguracionTicketModel.fromJson(Map<String, dynamic>.from(response.data));
  }
}
