// ✅ auth_model.dart

enum UserRole { admin, vendedor, personalizado }

extension UserRoleExt on UserRole {
  String get label => switch (this) {
        UserRole.admin => 'Admin',
        UserRole.vendedor => 'Vendedor',
        UserRole.personalizado => 'Personalizado',
      };
  String get value => name;
  static UserRole fromString(String v) =>
      UserRole.values.firstWhere((e) => e.name == v, orElse: () => UserRole.vendedor);
}

class UserModel {
  final int id;
  final String name;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? employeeNumber;
  final UserRole role;
  final List<String>? permissions;
  final bool isSeller;
  final bool isDeletable;
  final bool activo;
  final int? sucursalId;
  final String? sucursal;
  final DateTime? pinUpdatedAt;
  final bool pinIsDefault;

  const UserModel({
    required this.id,
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.employeeNumber,
    required this.role,
    this.permissions,
    required this.isSeller,
    required this.isDeletable,
    required this.activo,
    this.sucursalId,
    this.sucursal,
    this.pinUpdatedAt,
    required this.pinIsDefault,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        id: j['id'],
        name: j['name'],
        firstName: j['first_name'] ?? '',
        lastName: j['last_name'] ?? '',
        email: j['email'],
        phone: j['phone'],
        employeeNumber: j['employee_number'],
        role: UserRoleExt.fromString(j['role'] ?? 'vendedor'),
        permissions: (j['permissions'] as List<dynamic>?)?.cast<String>(),
        isSeller: j['is_seller'] ?? false,
        isDeletable: j['is_deletable'] ?? true,
        activo: j['activo'] ?? true,
        sucursalId: j['sucursal_id'],
        sucursal: j['sucursal'],
        pinUpdatedAt: j['pin_updated_at'] != null ? DateTime.tryParse(j['pin_updated_at']) : null,
        pinIsDefault: j['pin_is_default'] ?? false,
      );

  UserModel copyWith({
    bool? activo,
    String? sucursal,
    int? sucursalId,
  }) =>
      UserModel(
        id: id,
        name: name,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        employeeNumber: employeeNumber,
        role: role,
        permissions: permissions,
        isSeller: isSeller,
        isDeletable: isDeletable,
        activo: activo ?? this.activo,
        sucursalId: sucursalId ?? this.sucursalId,
        sucursal: sucursal ?? this.sucursal,
        pinUpdatedAt: pinUpdatedAt,
        pinIsDefault: pinIsDefault,
      );

  bool get onboardingComplete => phone != null && employeeNumber != null;
}

class AuthResponse {
  final String token;
  final String tenantId;
  final String? domain;
  final UserModel user;
  final bool onboardingComplete;

  AuthResponse({
    required this.token,
    required this.tenantId,
    this.domain,
    required this.user,
    required this.onboardingComplete,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      tenantId: json['tenant_id'] ?? '',
      domain: json['domain'],
      user: UserModel.fromJson(json['user']),
      onboardingComplete: json['onboarding_complete'] ?? true,
    );
  }
}
