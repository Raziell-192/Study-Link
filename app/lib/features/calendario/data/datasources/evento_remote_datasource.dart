import '../../../../core/network/api_client.dart';
import '../models/evento_model.dart';

class EventoRemoteDatasource {
  final _dio = ApiClient.instance.dio;

  /// HU-18. POST /api/eventos
  Future<EventoModel> crear({
    required String titulo,
    String? descripcion,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    String? idGrupo,
    bool compartido = false,
    int? recordatorioMinutosAntes,
  }) async {
    try {
      final response = await _dio.post('/eventos', data: {
        'titulo': titulo,
        if (descripcion != null) 'descripcion': descripcion,
        'fecha_inicio': fechaInicio.toIso8601String(),
        'fecha_fin': fechaFin.toIso8601String(),
        if (idGrupo != null) 'id_grupo': idGrupo,
        'compartido': compartido,
        if (recordatorioMinutosAntes != null)
          'recordatorio_minutos_antes': recordatorioMinutosAntes,
      });
      return EventoModel.fromJson(response.data['evento']);
    } catch (e) {
      throw ApiClient.instance.traducirError(e);
    }
  }

  /// HU-18. GET /api/eventos
  Future<List<EventoModel>> listarPropios() async {
    try {
      final response = await _dio.get('/eventos');
      final lista = response.data['eventos'] as List;
      return lista.map((e) => EventoModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiClient.instance.traducirError(e);
    }
  }

  /// HU-19. GET /api/eventos/grupo/:id_grupo
  Future<List<ItemCalendarioModel>> listarPorGrupo(String idGrupo) async {
    try {
      final response = await _dio.get('/eventos/grupo/$idGrupo');
      final lista = response.data['calendario'] as List;
      return lista.map((e) => ItemCalendarioModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiClient.instance.traducirError(e);
    }
  }

  /// HU-18. DELETE /api/eventos/:id_evento
  Future<void> eliminar(String idEvento) async {
    try {
      await _dio.delete('/eventos/$idEvento');
    } catch (e) {
      throw ApiClient.instance.traducirError(e);
    }
  }
}
