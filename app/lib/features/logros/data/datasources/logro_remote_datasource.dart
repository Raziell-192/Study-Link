import '../../../../core/network/api_client.dart';
import '../models/logro_model.dart';

class LogroRemoteDatasource {
  final _dio = ApiClient.instance.dio;

  /// GET /api/logros/catalogo
  Future<List<LogroModel>> catalogo() async {
    try {
      final response = await _dio.get('/logros/catalogo');
      final lista = response.data['logros'] as List;
      return lista.map((e) => LogroModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiClient.instance.traducirError(e);
    }
  }

  /// HU-30/31. GET /api/logros/mios — otorga automáticamente los pendientes.
  /// Devuelve (todos los logros con estado, los recién otorgados en esta llamada).
  Future<({List<LogroModel> logros, List<LogroModel> nuevos})> misLogros() async {
    try {
      final response = await _dio.get('/logros/mios');
      final logros = (response.data['logros'] as List).map((e) => LogroModel.fromJson(e)).toList();
      final nuevos = (response.data['nuevos'] as List).map((e) => LogroModel.fromJson(e)).toList();
      return (logros: logros, nuevos: nuevos);
    } catch (e) {
      throw ApiClient.instance.traducirError(e);
    }
  }
}
