import 'package:ventro_app/features/caja/models/corte_caja_model.dart';

class VentaResumenModel {
  final int id;
  final String numeroTicketCompleto;
  final double total;
  final String cajero;
  final List<MetodoPagoResumenModel> metodosPago;
  final String hora;
  final String estado;
  final VentaDevolucionResumenModel? devolucion;

  const VentaResumenModel({
    required this.id,
    required this.numeroTicketCompleto,
    required this.total,
    required this.cajero,
    required this.metodosPago,
    required this.hora,
    required this.estado,
    this.devolucion,
  });

  factory VentaResumenModel.fromJson(Map<String, dynamic> json) {
    return VentaResumenModel(
      id: json['id'],
      numeroTicketCompleto: json['numero_ticket_completo'] ?? '—',
      total: double.parse(json['total'].toString()),
      cajero: json['cajero'] ?? '—',
      metodosPago: (json['metodos_pago'] as List<dynamic>? ?? [])
          .map((m) => MetodoPagoResumenModel.fromJson(Map<String, dynamic>.from(m)))
          .toList(),
      hora: json['hora'] ?? '',
      estado: json['estado'] ?? 'completada',
      devolucion: json['devolucion'] != null
          ? VentaDevolucionResumenModel.fromJson(Map<String, dynamic>.from(json['devolucion']))
          : null,
    );
  }
}

class CajaVentasDiaModel {
  final int cajaId;
  final String cajaNombre;
  final String abiertaPor;
  final List<VentaResumenModel> ventas;
  final double totalDia;

  const CajaVentasDiaModel({
    required this.cajaId,
    required this.cajaNombre,
    required this.abiertaPor,
    required this.ventas,
    required this.totalDia,
  });

  factory CajaVentasDiaModel.fromJson(Map<String, dynamic> json) {
    return CajaVentasDiaModel(
      cajaId: json['caja_id'],
      cajaNombre: json['caja_nombre'],
      abiertaPor: json['abierta_por'] ?? '—',
      ventas: (json['ventas'] as List<dynamic>? ?? [])
          .map((v) => VentaResumenModel.fromJson(v))
          .toList(),
      totalDia: double.parse(json['total_dia'].toString()),
    );
  }
}

class MetodoPagoResumenModel {
  final int id;
  final String nombre;
  final String? icono;
  final String? color;

  const MetodoPagoResumenModel({
    required this.id,
    required this.nombre,
    this.icono,
    this.color,
  });

  factory MetodoPagoResumenModel.fromJson(Map<String, dynamic> json) {
    return MetodoPagoResumenModel(
      id: json['id'],
      nombre: json['nombre'],
      icono: json['icono'],
      color: json['color'],
    );
  }
}

class CajaVentasSesionModel {
  final int cajaId;
  final String cajaNombre;
  final String abiertaPor;
  final List<VentaResumenModel> ventas;
  final double totalSesion;
  final List<TotalMetodoPagoModel> totalesPorMetodo;
  final double efectivoEsperado;
  final double efectivoCobradoBruto;

  const CajaVentasSesionModel({
    required this.cajaId,
    required this.cajaNombre,
    required this.abiertaPor,
    required this.ventas,
    required this.totalSesion,
    required this.totalesPorMetodo,
    required this.efectivoEsperado,
    required this.efectivoCobradoBruto,
  });

  factory CajaVentasSesionModel.fromJson(Map<String, dynamic> json) {
    return CajaVentasSesionModel(
      cajaId: json['caja_id'],
      cajaNombre: json['caja_nombre'],
      abiertaPor: json['abierta_por'] ?? '—',
      ventas: (json['ventas'] as List<dynamic>? ?? [])
          .map((v) => VentaResumenModel.fromJson(v))
          .toList(),
      totalSesion: double.parse(json['total_sesion'].toString()),
      totalesPorMetodo: (json['totales_por_metodo'] as List<dynamic>? ?? [])
          .map((m) => TotalMetodoPagoModel.fromJson(Map<String, dynamic>.from(m)))
          .toList(),
      efectivoEsperado: double.parse((json['efectivo_esperado'] ?? 0).toString()),
      efectivoCobradoBruto: double.parse((json['efectivo_cobrado_bruto'] ?? 0).toString()),
    );
  }
}

class VentaDevolucionResumenModel {
  final double montoDevuelto;
  final String metodo;
  final String? motivo;

  const VentaDevolucionResumenModel({
    required this.montoDevuelto,
    required this.metodo,
    this.motivo,
  });

  factory VentaDevolucionResumenModel.fromJson(Map<String, dynamic> json) {
    return VentaDevolucionResumenModel(
      montoDevuelto: double.parse(json['monto_devuelto'].toString()),
      metodo: json['metodo'] ?? '—',
      motivo: json['motivo'],
    );
  }
}
