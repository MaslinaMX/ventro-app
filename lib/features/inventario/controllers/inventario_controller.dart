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

  /// Umbral configurable para "stock bajo". Default: 5.
  /// este valor debe cargarse desde la configuración del tenant.
  int umbralStockBajo = 5;

  List<InventarioStockModel> get stock => _stock;
  List<MovimientoInventarioModel> get movimientos => _movimientos;
  bool get isLoading => _isLoading;
  bool get isLoadingMovimientos => _isLoadingMovimientos;
  String? get error => _error;
  String? get movimientosError => _movimientosError;
  int? get sucursalId => _sucursalId;

  bool isLoadingUmbral = false;

  int get totalProductos => _stock.length;

  List<InventarioStockModel> get productosStockBajo =>
      _stock.where((s) => s.cantidad > 0 && s.cantidad < umbralStockBajo).toList();

  List<InventarioStockModel> get productosAgotadosLista =>
      _stock.where((s) => s.cantidad <= 0).toList();

  int get alertasStockBajo => productosStockBajo.length;
  int get productosAgotados => productosAgotadosLista.length;

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

  Future<void> cargarUmbralStockBajo() async {
    isLoadingUmbral = true;
    notifyListeners();
    try {
      umbralStockBajo = await _service.obtenerStockMinimoGlobal();
    } catch (_) {
      // Si falla, se queda con el default de 5.
    } finally {
      isLoadingUmbral = false;
      notifyListeners();
    }
  }

  Future<bool> guardarUmbralStockBajo(int nuevoUmbral) async {
    try {
      umbralStockBajo = await _service.actualizarStockMinimoGlobal(nuevoUmbral);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<MovimientoInventarioModel>> obtenerMovimientosPorVariante(
    int varianteId, {
    int? sucursalId,
  }) {
    return _service.getMovimientosPorVariante(varianteId, sucursalId: sucursalId);
  }

  /// Trae movimientos con filtros opcionales. Si ambos son null, trae
  /// todos los movimientos del tenant (sin filtrar por producto ni sucursal).
  Future<List<MovimientoInventarioModel>> obtenerMovimientos({
    int? varianteId,
    int? sucursalId,
  }) {
    return _service.getMovimientos(varianteId: varianteId, sucursalId: sucursalId);
  }
}
