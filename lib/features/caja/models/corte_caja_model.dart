import 'package:ventro_app/features/ventas/models/venta_dia_model.dart';

class TotalMetodoPagoModel {
  final int? id;
  final String metodo;
  final double total;
  final String? icono;
  final String? color;

  const TotalMetodoPagoModel({
    this.id,
    required this.metodo,
    required this.total,
    this.icono,
    this.color,
  });

  factory TotalMetodoPagoModel.fromJson(Map<String, dynamic> json) {
    return TotalMetodoPagoModel(
      id: json['id'],
      metodo: json['metodo'],
      total: double.parse(json['total'].toString()),
      icono: json['icono'],
      color: json['color'],
    );
  }
}

class VentaCanceladaResumenModel {
  final int id;
  final String numeroTicket;
  final double total;
  final String? canceladaEn;
  final VentaDevolucionResumenModel? devolucion;

  const VentaCanceladaResumenModel({
    required this.id,
    required this.numeroTicket,
    required this.total,
    this.canceladaEn,
    this.devolucion,
  });

  factory VentaCanceladaResumenModel.fromJson(Map<String, dynamic> json) {
    return VentaCanceladaResumenModel(
      id: json['id'],
      numeroTicket: json['numero_ticket']?.toString() ?? '—',
      total: double.parse(json['total'].toString()),
      canceladaEn: json['cancelada_en'],
      devolucion: json['devolucion'] != null
          ? VentaDevolucionResumenModel.fromJson(Map<String, dynamic>.from(json['devolucion']))
          : null,
    );
  }

  /// Una cancelación es "total" cuando se devolvió el 100% del monto de la
  /// venta. Si se devolvió menos, fue una devolución parcial.
  bool get esCancelacionTotal {
    final dev = devolucion;
    if (dev == null) return true;
    return dev.montoDevuelto >= total - 0.01;
  }

  double get montoConservado => total - (devolucion?.montoDevuelto ?? 0);
}

class CorteCajaModel {
  final int? corteId;
  final double montoInicial;
  final double efectivoVentas;
  final double efectivoEsperado;
  final List<TotalMetodoPagoModel> totalesPorMetodo;
  final double totalVentas;
  final int cantidadVentas;
  final List<VentaCanceladaResumenModel> ventasCanceladas;
  final double? efectivoContado;
  final double? diferencia;
  final String? status;

  const CorteCajaModel({
    this.corteId,
    required this.montoInicial,
    required this.efectivoVentas,
    required this.efectivoEsperado,
    required this.totalesPorMetodo,
    required this.totalVentas,
    required this.cantidadVentas,
    required this.ventasCanceladas,
    this.efectivoContado,
    this.diferencia,
    this.status,
  });

  factory CorteCajaModel.fromJson(Map<String, dynamic> json) {
    return CorteCajaModel(
      corteId: json['corte_id'],
      montoInicial: double.parse(json['monto_inicial'].toString()),
      efectivoVentas: double.parse(json['efectivo_ventas'].toString()),
      efectivoEsperado: double.parse(json['efectivo_esperado'].toString()),
      totalesPorMetodo: (json['totales_por_metodo'] as List<dynamic>? ?? [])
          .map((m) => TotalMetodoPagoModel.fromJson(Map<String, dynamic>.from(m)))
          .toList(),
      totalVentas: double.parse(json['total_ventas'].toString()),
      cantidadVentas: json['cantidad_ventas'] ?? 0,
      ventasCanceladas: (json['ventas_canceladas'] as List<dynamic>? ?? [])
          .map((v) => VentaCanceladaResumenModel.fromJson(Map<String, dynamic>.from(v)))
          .toList(),
      efectivoContado: json['efectivo_contado'] != null
          ? double.parse(json['efectivo_contado'].toString())
          : null,
      diferencia: json['diferencia'] != null ? double.parse(json['diferencia'].toString()) : null,
      status: json['status'],
    );
  }
}
