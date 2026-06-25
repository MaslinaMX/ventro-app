// ✅ auth_model.dart

enum UserRole { adminEmpresa, adminSucursal, vendedor }

extension UserRoleExt on UserRole {
  String get label => switch (this) {
        UserRole.adminEmpresa => 'Admin Empresa',
        UserRole.adminSucursal => 'Admin Sucursal',
        UserRole.vendedor => 'Vendedor',
      };
  String get value => switch (this) {
        UserRole.adminEmpresa => 'admin_empresa',
        UserRole.adminSucursal => 'admin_sucursal',
        UserRole.vendedor => 'vendedor',
      };
  static UserRole fromString(String v) => switch (v) {
        'admin_empresa' => UserRole.adminEmpresa,
        'admin_sucursal' => UserRole.adminSucursal,
        _ => UserRole.vendedor,
      };
  bool get isAdmin => this == UserRole.adminEmpresa || this == UserRole.adminSucursal;
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
