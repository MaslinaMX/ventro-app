import 'package:flutter/foundation.dart';
import 'package:ventro_app/features/inventario/models/inventario_stock_model.dart';
import 'package:ventro_app/features/inventario/models/movimiento_inventario_model.dart';
import 'package:ventro_app/features/inventario/services/inventario_service.dart';

class InventarioController extends ChangeNotifier {
  final InventarioService _service = InventarioService();

  List<InventarioStockModel> _stock = [];
  List<MovimientoInventarioModel> _movimientos = [];
  bool _isLoading = false;
  bool _isLoadingMovimientos = false;
  String? _error;
  String? _movimientosError;
  int? _sucursalId;

  List<InventarioStockModel> get stock => _stock;
  List<MovimientoInventarioModel> get movimientos => _movimientos;
  bool get isLoading => _isLoading;
  bool get isLoadingMovimientos => _isLoadingMovimientos;
  String? get error => _error;
  String? get movimientosError => _movimientosError;
  int? get sucursalId => _sucursalId;

  int get totalProductos => _stock.length;
  int get alertasStockBajo => _stock.where((s) => s.bajoStock).length;
  int get productosAgotados => _stock.where((s) => s.cantidad <= 0).length;

  Future<void> cargarStock(int sucursalId, {String? search}) async {
    _sucursalId = sucursalId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _stock = await _service.getStockPorSucursal(sucursalId, search: search);
    } catch (e) {
      _error = 'No se pudo cargar el inventario.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    await cargarMovimientos(sucursalId);
  }

  Future<void> cargarMovimientos(int sucursalId) async {
    _isLoadingMovimientos = true;
    _movimientosError = null;
    notifyListeners();

    try {
      _movimientos = await _service.getMovimientosPorSucursal(sucursalId);
    } catch (e) {
      _movimientosError = 'No se pudo cargar el historial de movimientos.';
    } finally {
      _isLoadingMovimientos = false;
      notifyListeners();
    }
  }

  Future<void> refrescar() async {
    if (_sucursalId == null) return;
    await cargarStock(_sucursalId!);
  }

  /// Registra un ajuste rápido de stock. Calcula automáticamente si es
  /// entrada ('in') o salida ('out') según la diferencia entre el stock
  /// actual y el nuevo stock ingresado.
  Future<bool> registrarAjusteRapido({
    required int varianteId,
    required double stockActual,
    required double stockNuevo,
    required String motivo,
  }) async {
    final diferencia = stockNuevo - stockActual;
    if (diferencia == 0 || _sucursalId == null) return false;

    final type = diferencia > 0 ? 'in' : 'out';
    final cantidad = diferencia.abs();

    try {
      await _service.registrarMovimiento(
        varianteId: varianteId,
        sucursalId: _sucursalId!,
        type: type,
        reason: 'ajuste',
        cantidad: cantidad,
        notas: motivo,
      );
      await refrescar();
      return true;
    } catch (e) {
      return false;
    }
  }
}
