class MetodoPagoModel {
  final int id;
  final String nombre;
  final bool activo;
  final bool isDeletable;
  final bool requiereReferencia;

  final String? icono;
  final String? color;

  MetodoPagoModel({
    required this.id,
    required this.nombre,
    required this.activo,
    required this.isDeletable,
    required this.requiereReferencia,
    this.icono,
    this.color,
  });

  factory MetodoPagoModel.fromJson(Map<String, dynamic> json) {
    return MetodoPagoModel(
      id: json['id'],
      nombre: json['nombre'],
      activo: json['activo'] ?? true,
      isDeletable: json['is_deletable'] ?? true,
      requiereReferencia: json['requiere_referencia'] ?? false,
    );
  }
}
