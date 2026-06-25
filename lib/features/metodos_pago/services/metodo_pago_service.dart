import 'package:dio/dio.dart';
import 'package:ventro_app/core/network/api_client.dart';
import 'package:ventro_app/features/metodos_pago/models/metodo_pago_model.dart';

class MetodoPagoService {
  final Dio _dio = ApiClient.instance;

  Future<List<MetodoPagoModel>> getMetodosPago() async {
    final response = await _dio.get('/metodos-pago');
    final list = response.data as List<dynamic>;
    return list.map((e) => MetodoPagoModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<MetodoPagoModel> createMetodoPago(Map<String, dynamic> data) async {
    final response = await _dio.post('/metodos-pago', data: data);
    return MetodoPagoModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<MetodoPagoModel> updateMetodoPago(int id, Map<String, dynamic> data) async {
    final response = await _dio.patch('/metodos-pago/$id', data: data);
    return MetodoPagoModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<void> deleteMetodoPago(int id) async {
    await _dio.delete('/metodos-pago/$id');
  }
}
