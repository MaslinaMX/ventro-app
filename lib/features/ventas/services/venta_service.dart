import 'package:dio/dio.dart';
import 'package:ventro_app/core/network/api_client.dart';

class VentaService {
  final Dio _dio = ApiClient.instance;

  /// Verifica número de empleado + PIN. Regresa el nombre si es válido.
  Future<String> verificarEmpleado(String employeeNumber, String pin) async {
    final response = await _dio.post('/ventas/verificar-empleado', data: {
      'employee_number': employeeNumber,
      'pin': pin,
    });
    return Map<String, dynamic>.from(response.data)['name'] as String;
  }

  /// Crea la venta completa: items, pagos, descuenta inventario.
  Future<Map<String, dynamic>> crearVenta({
    required int cajaId,
    required String employeeNumber,
    required String pin,
    required List<Map<String, dynamic>> items,
    required List<Map<String, dynamic>> pagos,
    double descuento = 0,
    int? clienteId,
  }) async {
    final response = await _dio.post('/ventas', data: {
      'caja_id': cajaId,
      'employee_number': employeeNumber,
      'pin': pin,
      'items': items,
      'pagos': pagos,
      'descuento': descuento,
      if (clienteId != null) 'cliente_id': clienteId,
    });
    return Map<String, dynamic>.from(response.data);
  }

  /// Lista las cajas que actualmente tienen sesión abierta.
  Future<List<Map<String, dynamic>>> getCajasAbiertas() async {
    final response = await _dio.get('/cajas-abiertas');
    final list = response.data as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }
}
