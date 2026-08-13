class CompraResumenModel {
  final int id;
  final String numeroTicketCompleto;
  final String fecha;
  final double total;
  final String estado;

  const CompraResumenModel({
    required this.id,
    required this.numeroTicketCompleto,
    required this.fecha,
    required this.total,
    required this.estado,
  });

  factory CompraResumenModel.fromJson(Map<String, dynamic> json) {
    return CompraResumenModel(
      id: json['id'],
      numeroTicketCompleto: json['numero_ticket_completo'] ?? '—',
      fecha: json['fecha'] ?? '',
      total: double.parse(json['total'].toString()),
      estado: json['estado'] ?? 'completada',
    );
  }
}

class ClienteEstadisticasModel {
  final String clienteNombre;
  final double totalGastado;
  final int numeroCompras;
  final double promedioCompra;
  final String? ultimaCompra;
  final String? productoFavorito;
  final List<CompraResumenModel> compras;

  const ClienteEstadisticasModel({
    required this.clienteNombre,
    required this.totalGastado,
    required this.numeroCompras,
    required this.promedioCompra,
    this.ultimaCompra,
    this.productoFavorito,
    required this.compras,
  });

  factory ClienteEstadisticasModel.fromJson(Map<String, dynamic> json) {
    return ClienteEstadisticasModel(
      clienteNombre: json['cliente']?['nombre'] ?? '—',
      totalGastado: double.parse((json['total_gastado'] ?? 0).toString()),
      numeroCompras: json['numero_compras'] ?? 0,
      promedioCompra: double.parse((json['promedio_compra'] ?? 0).toString()),
      ultimaCompra: json['ultima_compra'],
      productoFavorito: json['producto_favorito'],
      compras: (json['compras'] as List<dynamic>? ?? [])
          .map((c) => CompraResumenModel.fromJson(Map<String, dynamic>.from(c)))
          .toList(),
    );
  }
}
