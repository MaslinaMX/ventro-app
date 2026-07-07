// ✅ V2
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:ventro_app/core/network/api_client.dart';
import 'package:ventro_app/features/auth/models/user_model.dart';

class UserService {
  final Dio _dio = ApiClient.instance;

  Future<List<UserModel>> getAll() async {
    final res = await _dio.get('/usuarios');
    return (res.data as List).map((e) => UserModel.fromJson(e)).toList();
  }

  Future<UserModel> getById(int id) async {
    final res = await _dio.get('/usuarios/$id');
    return UserModel.fromJson(res.data);
  }

  Future<UserModel> create(Map<String, dynamic> data) async {
    try {
      final res = await _dio.post(
        '/usuarios',
        data: data,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      return UserModel.fromJson(res.data);
    } on DioException catch (e) {
      debugPrint('ERROR: ${e.response?.data}');
      rethrow;
    }
  }

  Future<UserModel> update(int id, Map<String, dynamic> data) async {
    final res = await _dio.patch('/usuarios/$id', data: data);
    return UserModel.fromJson(res.data);
  }

  Future<void> delete(int id) async {
    await _dio.delete('/usuarios/$id');
  }

  Future<UserModel> toggleActivo(int id) async {
    final res = await _dio.patch('/usuarios/$id/toggle-activo');
    return UserModel.fromJson(res.data);
  }
}
