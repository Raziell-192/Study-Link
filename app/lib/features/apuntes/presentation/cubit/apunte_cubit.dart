import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/repositories/apunte_repository.dart';
import 'apunte_state.dart';

class ApunteCubit extends Cubit<ApunteState> {
  final ApunteRepository _repository;

  ApunteCubit(this._repository) : super(ApunteInicial());

  /// HU-11
  Future<void> subir({
    required String idMateria,
    required String titulo,
    String? descripcion,
    required String tipoArchivo,
    required String archivoUrl,
  }) async {
    emit(ApunteCargando());
    try {
      final apunte = await _repository.subir(
        idMateria: idMateria,
        titulo: titulo,
        descripcion: descripcion,
        tipoArchivo: tipoArchivo,
        archivoUrl: archivoUrl,
      );
      emit(ApunteSubido(apunte));
    } catch (e) {
      emit(ApunteError(e is AppException ? e.mensaje : 'No se pudo subir el apunte.'));
    }
  }

  /// HU-12
  Future<void> listarPorMateria(String idMateria) async {
    emit(ApunteCargando());
    try {
      final apuntes = await _repository.listarPorMateria(idMateria);
      emit(ApunteListaCargada(apuntes));
    } catch (e) {
      emit(ApunteError(e is AppException ? e.mensaje : 'No se pudieron cargar los apuntes.'));
    }
  }

  /// HU-12
  Future<void> buscar(String q, {String? idMateria}) async {
    emit(ApunteCargando());
    try {
      final apuntes = await _repository.buscar(q, idMateria: idMateria);
      emit(ApunteListaCargada(apuntes));
    } catch (e) {
      emit(ApunteError(e is AppException ? e.mensaje : 'No se pudo completar la búsqueda.'));
    }
  }

  /// HU-13. Al eliminar, refresca la lista de la misma materia.
  Future<void> eliminar(String idApunte, String idMateriaParaRefrescar) async {
    try {
      await _repository.eliminar(idApunte);
      await listarPorMateria(idMateriaParaRefrescar);
    } catch (e) {
      emit(ApunteError(e is AppException ? e.mensaje : 'No se pudo eliminar el apunte.'));
    }
  }
}
