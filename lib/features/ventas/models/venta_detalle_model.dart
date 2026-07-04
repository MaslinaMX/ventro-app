class VentaDetalleModel {
  final int id;
  final String numeroTicketCompleto;
  final String fecha;
  final String cajero;
  final String caja;
  final String sucursal;
  final String estado;
  final double subtotal;
  final double baseGravable;
  final double descuento;
  final double ivaTotal;
  final double iepsTotal;
  final double total;
  final List<VentaDetalleItemModel> items;
  final List<VentaDetallePagoModel> pagos;

  const VentaDetalleModel({
    required this.id,
    required this.numeroTicketCompleto,
    required this.fecha,
    required this.cajero,
    required this.caja,
    required this.sucursal,
    required this.estado,
    required this.subtotal,
    required this.baseGravable,
    required this.descuento,
    required this.ivaTotal,
    required this.iepsTotal,
    required this.total,
    required this.items,
    required this.pagos,
  });

  factory VentaDetalleModel.fromJson(Map<String, dynamic> json) {
    return VentaDetalleModel(
      id: json['id'],
      numeroTicketCompleto: json['numero_ticket_completo'] ?? '—',
      fecha: json['fecha'] ?? '—',
      cajero: json['cajero'] ?? '—',
      caja: json['caja'] ?? '—',
      sucursal: json['sucursal'] ?? '—',
      estado: json['estado'] ?? '—',
      subtotal: double.parse(json['subtotal'].toString()),
      baseGravable: double.parse((json['base_gravable'] ?? json['subtotal']).toString()),
      descuento: double.parse(json['descuento'].toString()),
      ivaTotal: double.parse(json['iva_total'].toString()),
      iepsTotal: double.parse(json['ieps_total'].toString()),
      total: double.parse(json['total'].toString()),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((i) => VentaDetalleItemModel.fromJson(Map<String, dynamic>.from(i)))
          .toList(),
      pagos: (json['pagos'] as List<dynamic>? ?? [])
          .map((p) => VentaDetallePagoModel.fromJson(Map<String, dynamic>.from(p)))
          .toList(),
    );
  }
}

class VentaDetalleItemModel {
  final int id;
  final String nombreSnapshot;
  final int cantidad;
  final double precioUnitario;
  final double descuentoLinea;
  final double ivaMonto;
  final double iepsMonto;
  final double subtotal;

  const VentaDetalleItemModel({
    required this.id,
    required this.nombreSnapshot,
    required this.cantidad,
    required this.precioUnitario,
    required this.descuentoLinea,
    required this.ivaMonto,
    required this.iepsMonto,
    required this.subtotal,
  });

  factory VentaDetalleItemModel.fromJson(Map<String, dynamic> json) {
    return VentaDetalleItemModel(
      id: json['id'],
      nombreSnapshot: json['nombre_snapshot'] ?? '—',
      cantidad: json['cantidad'],
      precioUnitario: double.parse(json['precio_unitario'].toString()),
      descuentoLinea: double.parse(json['descuento_linea'].toString()),
      ivaMonto: double.parse(json['iva_monto'].toString()),
      iepsMonto: double.parse(json['ieps_monto'].toString()),
      subtotal: double.parse(json['subtotal'].toString()),
    );
  }
}

class VentaDetallePagoModel {
  final int id;
  final String metodo;
  final String? icono;
  final String? color;
  final double monto;
  final double? recibido;
  final double? cambio;
  final String? referencia;

  const VentaDetallePagoModel({
    required this.id,
    required this.metodo,
    this.icono,
    this.color,
    required this.monto,
    this.recibido,
    this.cambio,
    this.referencia,
  });

  factory VentaDetallePagoModel.fromJson(Map<String, dynamic> json) {
    return VentaDetallePagoModel(
      id: json['id'],
      metodo: json['metodo'] ?? '—',
      icono: json['icono'],
      color: json['color'],
      monto: double.parse(json['monto'].toString()),
      recibido: json['recibido'] != null ? double.parse(json['recibido'].toString()) : null,
      cambio: json['cambio'] != null ? double.parse(json['cambio'].toString()) : null,
      referencia: json['referencia'],
    );
  }
}
