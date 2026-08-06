import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:ventro_app/features/clientes/models/cliente_model.dart';
import 'package:ventro_app/features/clientes/services/cliente_service.dart';

enum ClientesStatus { idle, loading, success, error }

class ClientesController extends ChangeNotifier {
  final ClienteService _service = ClienteService();

  ClientesStatus _status = ClientesStatus.idle;
  String? _errorMessage;
  List<ClienteModel> _clientes = [];
  String _busqueda = '';

  ClientesStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == ClientesStatus.loading;
  String get busqueda => _busqueda;

  List<ClienteModel> get clientes {
    if (_busqueda.isEmpty) return _clientes;
    final q = _busqueda.toLowerCase();
    return _clientes.where((c) {
      return c.nombre.toLowerCase().contains(q) ||
          (c.rfc?.toLowerCase().contains(q) ?? false) ||
          (c.telefono?.contains(q) ?? false) ||
          (c.email?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  Future<void> cargarClientes() async {
    _status = ClientesStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _clientes = await _service.getClientes();
      _status = ClientesStatus.success;
    } on DioException catch (e) {
      _status = ClientesStatus.error;
      _errorMessage = _parseError(e);
    } catch (e) {
      _status = ClientesStatus.error;
      _errorMessage = 'Error inesperado al cargar clientes';
    }
    notifyListeners();
  }

  void buscar(String query) {
    _busqueda = query;
    notifyListeners();
  }

  Future<bool> guardarCliente(ClienteModel cliente) async {
    try {
      final esNuevo = cliente.id == 0;
      final guardado = esNuevo
          ? await _service.crearCliente(cliente)
          : await _service.actualizarCliente(cliente);

      if (esNuevo) {
        _clientes = [..._clientes, guardado];
      } else {
        _clientes = _clientes.map((c) => c.id == guardado.id ? guardado : c).toList();
      }
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  /// Regresa null si se eliminó correctamente, o el mensaje del backend
  /// si falló (ej. "tiene ventas asociadas") para que la UI lo muestre
  /// y sugiera desactivar en vez de eliminar.
  Future<String?> eliminarCliente(int id) async {
    try {
      await _service.eliminarCliente(id);
      _clientes = _clientes.where((c) => c.id != id).toList();
      notifyListeners();
      return null;
    } on DioException catch (e) {
      return _parseError(e);
    }
  }

  String _parseError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return 'Error de conexión. Intenta de nuevo.';
  }
}
