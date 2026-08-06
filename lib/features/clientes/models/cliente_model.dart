enum TipoCliente { personaFisica, personaMoral }

extension TipoClienteX on TipoCliente {
  String get value => switch (this) {
        TipoCliente.personaFisica => 'persona_fisica',
        TipoCliente.personaMoral => 'persona_moral',
      };

  String get label => switch (this) {
        TipoCliente.personaFisica => 'Persona física',
        TipoCliente.personaMoral => 'Persona moral',
      };

  static TipoCliente fromValue(String value) => switch (value) {
        'persona_moral' => TipoCliente.personaMoral,
        _ => TipoCliente.personaFisica,
      };
}

class ClienteModel {
  final int id;
  final String nombre;
  final TipoCliente tipo;

  final String? telefono;
  final String? email;

  final String? direccion;
  final String? ciudad;
  final String? estado;
  final String? codigoPostal;

  final String? rfc;
  final String? razonSocial;
  final String? regimenFiscal;
  final String? usoCfdi;

  final String? notas;
  final bool activo;

  ClienteModel({
    required this.id,
    required this.nombre,
    required this.tipo,
    this.telefono,
    this.email,
    this.direccion,
    this.ciudad,
    this.estado,
    this.codigoPostal,
    this.rfc,
    this.razonSocial,
    this.regimenFiscal,
    this.usoCfdi,
    this.notas,
    this.activo = true,
  });

  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    return ClienteModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      tipo: TipoClienteX.fromValue(json['tipo'] as String? ?? 'persona_fisica'),
      telefono: json['telefono'] as String?,
      email: json['email'] as String?,
      direccion: json['direccion'] as String?,
      ciudad: json['ciudad'] as String?,
      estado: json['estado'] as String?,
      codigoPostal: json['codigo_postal'] as String?,
      rfc: json['rfc'] as String?,
      razonSocial: json['razon_social'] as String?,
      regimenFiscal: json['regimen_fiscal'] as String?,
      usoCfdi: json['uso_cfdi'] as String?,
      notas: json['notas'] as String?,
      activo: json['activo'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'tipo': tipo.value,
      'telefono': telefono,
      'email': email,
      'direccion': direccion,
      'ciudad': ciudad,
      'estado': estado,
      'codigo_postal': codigoPostal,
      'rfc': rfc,
      'razon_social': razonSocial,
      'regimen_fiscal': regimenFiscal,
      'uso_cfdi': usoCfdi,
      'notas': notas,
      'activo': activo,
    };
  }

  ClienteModel copyWith({
    String? nombre,
    TipoCliente? tipo,
    String? telefono,
    String? email,
    String? direccion,
    String? ciudad,
    String? estado,
    String? codigoPostal,
    String? rfc,
    String? razonSocial,
    String? regimenFiscal,
    String? usoCfdi,
    String? notas,
    bool? activo,
  }) {
    return ClienteModel(
      id: id,
      nombre: nombre ?? this.nombre,
      tipo: tipo ?? this.tipo,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      direccion: direccion ?? this.direccion,
      ciudad: ciudad ?? this.ciudad,
      estado: estado ?? this.estado,
      codigoPostal: codigoPostal ?? this.codigoPostal,
      rfc: rfc ?? this.rfc,
      razonSocial: razonSocial ?? this.razonSocial,
      regimenFiscal: regimenFiscal ?? this.regimenFiscal,
      usoCfdi: usoCfdi ?? this.usoCfdi,
      notas: notas ?? this.notas,
      activo: activo ?? this.activo,
    );
  }
}
