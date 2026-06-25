class CajaModel {
  final int id;
  final String nombre;
  final int sucursalId;
  final String? sucursalNombre;
  final bool activa;
  final bool isDeletable;
  final String? abiertaPorNombre;

  CajaModel({
    required this.id,
    required this.nombre,
    required this.sucursalId,
    this.sucursalNombre,
    required this.activa,
    required this.isDeletable,
    this.abiertaPorNombre,
  });

  bool get tieneSesionAbierta => abiertaPorNombre != null;

  factory CajaModel.fromJson(Map<String, dynamic> json) {
    final sesionActiva = json['sesion_activa'];
    String? abiertaPor;
    if (sesionActiva != null && sesionActiva is Map && sesionActiva['usuario'] != null) {
      abiertaPor = sesionActiva['usuario']['name'];
    }

    return CajaModel(
      id: json['id'],
      nombre: json['nombre'],
      sucursalId: json['sucursal_id'],
      sucursalNombre: json['sucursal']?['nombre'],
      activa: json['activa'] ?? true,
      isDeletable: json['is_deletable'] ?? true,
      abiertaPorNombre: abiertaPor,
    );
  }
}
