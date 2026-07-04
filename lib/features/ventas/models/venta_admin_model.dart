class VentaAdminModel {
  final int id;
  final String numeroTicketCompleto;
  final String fecha;
  final double total;
  final String estado;
  final String cajero;
  final String sucursal;

  const VentaAdminModel({
    required this.id,
    required this.numeroTicketCompleto,
    required this.fecha,
    required this.total,
    required this.estado,
    required this.cajero,
    required this.sucursal,
  });

  factory VentaAdminModel.fromJson(Map<String, dynamic> json) {
    return VentaAdminModel(
      id: json['id'],
      numeroTicketCompleto: json['numero_ticket_completo'] ?? '—',
      fecha: json['fecha'] ?? '—',
      total: double.parse(json['total'].toString()),
      estado: json['estado'] ?? '—',
      cajero: json['cajero'] ?? '—',
      sucursal: json['sucursal'] ?? '—',
    );
  }
}
