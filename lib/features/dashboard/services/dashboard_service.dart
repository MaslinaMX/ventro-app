import 'package:ventro_app/core/network/api_client.dart';
import 'package:ventro_app/features/dashboard/models/resumen_mes_model.dart';

class DashboardService {
  final _dio = ApiClient.instance;

  Future<ResumenMesModel> getResumenMes() async {
    final response = await _dio.get('/dashboard/resumen-mes');
    return ResumenMesModel.fromJson(Map<String, dynamic>.from(response.data));
  }
}
