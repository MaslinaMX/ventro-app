import 'package:ventro_app/core/network/api_client.dart';
import 'package:ventro_app/features/clientes/models/cliente_estadisticas_model.dart';
import 'package:ventro_app/features/clientes/models/cliente_model.dart';

/// Service de clientes — usa ApiClient.instance (autenticado, con
/// X-Tenant-ID/X-Sucursal-ID vía interceptor) a diferencia del catálogo
/// público que usa su propio Dio sin auth.
class ClienteService {
  final _dio = ApiClient.instance;

  Future<List<ClienteModel>> getClientes({String? search, bool? activo}) async {
    final response = await _dio.get(
      '/clientes',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (activo != null) 'activo': activo,
        'per_page': 100,
      },
    );

    final data = response.data['data'] as List<dynamic>;
    return data.map((json) => ClienteModel.fromJson(json)).toList();
  }

  Future<ClienteModel> getCliente(int id) async {
    final response = await _dio.get('/clientes/$id');
    return ClienteModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ClienteModel> crearCliente(ClienteModel cliente) async {
    final response = await _dio.post('/clientes', data: cliente.toJson());
    return ClienteModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ClienteModel> actualizarCliente(ClienteModel cliente) async {
    final response = await _dio.put('/clientes/${cliente.id}', data: cliente.toJson());
    return ClienteModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Puede fallar con 422 si el cliente tiene ventas asociadas — en ese
  /// caso el controller debe sugerir desactivar en vez de eliminar.
  Future<void> eliminarCliente(int id) async {
    await _dio.delete('/clientes/$id');
  }

  Future<ClienteEstadisticasModel> getEstadisticas(int clienteId) async {
    final response = await _dio.get('/clientes/$clienteId/estadisticas');
    return ClienteEstadisticasModel.fromJson(response.data as Map<String, dynamic>);
  }
}
