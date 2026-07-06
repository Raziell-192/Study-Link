import '../../data/models/calificacion_model.dart';

abstract class CalificacionRepository {
  Future<CalificacionModel> calificar({
    required String idSesion,
    required String idTutor,
    required int puntuacion,
    String? comentario,
  });

  Future<ReputacionModel> obtenerReputacion(String idUsuario);
}
