class ConfiguracionTicketModel {
  final bool mostrarLogo;
  final String? mensajePersonalizado;

  const ConfiguracionTicketModel({
    required this.mostrarLogo,
    this.mensajePersonalizado,
  });

  factory ConfiguracionTicketModel.fromJson(Map<String, dynamic> json) {
    return ConfiguracionTicketModel(
      mostrarLogo: json['mostrar_logo'] ?? true,
      mensajePersonalizado: json['mensaje_personalizado'],
    );
  }
}
