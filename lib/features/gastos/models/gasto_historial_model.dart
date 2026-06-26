// ajusta este import a tu ruta real

import 'package:ventro_app/features/auth/models/user_model.dart';

class GastoHistorialModel {
  final int id;
  final int gastoId;
  final int editadoPor;
  final Map<String, dynamic> snapshotAnterior;
  final String motivo;
  final DateTime createdAt;
  final UserModel? editadoPorUser;

  const GastoHistorialModel({
    required this.id,
    required this.gastoId,
    required this.editadoPor,
    required this.snapshotAnterior,
    required this.motivo,
    required this.createdAt,
    this.editadoPorUser,
  });

  factory GastoHistorialModel.fromJson(Map<String, dynamic> json) {
    return GastoHistorialModel(
      id: json['id'] as int,
      gastoId: json['gasto_id'] as int,
      editadoPor: json['editado_por'] as int,
      snapshotAnterior: json['snapshot_anterior'] as Map<String, dynamic>,
      motivo: json['motivo'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      editadoPorUser: json['editado_por_user'] != null
          ? UserModel.fromJson(json['editado_por_user'] as Map<String, dynamic>)
          : null,
    );
  }
}
