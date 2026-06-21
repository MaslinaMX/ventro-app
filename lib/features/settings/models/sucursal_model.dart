class SucursalModel {
  final int id;
  final String nombre;
  final String? direccion;
  final String? direccion2;
  final String? ciudad;
  final String? estado;
  final String? codigoPostal;
  final String? pais;
  final String? telefono;
  final String? telefonoAlternativo;
  final String? email;
  final String? sitioWeb;
  final String? rfc;
  final bool activa;
  final bool isMain;
  final bool isDeletable;

  SucursalModel({
    required this.id,
    required this.nombre,
    this.direccion,
    this.direccion2,
    this.ciudad,
    this.estado,
    this.codigoPostal,
    this.pais,
    this.telefono,
    this.telefonoAlternativo,
    this.email,
    this.sitioWeb,
    this.rfc,
    required this.activa,
    required this.isMain,
    required this.isDeletable,
  });

  factory SucursalModel.fromJson(Map<String, dynamic> json) {
    return SucursalModel(
      id: json['id'],
      nombre: json['nombre'],
      direccion: json['direccion'],
      direccion2: json['direccion_2'],
      ciudad: json['ciudad'],
      estado: json['estado'],
      codigoPostal: json['codigo_postal'],
      pais: json['pais'],
      telefono: json['telefono'],
      telefonoAlternativo: json['telefono_alternativo'],
      email: json['email'],
      sitioWeb: json['sitio_web'],
      rfc: json['rfc'],
      activa: json['activa'] ?? true,
      isMain: json['is_main'] ?? false,
      isDeletable: json['is_deletable'] ?? true,
    );
  }
}
