import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/repositories/solicitud_repository.dart';
import 'solicitud_state.dart';

class SolicitudCubit extends Cubit<SolicitudState> {
  final SolicitudRepository _repository;

  SolicitudCubit(this._repository) : super(SolicitudInicial());

  /// HU-04
  Future<void> crear({
    required String idMateria,
    required String titulo,
    String? descripcion,
    required String modalidad,
  }) async {
    emit(SolicitudCargando());
    try {
      final solicitud = await _repository.crear(
        idMateria: idMateria,
        titulo: titulo,
        descripcion: descripcion,
        modalidad: modalidad,
      );
      emit(SolicitudCreada(solicitud));
    } catch (e) {
      emit(SolicitudError(e is AppException ? e.mensaje : 'No se pudo crear la solicitud.'));
    }
  }

  /// HU-04
  Future<void> listarPorMateria(String idMateria) async {
    emit(SolicitudCargando());
    try {
      final solicitudes = await _repository.listarPorMateria(idMateria);
      emit(SolicitudListaCargada(solicitudes));
    } catch (e) {
      emit(SolicitudError(e is AppException ? e.mensaje : 'No se pudieron cargar las solicitudes.'));
    }
  }

  /// HU-05
  Future<void> buscarTutores(String idMateria) async {
    emit(SolicitudCargando());
    try {
      final tutores = await _repository.buscarTutores(idMateria);
      emit(TutoresCargados(tutores));
    } catch (e) {
      emit(SolicitudError(e is AppException ? e.mensaje : 'No se pudieron cargar los tutores.'));
    }
  }

  /// HU-06
  Future<void> aceptar(String idSolicitud) async {
    emit(SolicitudCargando());
    try {
      final solicitud = await _repository.aceptar(idSolicitud);
      emit(SolicitudAceptada(solicitud));
    } catch (e) {
      emit(SolicitudError(e is AppException ? e.mensaje : 'No se pudo aceptar la solicitud.'));
    }
  }
}