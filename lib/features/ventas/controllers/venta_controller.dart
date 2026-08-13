import 'dart:async';
import 'dart:js_interop';
import 'package:printing/printing.dart';
import 'package:ventro_app/features/ventas/models/tipo_descuento.dart';
import 'package:ventro_app/features/ventas/models/venta_detalle_model.dart';
import 'package:web/web.dart' as web;
import 'package:flutter/scheduler.dart';

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:ventro_app/core/network/api_client.dart';
import 'package:ventro_app/features/caja/models/caja_model.dart';
import 'package:ventro_app/features/products/models/categoria_model.dart';
import 'package:ventro_app/features/products/models/producto_model.dart';
import 'package:ventro_app/features/products/models/producto_variante_model.dart';
import 'package:ventro_app/features/products/services/producto_service.dart';
import 'package:ventro_app/features/ventas/models/carrito_item_model.dart';
import 'package:ventro_app/features/ventas/models/venta_dia_model.dart';
import 'package:ventro_app/features/ventas/services/venta_service.dart';

enum VentaStatus { idle, loading, success, error }

class VentaController extends ChangeNotifier {
  final ProductoService _service = ProductoService();
  final VentaService _ventaService = VentaService();

  bool _cancelando = false;
  bool get cancelando => _cancelando;

  TipoDescuento? _descuentoTipo;
  double _descuentoValor = 0;
  String? _descuentoAutorizadoPor;

  VentaStatus _status = VentaStatus.idle;
  String? _errorMessage;
  List<ProductoModel> _productos = [];
  List<CategoriaModel> _categorias = [];
  Map<int, double> _stockPorVarianteId = {};

  int? _categoriaSeleccionadaId; // null = "Todas"
  String _busqueda = '';

  int? _sucursalId;
  int? get sucursalId => _sucursalId;

  final List<CarritoItemModel> _carrito = [];

  // ─── Caja y empleado verificado para esta sesión de venta en pantalla ──────
  List<CajaModel> _cajasAbiertas = [];
  List<CajaVentasDiaModel> _ventasDelDia = [];
  bool _cargandoVentasDelDia = false;
  int? _cajaId;
  String? _empleadoNumero;
  String? _empleadoPin;
  String? _empleadoNombreVerificado;
  bool _verificandoEmpleado = false;
  bool _cobrando = false;
  Timer? _inactividadTimer;
  static const _tiempoInactividad = Duration(minutes: 3);

  // ─── Getters ────────────────────────────────────────────────────────────────
  VentaStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == VentaStatus.loading;
  List<CategoriaModel> get categorias => _categorias;
  int? get categoriaSeleccionadaId => _categoriaSeleccionadaId;
  String get busqueda => _busqueda;
  List<CarritoItemModel> get carrito => List.unmodifiable(_carrito);

  List<CajaModel> get cajasAbiertas => _cajasAbiertas;
  List<CajaVentasDiaModel> get ventasDelDia => _ventasDelDia;
  bool get cargandoVentasDelDia => _cargandoVentasDelDia;
  int? get cajaId => _cajaId;
  bool get empleadoVerificado => _empleadoNombreVerificado != null;
  String? get empleadoNombreVerificado => _empleadoNombreVerificado;
  bool get verificandoEmpleado => _verificandoEmpleado;
  bool get cobrando => _cobrando;

  double get totalCarrito => subtotalCarrito - descuentoMonto;
  int get cantidadItemsCarrito => _carrito.fold(0, (sum, item) => sum + item.cantidad);

  VentaDetalleModel? _ventaDetalle;
  bool _cargandoDetalle = false;
  VentaDetalleModel? get ventaDetalle => _ventaDetalle;
  bool get cargandoDetalle => _cargandoDetalle;

// ─── Descuentos ────────────────────────────────────────────────────────────────
  bool get descuentoActivo => _descuentoTipo != null && _descuentoValor > 0;
  TipoDescuento? get descuentoTipo => _descuentoTipo;
  double get descuentoValorConfigurado => _descuentoValor;
  String? get descuentoAutorizadoPor => _descuentoAutorizadoPor;

  double get subtotalCarrito => _carrito.fold(0, (sum, item) => sum + item.subtotal);

  double get descuentoMonto {
    if (!descuentoActivo) return 0;
    final monto = _descuentoTipo == TipoDescuento.porcentaje
        ? subtotalCarrito * _descuentoValor / 100
        : _descuentoValor;
    return double.parse(monto.clamp(0, subtotalCarrito).toStringAsFixed(2));
  }

  /// Cantidad de una variante específica ya presente en el carrito. 0 si no está.
  int cantidadEnCarrito(int varianteId) {
    for (final item in _carrito) {
      if (item.variante.id == varianteId) return item.cantidad;
    }
    return 0;
  }

  /// Stock disponible de una variante en la sucursal actual. 0 si no hay registro.
  double stockDisponible(int varianteId) => _stockPorVarianteId[varianteId] ?? 0;

  ///listado de las ventas por sesion
  List<CajaVentasSesionModel> _ventasDeLaSesion = [];
  bool _cargandoVentasDeLaSesion = false;

  List<CajaVentasSesionModel> get ventasDeLaSesion => _ventasDeLaSesion;
  bool get cargandoVentasDeLaSesion => _cargandoVentasDeLaSesion;

  /// Lista plana de variantes vendibles (activas), ya filtradas por
  /// categoría y búsqueda. Cada variante lleva referencia a su producto
  /// padre para poder mostrar "Producto - Variante" en el grid.
  List<({ProductoVarianteModel variante, ProductoModel producto})> get variantesVisibles {
    final resultado = <({ProductoVarianteModel variante, ProductoModel producto})>[];

    for (final producto in _productos) {
      if (!producto.activo) continue;
      if (_categoriaSeleccionadaId != null && producto.categoriaId != _categoriaSeleccionadaId) {
        continue;
      }

      for (final variante in producto.variantes) {
        if (!variante.activo) continue;

        if (_busqueda.isNotEmpty) {
          final q = _busqueda.toLowerCase();
          final matchNombre = producto.nombre.toLowerCase().contains(q) ||
              variante.nombre.toLowerCase().contains(q);
          final matchSku = variante.sku?.toLowerCase().contains(q) ?? false;
          if (!matchNombre && !matchSku) continue;
        }

        resultado.add((variante: variante, producto: producto));
      }
    }

    return resultado;
  }

  Future<void> cargarDetalle(int ventaId) async {
    _cargandoDetalle = true;
    _ventaDetalle = null;
    notifyListeners();
    try {
      _ventaDetalle = await _ventaService.getDetalle(ventaId);
    } on DioException catch (e) {
      _errorMessage = _parseError(e);
    }
    _cargandoDetalle = false;
    notifyListeners();
  }

// ─── Cliente de la venta actual ──────────────────────────────────────────
  int? _clienteId;
  String? _clienteNombre;
  bool _clienteYaElegido = false;

  int? get clienteId => _clienteId;
  String get clienteNombreMostrado => _clienteNombre ?? 'Público en general';
  bool get clienteYaElegido => _clienteYaElegido;

  void seleccionarCliente({int? id, String? nombre}) {
    _clienteId = id;
    _clienteNombre = nombre;
    _clienteYaElegido = true;
    notifyListeners();
  }

  void _limpiarCliente() {
    _clienteId = null;
    _clienteNombre = null;
    _clienteYaElegido = false;
  }

  // ─── Catálogo + stock ────────────────────────────────────────────────────────

  Future<void> cargarDatos({required int sucursalId}) async {
    _status = VentaStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final resultados = await Future.wait([
        _service.getProductos(),
        _service.getCategorias(),
        _cargarStock(sucursalId),
      ]);
      _productos = resultados[0] as List<ProductoModel>;
      _categorias = resultados[1] as List<CategoriaModel>;
      _status = VentaStatus.success;
    } on DioException catch (e) {
      _status = VentaStatus.error;
      _errorMessage = _parseError(e);
    } catch (e) {
      _status = VentaStatus.error;
      _errorMessage = 'Error inesperado al cargar productos';
    }
    debugPrint('🟣 cargarDatos notifyListeners final, status=$_status');
    notifyListeners();
  }

  Future<void> _cargarStock(int sucursalId) async {
    final response = await ApiClient.instance.get('/inventario/sucursales/$sucursalId/stock');
    final list = response.data as List<dynamic>;
    _stockPorVarianteId = {
      for (final row in list) (row['variante_id'] as int): double.parse(row['cantidad'].toString()),
    };
  }

  void filtrarPorCategoria(int? categoriaId) {
    _categoriaSeleccionadaId = categoriaId;
    notifyListeners();
  }

  void buscar(String query) {
    _busqueda = query;
    notifyListeners();
  }

  // ─── Carrito ──────────────────────────────────────────────────────────────
  // En Ventas el límite SIEMPRE es el stock real; allow_out_of_stock no
  // aplica aquí (esa bandera es para el futuro feature de Pedidos).

  void agregarAlCarrito(
    ProductoVarianteModel variante,
    ProductoModel producto, {
    int cantidad = 1,
  }) {
    final disponible = stockDisponible(variante.id);
    final yaEnCarrito = cantidadEnCarrito(variante.id);

    if (!variante.allowOutOfStock && yaEnCarrito + cantidad > disponible) {
      _errorMessage =
          'Solo hay ${disponible.toStringAsFixed(0)} disponibles de "${variante.nombre}".';
      notifyListeners();
      return;
    }

    final index = _carrito.indexWhere((item) => item.variante.id == variante.id);
    if (index >= 0) {
      _carrito[index] = _carrito[index].copyWith(
        cantidad: _carrito[index].cantidad + cantidad,
      );
    } else {
      _carrito
          .add(CarritoItemModel(variante: variante, productoPadre: producto, cantidad: cantidad));
    }
    notifyListeners();
  }

  void incrementar(int varianteId) {
    final index = _carrito.indexWhere((item) => item.variante.id == varianteId);
    if (index < 0) return;

    final item = _carrito[index];
    final disponible = stockDisponible(varianteId);
    if (!item.variante.allowOutOfStock && item.cantidad + 1 > disponible) {
      _errorMessage =
          'Solo hay ${disponible.toStringAsFixed(0)} disponibles de "${item.variante.nombre}".';
      notifyListeners();
      return;
    }

    _carrito[index] = _carrito[index].copyWith(cantidad: _carrito[index].cantidad + 1);
    notifyListeners();
  }

  void decrementar(int varianteId) {
    final index = _carrito.indexWhere((item) => item.variante.id == varianteId);
    if (index < 0) return;
    final nuevaCantidad = _carrito[index].cantidad - 1;
    if (nuevaCantidad <= 0) {
      _carrito.removeAt(index);
    } else {
      _carrito[index] = _carrito[index].copyWith(cantidad: nuevaCantidad);
    }
    notifyListeners();
  }

  void quitarDelCarrito(int varianteId) {
    _carrito.removeWhere((item) => item.variante.id == varianteId);
    notifyListeners();
  }

  void vaciarCarrito() {
    _carrito.clear();
    _descuentoTipo = null;
    _descuentoValor = 0;
    _descuentoAutorizadoPor = null;
    notifyListeners();
  }

  Future<bool> aplicarDescuento({
    required TipoDescuento tipo,
    required double valor,
    required String employeeNumber,
    required String pin,
  }) async {
    _errorMessage = null;
    notifyListeners();
    try {
      final nombreAdmin = await _ventaService.autorizarDescuento(employeeNumber, pin);
      _descuentoTipo = tipo;
      _descuentoValor = valor;
      _descuentoAutorizadoPor = nombreAdmin;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  void quitarDescuento() {
    _descuentoTipo = null;
    _descuentoValor = 0;
    _descuentoAutorizadoPor = null;
    notifyListeners();
  }

  void reiniciarSeleccionSucursal() {
    _sucursalId = null;
    _cajaId = null;
    _empleadoNumero = null;
    _empleadoPin = null;
    _empleadoNombreVerificado = null;
    _carrito.clear();
    _limpiarCliente();
    notifyListeners();
  }

  Future<void> cargarVentasDeLaSesion() async {
    _cargandoVentasDeLaSesion = true;
    notifyListeners();
    try {
      final raw = await _ventaService.getVentasDeLaSesion();
      _ventasDeLaSesion = raw.map((json) => CajaVentasSesionModel.fromJson(json)).toList();
    } on DioException catch (_) {
      _ventasDeLaSesion = [];
    }
    _cargandoVentasDeLaSesion = false;
    notifyListeners();
  }

  // ─── Cajas abiertas + empleado verificado ─────────────────────────────────

  Future<void> cargarCajasAbiertas() async {
    _status = VentaStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final raw = await _ventaService.getCajasAbiertas(sucursalId: _sucursalId);
      _cajasAbiertas = raw.map((json) => CajaModel.fromJson(json)).toList();
      _status = VentaStatus.success;
    } on DioException catch (e) {
      _status = VentaStatus.error;
      _errorMessage = _parseError(e);
    }
    notifyListeners();
    await cargarVentasDeLaSesion();
  }

  Future<void> cargarVentasDelDia() async {
    _cargandoVentasDelDia = true;
    notifyListeners();
    try {
      final raw = await _ventaService.getVentasDelDia();
      _ventasDelDia = raw.map((json) => CajaVentasDiaModel.fromJson(json)).toList();
    } on DioException catch (_) {
      _ventasDelDia = [];
    }
    _cargandoVentasDelDia = false;
    notifyListeners();
  }

  void seleccionarCaja(int cajaId) {
    _cajaId = cajaId;
    notifyListeners();
  }

  void cambiarCaja() {
    _inactividadTimer?.cancel();
    _cajaId = null;
    _empleadoNumero = null;
    _empleadoPin = null;
    _empleadoNombreVerificado = null;
    _carrito.clear();
    _descuentoTipo = null;
    _descuentoValor = 0;
    _descuentoAutorizadoPor = null;
    _limpiarCliente();
    notifyListeners();
  }

  Future<bool> verificarEmpleado(String employeeNumber, String pin) async {
    _verificandoEmpleado = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final nombre = await _ventaService.verificarEmpleado(employeeNumber, pin);
      _empleadoNumero = employeeNumber;
      _empleadoPin = pin;
      _empleadoNombreVerificado = nombre;
      _verificandoEmpleado = false;
      _reiniciarTimerInactividad();
      notifyListeners();
      SchedulerBinding.instance.scheduleFrame();
      return true;
    } on DioException catch (e) {
      _verificandoEmpleado = false;
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  /// Se llama ante cualquier toque dentro de la pantalla de Ventas
  /// (grid o carrito) mientras hay un empleado verificado. Reinicia el
  /// reloj de 3 minutos; si expira, se vuelve a pedir PIN sin perder la caja.
  void registrarActividad() {
    if (!empleadoVerificado) return;
    _reiniciarTimerInactividad();
  }

  void _reiniciarTimerInactividad() {
    _inactividadTimer?.cancel();
    _inactividadTimer = Timer(_tiempoInactividad, _cerrarPorInactividad);
  }

  void _cerrarPorInactividad() {
    _cajaId = null;
    _empleadoNumero = null;
    _empleadoPin = null;
    _empleadoNombreVerificado = null;
    _carrito.clear();
    _descuentoTipo = null;
    _descuentoValor = 0;
    _descuentoAutorizadoPor = null;
    _limpiarCliente();
    notifyListeners();
  }

  void seleccionarSucursal(int id) {
    _sucursalId = id;
    notifyListeners();
  }

  @override
  void dispose() {
    _inactividadTimer?.cancel();
    super.dispose();
  }

  // ─── Cobro ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> cobrar(List<Map<String, dynamic>> pagos) async {
    if (_cajaId == null || _empleadoNumero == null || _empleadoPin == null) return null;

    _cobrando = true;
    _errorMessage = null;
    notifyListeners();

    final items = _carrito
        .map((item) => {
              'producto_variante_id': item.variante.id,
              'cantidad': item.cantidad,
              'precio_unitario': item.variante.precioFinal,
              'precio_lista': item.variante.precioFinal,
              'descuento_linea': 0,
            })
        .toList();

    try {
      final venta = await _ventaService.crearVenta(
        cajaId: _cajaId!,
        employeeNumber: _empleadoNumero!,
        pin: _empleadoPin!,
        items: items,
        pagos: pagos,
        descuento: descuentoMonto,
        clienteId: _clienteId,
      );
      _carrito.clear();
      _limpiarCliente();
      _descuentoTipo = null;
      _descuentoValor = 0;
      _descuentoAutorizadoPor = null;
      _cobrando = false;

      // Al concluir la venta, regresa al listado de cajas.
      _cajaId = null;
      _empleadoNumero = null;
      _empleadoPin = null;
      _empleadoNombreVerificado = null;
      _inactividadTimer?.cancel();
      await cargarVentasDeLaSesion();
      notifyListeners();
      return venta;
    } on DioException catch (e) {
      _cobrando = false;
      _errorMessage = _parseError(e);
      notifyListeners();
      return null;
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  String _parseError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final message = data['message'];
      if (message != null) return message.toString();
    }
    return 'Error de conexión. Intenta de nuevo.';
  }

  Future<void> reimprimirTicket(int ventaId) async {
    try {
      if (kIsWeb) {
        final nuevaVentana = web.window.open('', '_blank');
        final bytes = await _ventaService.descargarTicketPdf(ventaId, reimpresion: true);
        final blobParts = [Uint8List.fromList(bytes).toJS].toJS;
        final blob = web.Blob(blobParts, web.BlobPropertyBag(type: 'application/pdf'));
        final url = web.URL.createObjectURL(blob);
        nuevaVentana?.location.href = url;
      } else {
        final bytes = await _ventaService.descargarTicketPdf(ventaId, reimpresion: true);
        await Printing.layoutPdf(onLayout: (_) async => Uint8List.fromList(bytes));
      }
    } catch (e) {
      _errorMessage = 'No se pudo abrir el ticket';
      notifyListeners();
    }
  }

  Future<bool> cancelarVenta({
    required int ventaId,
    required String employeeNumber,
    required String pin,
    required int metodoDevolucionId,
    required double montoDevuelto,
    String? motivo,
    required List<Map<String, dynamic>> itemsDevueltos,
  }) async {
    _cancelando = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _ventaService.cancelarVenta(
        ventaId: ventaId,
        employeeNumber: employeeNumber,
        pin: pin,
        metodoDevolucionId: metodoDevolucionId,
        montoDevuelto: montoDevuelto,
        motivo: motivo,
        itemsDevueltos: itemsDevueltos,
      );
      _cancelando = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _cancelando = false;
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> imprimirTicketCancelacion(int ventaId) async {
    try {
      if (kIsWeb) {
        final nuevaVentana = web.window.open('', '_blank');
        final bytes = await _ventaService.descargarTicketCancelacionPdf(ventaId);
        final blobParts = [Uint8List.fromList(bytes).toJS].toJS;
        final blob = web.Blob(blobParts, web.BlobPropertyBag(type: 'application/pdf'));
        final url = web.URL.createObjectURL(blob);
        nuevaVentana?.location.href = url;
      } else {
        final bytes = await _ventaService.descargarTicketCancelacionPdf(ventaId);
        await Printing.layoutPdf(onLayout: (_) async => Uint8List.fromList(bytes));
      }
    } catch (e) {
      _errorMessage = 'No se pudo abrir el comprobante de cancelación';
      notifyListeners();
    }
  }
}
