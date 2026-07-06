import '../../../../core/network/api_client.dart';
import '../models/calificacion_model.dart';

class CalificacionRemoteDatasource {
  final _dio = ApiClient.instance.dio;

  /// HU-26. POST /api/calificaciones
  Future<CalificacionModel> calificar({
    required String idSesion,
    required String idTutor,
    required int puntuacion,
    String? comentario,
  }) async {
    try {
      final response = await _dio.post('/calificaciones', data: {
        'id_sesion': idSesion,
        'id_tutor': idTutor,
        'puntuacion': puntuacion,
        if (comentario != null) 'comentario': comentario,
      });
      return CalificacionModel.fromJson(response.data['calificacion']);
    } catch (e) {
      throw ApiClient.instance.traducirError(e);
    }
  }

  /// HU-27. GET /api/calificaciones/tutor/:id_usuario
  Future<ReputacionModel> obtenerReputacion(String idUsuario) async {
    try {
      final response = await _dio.get('/calificaciones/tutor/$idUsuario');
      return ReputacionModel.fromJson(response.data);
    } catch (e) {
      throw ApiClient.instance.traducirError(e);
    }
  }
}
