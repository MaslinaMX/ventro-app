class ResumenVentasAdminModel {
  final int ventasCount;
  final double ventasTotal;
  final int canceladasCount;
  final double canceladasTotal;

  const ResumenVentasAdminModel({
    required this.ventasCount,
    required this.ventasTotal,
    required this.canceladasCount,
    required this.canceladasTotal,
  });

  factory ResumenVentasAdminModel.fromJson(Map<String, dynamic> json) {
    return ResumenVentasAdminModel(
      ventasCount: json['ventas_count'] ?? 0,
      ventasTotal: double.parse((json['ventas_total'] ?? 0).toString()),
      canceladasCount: json['canceladas_count'] ?? 0,
      canceladasTotal: double.parse((json['canceladas_total'] ?? 0).toString()),
    );
  }
}
