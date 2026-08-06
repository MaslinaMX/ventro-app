// V1

/// Info del negocio para el header del catálogo público — nombre, logo, y
/// contacto de la sucursal principal. Espejo de lo que regresa
/// CatalogoPublicoController::negocio() en el backend.
class NegocioPublicoModel {
  final String nombre;
  final String? logo;
  final ContactoNegocioModel? contacto;

  NegocioPublicoModel({
    required this.nombre,
    this.logo,
    this.contacto,
  });

  factory NegocioPublicoModel.fromJson(Map<String, dynamic> json) {
    return NegocioPublicoModel(
      nombre: json['nombre'] as String,
      logo: json['logo'] as String?,
      contacto: json['contacto'] != null
          ? ContactoNegocioModel.fromJson(json['contacto'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ContactoNegocioModel {
  final String? direccion;
  final String? ciudad;
  final String? estado;
  final String? telefono;
  final String? email;
  final String? sitioWeb;

  ContactoNegocioModel({
    this.direccion,
    this.ciudad,
    this.estado,
    this.telefono,
    this.email,
    this.sitioWeb,
  });

  factory ContactoNegocioModel.fromJson(Map<String, dynamic> json) {
    return ContactoNegocioModel(
      direccion: json['direccion'] as String?,
      ciudad: json['ciudad'] as String?,
      estado: json['estado'] as String?,
      telefono: json['telefono'] as String?,
      email: json['email'] as String?,
      sitioWeb: json['sitio_web'] as String?,
    );
  }
}
