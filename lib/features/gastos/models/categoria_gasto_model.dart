class CategoriaGastoModel {
  final int id;
  final String nombre;
  final String slug;
  final String? icono;
  final String? color;
  final bool activo;

  const CategoriaGastoModel({
    required this.id,
    required this.nombre,
    required this.slug,
    this.icono,
    this.color,
    this.activo = true,
  });

  factory CategoriaGastoModel.fromJson(Map<String, dynamic> json) {
    return CategoriaGastoModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      slug: json['slug'] as String,
      icono: json['icono'] as String?,
      color: json['color'] as String?,
      activo: switch (json['activo']) {
        bool b => b,
        int i => i == 1,
        _ => true,
      },
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'nombre': nombre,
      if (icono != null) 'icono': icono,
      if (color != null) 'color': color,
    };
  }
}
