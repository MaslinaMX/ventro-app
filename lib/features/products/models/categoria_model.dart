class CategoriaModel {
  final int id;
  final String nombre;
  final String slug;
  final String? descripcion;
  final String? imagen;
  final String? icono;
  final String? color;
  final int? parentId;
  final bool activo;

  const CategoriaModel({
    required this.id,
    required this.nombre,
    required this.slug,
    this.descripcion,
    this.imagen,
    this.icono,
    this.color,
    this.parentId,
    this.activo = true,
  });

  factory CategoriaModel.fromJson(Map<String, dynamic> json) {
    return CategoriaModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      slug: json['slug'] as String,
      descripcion: json['descripcion'] as String?,
      imagen: json['imagen'] as String?,
      icono: json['icono'] as String?,
      color: json['color'] as String?,
      parentId: json['parent_id'] as int?,
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
      if (descripcion != null) 'descripcion': descripcion,
      if (parentId != null) 'parent_id': parentId,
      if (icono != null) 'icono': icono,
      if (color != null) 'color': color,
    };
  }
}
