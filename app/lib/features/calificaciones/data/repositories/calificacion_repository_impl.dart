import '../../domain/repositories/calificacion_repository.dart';
import '../datasources/calificacion_remote_datasource.dart';
import '../models/calificacion_model.dart';

class CalificacionRepositoryImpl implements CalificacionRepository {
  final CalificacionRemoteDatasource _remote;

  CalificacionRepositoryImpl({CalificacionRemoteDatasource? remote})
      : _remote = remote ?? CalificacionRemoteDatasource();

  @override
  Future<CalificacionModel> calificar({
    required String idSesion,
    required String idTutor,
    required int puntuacion,
    String? comentario,
  }) {
    return _remote.calificar(
      idSesion: idSesion,
      idTutor: idTutor,
      puntuacion: puntuacion,
      comentario: comentario,
    );
  }

  @override
  Future<ReputacionModel> obtenerReputacion(String idUsuario) => _remote.obtenerReputacion(idUsuario);
}
