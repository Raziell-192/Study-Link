import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/repositories/calificacion_repository.dart';
import 'calificacion_state.dart';

class CalificacionCubit extends Cubit<CalificacionState> {
  final CalificacionRepository _repository;

  CalificacionCubit(this._repository) : super(CalificacionInicial());

  /// HU-26
  Future<void> calificar({
    required String idSesion,
    required String idTutor,
    required int puntuacion,
    String? comentario,
  }) async {
    emit(CalificacionCargando());
    try {
      final calificacion = await _repository.calificar(
        idSesion: idSesion,
        idTutor: idTutor,
        puntuacion: puntuacion,
        comentario: comentario,
      );
      emit(CalificacionEnviada(calificacion));
    } catch (e) {
      emit(CalificacionError(e is AppException ? e.mensaje : 'No se pudo enviar la calificación.'));
    }
  }

  /// HU-27
  Future<void> cargarReputacion(String idUsuario) async {
    emit(CalificacionCargando());
    try {
      final reputacion = await _repository.obtenerReputacion(idUsuario);
      emit(ReputacionCargada(reputacion));
    } catch (e) {
      emit(CalificacionError(e is AppException ? e.mensaje : 'No se pudo cargar la reputación.'));
    }
  }
}
