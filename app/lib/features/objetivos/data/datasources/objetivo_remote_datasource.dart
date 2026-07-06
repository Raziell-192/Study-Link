import '../../../../core/network/api_client.dart';
import '../models/objetivo_model.dart';

class ObjetivoRemoteDatasource {
  final _dio = ApiClient.instance.dio;

  /// HU-23. POST /api/objetivos
  Future<ObjetivoModel> crear({
    required String titulo,
    String? descripcion,
    String? fechaLimite,
  }) async {
    try {
      final response = await _dio.post('/objetivos', data: {
        'titulo': titulo,
        if (descripcion != null) 'descripcion': descripcion,
        if (fechaLimite != null) 'fecha_limite': fechaLimite,
      });
      return ObjetivoModel.fromJson(response.data['objetivo']);
    } catch (e) {
      throw ApiClient.instance.traducirError(e);
    }
  }

  /// HU-23. GET /api/objetivos/mios
  Future<List<ObjetivoModel>> listarMios() async {
    try {
      final response = await _dio.get('/objetivos/mios');
      final lista = response.data['objetivos'] as List;
      return lista.map((e) => ObjetivoModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiClient.instance.traducirError(e);
    }
  }

  /// HU-24. PATCH /api/objetivos/:id_objetivo/progreso
  Future<ObjetivoModel> actualizarProgreso(String idObjetivo, int progreso) async {
    try {
      final response = await _dio.patch('/objetivos/$idObjetivo/progreso', data: {
        'progreso': progreso,
      });
      return ObjetivoModel.fromJson(response.data['objetivo']);
    } catch (e) {
      throw ApiClient.instance.traducirError(e);
    }
  }
}
