import 'package:dio/dio.dart';
import 'package:ventro_app/core/network/api_client.dart';
import 'package:ventro_app/features/inventario/models/inventario_stock_model.dart';
import 'package:ventro_app/features/inventario/models/movimiento_inventario_model.dart';

class InventarioService {
  final Dio _dio = ApiClient.instance;

  /// Stock actual de todas las variantes activas en una sucursal.
  /// No paginado: pensado para negocios chicos/medianos con catálogos manejables.
  Future<List<InventarioStockModel>> getStockPorSucursal(
    int sucursalId, {
    String? search,
  }) async {
    final response = await _dio.get(
      '/inventario/sucursales/$sucursalId/stock',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    final List data = response.data as List;
    return data.map((e) => InventarioStockModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  /// Historial de movimientos (kardex) de una sucursal. Paginado.
  Future<List<MovimientoInventarioModel>> getMovimientosPorSucursal(
    int sucursalId, {
    int page = 1,
    String? search,
    String? mes,
  }) async {
    final response = await _dio.get(
      '/inventario/sucursales/$sucursalId/movimientos',
      queryParameters: {
        'page': page,
        if (search != null && search.isNotEmpty) 'search': search,
        if (mes != null) 'mes': mes,
      },
    );
    final List data = response.data['data'] as List;
    return data
        .map((e) => MovimientoInventarioModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Registra un movimiento de inventario (ajuste, compra, venta, merma, etc.)
  Future<MovimientoInventarioModel> registrarMovimiento({
    required int varianteId,
    required int sucursalId,
    required String type,
    required String reason,
    required double cantidad,
    String? notas,
  }) async {
    final response = await _dio.post('/inventario/movimientos', data: {
      'variante_id': varianteId,
      'sucursal_id': sucursalId,
      'type': type,
      'reason': reason,
      'cantidad': cantidad,
      if (notas != null && notas.isNotEmpty) 'notas': notas,
    });
    return MovimientoInventarioModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<int> obtenerStockMinimoGlobal() async {
    final response = await _dio.get('/inventario/configuracion/stock-minimo');
    return (response.data['cantidad_minima'] as num).toInt();
  }

  Future<int> actualizarStockMinimoGlobal(int cantidadMinima) async {
    final response = await _dio.post(
      '/inventario/configuracion/stock-minimo',
      data: {'cantidad_minima': cantidadMinima},
    );
    return (response.data['cantidad_minima'] as num).toInt();
  }

  Future<List<MovimientoInventarioModel>> getMovimientosPorVariante(
    int varianteId, {
    int? sucursalId,
  }) async {
    final response = await _dio.get(
      '/inventario/variantes/$varianteId/movimientos',
      queryParameters: {
        if (sucursalId != null) 'sucursal_id': sucursalId,
        'per_page': 100,
      },
    );
    final List data = response.data['data'] as List;
    return data
        .map((e) => MovimientoInventarioModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Historial de movimientos con filtros opcionales de producto y/o sucursal.
  /// Si ambos son null, trae todos los movimientos del tenant.
  /// Requiere el endpoint GET /inventario/movimientos en el backend
  /// (ver nota abajo — este endpoint aún no existe en tu Laravel).
  Future<List<MovimientoInventarioModel>> getMovimientos({
    int? varianteId,
    int? sucursalId,
    int perPage = 50,
  }) async {
    final response = await _dio.get(
      '/inventario/movimientos',
      queryParameters: {
        if (varianteId != null) 'variante_id': varianteId,
        if (sucursalId != null) 'sucursal_id': sucursalId,
        'per_page': perPage,
      },
    );
    final List data = response.data['data'] as List;
    return data
        .map((e) => MovimientoInventarioModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
