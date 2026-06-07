class UserModel {
  final int id;
  final String name;
  final String? firstName;
  final String? lastName;
  final String email;
  final String? phone;
  final String? employeeNumber;
  final String role;
  final bool isSeller;
  final bool isDeletable;
  final int? sucursalId;
  final String? pinUpdatedAt;

  UserModel({
    required this.id,
    required this.name,
    this.firstName,
    this.lastName,
    required this.email,
    this.phone,
    this.employeeNumber,
    required this.role,
    required this.isSeller,
    required this.isDeletable,
    this.sucursalId,
    this.pinUpdatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phone: json['phone'],
      employeeNumber: json['employee_number'],
      role: json['role'],
      isSeller: json['is_seller'] ?? false,
      isDeletable: json['is_deletable'] ?? true,
      sucursalId: json['sucursal_id'],
      pinUpdatedAt: json['pin_updated_at'],
    );
  }

  bool get onboardingComplete =>
      firstName != null && lastName != null && phone != null && employeeNumber != null;
}

class AuthResponse {
  final String token;
  final String tenantId;
  final String? domain; // ← nullable
  final UserModel user;
  final bool onboardingComplete;

  AuthResponse({
    required this.token,
    required this.tenantId,
    this.domain, // ← opcional
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
