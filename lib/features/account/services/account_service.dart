import 'package:dio/dio.dart';
import 'package:ventro_app/core/network/api_client.dart';
import 'package:ventro_app/features/account/models/account_model.dart';

class AccountService {
  final Dio _dio = ApiClient.instance;

  Future<AccountModel> getAccount() async {
    final response = await _dio.get('/account');
    return AccountModel.fromJson(Map<String, dynamic>.from(response.data));
  }
}
