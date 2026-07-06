import '../../../../core/network/api_client.dart';
import '../models/estadisticas_model.dart';

class EstadisticaRemoteDatasource {
  final _dio = ApiClient.instance.dio;

  /// HU-25. GET /api/estadisticas/mias
  Future<EstadisticasModel> misEstadisticas() async {
    try {
      final response = await _dio.get('/estadisticas/mias');
      return EstadisticasModel.fromJson(response.data['estadisticas']);
    } catch (e) {
      throw ApiClient.instance.traducirError(e);
    }
  }
}
