import 'package:dio/dio.dart';
import 'package:ventro_app/core/network/api_client.dart';
import 'package:ventro_app/features/ventas/models/venta_detalle_model.dart';

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

  Future<void> enviarTicketPorEmail(int ventaId, String email) async {
    await _dio.post('/ventas/$ventaId/ticket/email', data: {'email': email});
  }

  Future<List<int>> descargarTicketPdf(int ventaId, {bool reimpresion = false}) async {
    final response = await _dio.get(
      '/ventas/$ventaId/ticket',
      queryParameters: reimpresion ? {'reimpresion': 'true'} : null,
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data as List<int>;
  }

  Future<List<Map<String, dynamic>>> getVentasDelDia() async {
    final response = await _dio.get('/ventas/del-dia');
    final list = response.data as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getVentasDeLaSesion() async {
    final response = await _dio.get('/ventas/de-la-sesion');
    final list = response.data as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  Future<VentaDetalleModel> getDetalle(int ventaId) async {
    final response = await _dio.get('/ventas/$ventaId');
    return VentaDetalleModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<void> cancelarVenta({
    required int ventaId,
    required String employeeNumber,
    required String pin,
    required int metodoDevolucionId,
    required double montoDevuelto,
    String? motivo,
    required List<Map<String, dynamic>> itemsDevueltos,
  }) async {
    await _dio.post('/ventas/$ventaId/cancelar', data: {
      'employee_number': employeeNumber,
      'pin': pin,
      'metodo_devolucion_id': metodoDevolucionId,
      'monto_devuelto': montoDevuelto,
      'motivo': motivo,
      'items_devueltos': itemsDevueltos,
    });
  }

  Future<String> autorizarDescuento(String employeeNumber, String pin) async {
    final response = await ApiClient.instance.post('/ventas/autorizar-descuento', data: {
      'employee_number': employeeNumber,
      'pin': pin,
    });
    return response.data['name'] as String;
  }

  Future<Map<String, dynamic>> getTodasLasVentas({
    int? sucursalId,
    String? buscar,
    String? mes,
  }) async {
    final response = await _dio.get('/ventas/todas', queryParameters: {
      if (sucursalId != null) 'sucursal_id': sucursalId,
      if (buscar != null && buscar.isNotEmpty) 'buscar': buscar,
      if (mes != null) 'mes': mes,
    });
    return Map<String, dynamic>.from(response.data);
  }
}
