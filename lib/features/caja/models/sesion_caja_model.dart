class SesionCajaModel {
  final int id;
  final int cajaId;
  final int usuarioId;
  final String? usuarioNombre;
  final double montoInicial;
  final double? montoFinalEsperado;
  final double? montoFinalContado;
  final double? diferencia;
  final String estado; // 'abierta' | 'cerrada'
  final DateTime abiertaEn;
  final DateTime? cerradaEn;

  SesionCajaModel({
    required this.id,
    required this.cajaId,
    required this.usuarioId,
    this.usuarioNombre,
    required this.montoInicial,
    this.montoFinalEsperado,
    this.montoFinalContado,
    this.diferencia,
    required this.estado,
    required this.abiertaEn,
    this.cerradaEn,
  });

  bool get isAbierta => estado == 'abierta';

  factory SesionCajaModel.fromJson(Map<String, dynamic> json) {
    return SesionCajaModel(
      id: json['id'],
      cajaId: json['caja_id'],
      usuarioId: json['usuario_id'],
      usuarioNombre: json['usuario']?['name'],
      montoInicial: double.parse(json['monto_inicial'].toString()),
      montoFinalEsperado: json['monto_final_esperado'] != null
          ? double.parse(json['monto_final_esperado'].toString())
          : null,
      montoFinalContado: json['monto_final_contado'] != null
          ? double.parse(json['monto_final_contado'].toString())
          : null,
      diferencia: json['diferencia'] != null ? double.parse(json['diferencia'].toString()) : null,
      estado: json['estado'],
      abiertaEn: DateTime.parse(json['abierta_en']),
      cerradaEn: json['cerrada_en'] != null ? DateTime.parse(json['cerrada_en']) : null,
    );
  }
}
