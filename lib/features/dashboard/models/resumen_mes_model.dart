class ResumenMesModel {
  final double vendido;
  final double gastado;
  final double neto;

  const ResumenMesModel({
    required this.vendido,
    required this.gastado,
    required this.neto,
  });

  factory ResumenMesModel.fromJson(Map<String, dynamic> json) {
    return ResumenMesModel(
      vendido: double.parse(json['vendido'].toString()),
      gastado: double.parse(json['gastado'].toString()),
      neto: double.parse(json['neto'].toString()),
    );
  }
}
