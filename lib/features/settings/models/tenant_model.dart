class TenantModel {
  final String id;
  final String name;
  final String? razonSocial;
  final String? logo;
  final String email;
  final String plan;
  final String status;

  TenantModel({
    required this.id,
    required this.name,
    this.razonSocial,
    this.logo,
    required this.email,
    required this.plan,
    required this.status,
  });

  factory TenantModel.fromJson(Map<String, dynamic> json) {
    return TenantModel(
      id: json['id'],
      name: json['name'],
      razonSocial: json['razon_social'],
      logo: json['logo'],
      email: json['email'],
      plan: json['plan'] ?? 'basic',
      status: json['status'] ?? 'active',
    );
  }
}
