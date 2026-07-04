import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:ventro_app/features/ventas/models/venta_admin_model.dart';
import 'package:ventro_app/features/ventas/models/resumen_ventas_admin_model.dart';
import 'package:ventro_app/features/ventas/services/venta_service.dart';

class TodasVentasController extends ChangeNotifier {
  final VentaService _service = VentaService();

  bool _cargando = false;
  String? _errorMessage;
  List<VentaAdminModel> _ventas = [];
  ResumenVentasAdminModel? _resumen;

  int? _sucursalId;
  String _buscar = '';
  String? _mes; // formato 'YYYY-MM'; null = todas las fechas

  bool get cargando => _cargando;
  String? get errorMessage => _errorMessage;
  List<VentaAdminModel> get ventas => List.unmodifiable(_ventas);
  ResumenVentasAdminModel? get resumen => _resumen;
  int? get sucursalId => _sucursalId;
  String get buscar => _buscar;
  String? get mes => _mes;

  Future<void> cargarVentas() async {
    _cargando = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final data = await _service.getTodasLasVentas(
        sucursalId: _sucursalId,
        buscar: _buscar,
        mes: _mes,
      );
      final rawVentas = (data['ventas'] as List<dynamic>).cast<Map<String, dynamic>>();
      _ventas = rawVentas.map((json) => VentaAdminModel.fromJson(json)).toList();
      _resumen = ResumenVentasAdminModel.fromJson(
        Map<String, dynamic>.from(data['resumen'] ?? {}),
      );
    } on DioException catch (e) {
      final errData = e.response?.data;
      _errorMessage = (errData is Map && errData['message'] != null)
          ? errData['message'].toString()
          : 'Error de conexión. Intenta de nuevo.';
    }
    _cargando = false;
    notifyListeners();
  }

  Future<void> filtrarPorSucursal(int? sucursalId) async {
    _sucursalId = sucursalId;
    await cargarVentas();
  }

  Future<void> buscarPorTicket(String termino) async {
    _buscar = termino;
    await cargarVentas();
  }

  Future<void> filtrarPorMes(String? mes) async {
    _mes = mes;
    await cargarVentas();
  }
}
