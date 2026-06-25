import 'package:dio/dio.dart';
import 'package:ventro_app/core/network/api_client.dart';
import 'package:ventro_app/features/caja/models/sesion_caja_model.dart';

class SesionCajaService {
  final Dio _dio = ApiClient.instance;

  Future<SesionCajaModel?> getSesionActiva(int cajaId) async {
    final response = await _dio.get('/cajas/$cajaId/sesion-activa');
    final data = response.data;
    if (data == null || data is! Map || data.isEmpty) return null;
    return SesionCajaModel.fromJson(Map<String, dynamic>.from(data));
  }

  Future<SesionCajaModel> abrir({
    required int cajaId,
    required String employeeNumber,
    required String pin,
    required double montoInicial,
  }) async {
    final response = await _dio.post('/cajas/$cajaId/abrir', data: {
      'employee_number': employeeNumber,
      'pin': pin,
      'monto_inicial': montoInicial,
    });
    return SesionCajaModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<SesionCajaModel> cerrar({
    required int sesionId,
    required String employeeNumber,
    required String pin,
    required double montoFinalContado,
  }) async {
    final response = await _dio.post('/sesiones-caja/$sesionId/cerrar', data: {
      'employee_number': employeeNumber,
      'pin': pin,
      'monto_final_contado': montoFinalContado,
    });
    return SesionCajaModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<Map<String, dynamic>> corteX({
    required int sesionId,
    required String employeeNumber,
    required String pin,
  }) async {
    final response = await _dio.post('/sesiones-caja/$sesionId/corte-x', data: {
      'employee_number': employeeNumber,
      'pin': pin,
    });
    return Map<String, dynamic>.from(response.data);
  }
}
