enum MovimientoType { in_, out }

extension MovimientoTypeExt on MovimientoType {
  String get value => this == MovimientoType.in_ ? 'in' : 'out';

  static MovimientoType fromString(String v) => v == 'in' ? MovimientoType.in_ : MovimientoType.out;
}

enum MovimientoReason { ajuste, compra, venta, merma, devolucion, transferencia }

extension MovimientoReasonExt on MovimientoReason {
  String get value => name;

  String get label => switch (this) {
        MovimientoReason.ajuste => 'Ajuste',
        MovimientoReason.compra => 'Compra',
        MovimientoReason.venta => 'Venta',
        MovimientoReason.merma => 'Merma',
        MovimientoReason.devolucion => 'Devolución',
        MovimientoReason.transferencia => 'Transferencia',
      };

  static MovimientoReason fromString(String v) => MovimientoReason.values.firstWhere(
        (e) => e.name == v,
        orElse: () => MovimientoReason.ajuste,
      );
}

class MovimientoInventarioModel {
  final int id;
  final int varianteId;
  final String? varianteNombre;
  final String? productoNombre;
  final int sucursalId;
  final String? sucursalNombre;
  final String? userNombre;
  final MovimientoType type;
  final MovimientoReason reason;
  final double cantidad;
  final double stockAnterior;
  final double stockNuevo;
  final String? notas;
  final DateTime createdAt;

  const MovimientoInventarioModel({
    required this.id,
    required this.varianteId,
    this.varianteNombre,
    this.productoNombre,
    required this.sucursalId,
    this.sucursalNombre,
    this.userNombre,
    required this.type,
    required this.reason,
    required this.cantidad,
    required this.stockAnterior,
    required this.stockNuevo,
    this.notas,
    required this.createdAt,
  });

  factory MovimientoInventarioModel.fromJson(Map<String, dynamic> j) {
    return MovimientoInventarioModel(
      id: j['id'],
      varianteId: j['variante_id'],
      varianteNombre: j['variante']?['nombre'],
      productoNombre: j['variante']?['producto']?['nombre'],
      sucursalId: j['sucursal_id'],
      sucursalNombre: j['sucursal']?['nombre'],
      userNombre: j['user']?['name'],
      type: MovimientoTypeExt.fromString(j['type']),
      reason: MovimientoReasonExt.fromString(j['reason']),
      cantidad: double.tryParse('${j['cantidad'] ?? 0}') ?? 0,
      stockAnterior: double.tryParse('${j['stock_anterior'] ?? 0}') ?? 0,
      stockNuevo: double.tryParse('${j['stock_nuevo'] ?? 0}') ?? 0,
      notas: j['notas'],
      createdAt: DateTime.tryParse(j['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
