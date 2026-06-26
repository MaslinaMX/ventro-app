import 'package:ventro_app/features/auth/models/user_model.dart';
import 'package:ventro_app/features/metodos_pago/models/metodo_pago_model.dart';
import 'package:ventro_app/features/settings/models/sucursal_model.dart';

import 'categoria_gasto_model.dart';
import 'gasto_historial_model.dart';

class GastoModel {
  final int id;
  final int sucursalId;
  final int categoriaId;
  final int metodoPagoId;
  final int userId;
  final String concepto;
  final double monto;
  final DateTime fecha;
  final String? proveedor;
  final String? comprobanteUrl;
  final String? notas;
  final CategoriaGastoModel? categoria;
  final MetodoPagoModel? metodoPago;
  final SucursalModel? sucursal;
  final UserModel? user;
  final List<GastoHistorialModel> historial;

  const GastoModel({
    required this.id,
    required this.sucursalId,
    required this.categoriaId,
    required this.metodoPagoId,
    required this.userId,
    required this.concepto,
    required this.monto,
    required this.fecha,
    this.proveedor,
    this.comprobanteUrl,
    this.notas,
    this.categoria,
    this.metodoPago,
    this.sucursal,
    this.user,
    this.historial = const [],
  });

  factory GastoModel.fromJson(Map<String, dynamic> json) {
    return GastoModel(
      id: json['id'] as int,
      sucursalId: json['sucursal_id'] as int,
      categoriaId: json['categoria_id'] as int,
      metodoPagoId: json['metodo_pago_id'] as int,
      userId: json['user_id'] as int,
      concepto: json['concepto'] as String,
      monto: double.parse(json['monto'].toString()),
      fecha: DateTime.parse(json['fecha'] as String),
      proveedor: json['proveedor'] as String?,
      comprobanteUrl: json['comprobante_url'] as String?,
      notas: json['notas'] as String?,
      categoria: json['categoria'] != null
          ? CategoriaGastoModel.fromJson(json['categoria'] as Map<String, dynamic>)
          : null,
      metodoPago: json['metodo_pago'] != null
          ? MetodoPagoModel.fromJson(json['metodo_pago'] as Map<String, dynamic>)
          : null,
      sucursal: json['sucursal'] != null
          ? SucursalModel.fromJson(json['sucursal'] as Map<String, dynamic>)
          : null,
      user: json['user'] != null ? UserModel.fromJson(json['user'] as Map<String, dynamic>) : null,
      historial: (json['historial'] as List<dynamic>? ?? [])
          .map((h) => GastoHistorialModel.fromJson(h as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Payload para crear un gasto nuevo (POST /gastos).
  /// No incluye user_id — el backend lo asigna del usuario autenticado.
  Map<String, dynamic> toCreateJson() {
    return {
      'sucursal_id': sucursalId,
      'categoria_id': categoriaId,
      'metodo_pago_id': metodoPagoId,
      'concepto': concepto,
      'monto': monto,
      'fecha': fecha.toIso8601String().split('T').first,
      if (proveedor != null) 'proveedor': proveedor,
      if (comprobanteUrl != null) 'comprobante_url': comprobanteUrl,
      if (notas != null) 'notas': notas,
    };
  }

  bool get fueEditado => historial.isNotEmpty;
}
