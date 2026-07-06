import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/repositories/grupo_repository.dart';
import 'grupo_state.dart';

class GrupoCubit extends Cubit<GrupoState> {
  final GrupoRepository _repository;

  GrupoCubit(this._repository) : super(GrupoInicial());

  /// HU-08
  Future<void> crear({
    required String nombre,
    String? descripcion,
    required String idMateria,
  }) async {
    emit(GrupoCargando());
    try {
      final grupo = await _repository.crear(nombre: nombre, descripcion: descripcion, idMateria: idMateria);
      emit(GrupoCreado(grupo));
    } catch (e) {
      emit(GrupoError(e is AppException ? e.mensaje : 'No se pudo crear el grupo.'));
    }
  }

  /// HU-09
  Future<void> unirse(String idGrupo) async {
    emit(GrupoCargando());
    try {
      final miembro = await _repository.unirse(idGrupo);
      emit(GrupoUnido(miembro));
    } catch (e) {
      emit(GrupoError(e is AppException ? e.mensaje : 'No se pudo unir al grupo.'));
    }
  }

  /// HU-10
  Future<void> listarMiembros(String idGrupo) async {
    emit(GrupoCargando());
    try {
      final miembros = await _repository.listarMiembros(idGrupo);
      emit(MiembrosCargados(miembros));
    } catch (e) {
      emit(GrupoError(e is AppException ? e.mensaje : 'No se pudieron cargar los miembros.'));
    }
  }

  /// HU-10
  Future<void> expulsar(String idGrupo, String idUsuario) async {
    try {
      await _repository.expulsar(idGrupo, idUsuario);
      await listarMiembros(idGrupo);
    } catch (e) {
      emit(GrupoError(e is AppException ? e.mensaje : 'No se pudo expulsar al miembro.'));
    }
  }

  /// HU-10
  Future<void> cambiarRol(String idGrupo, String idUsuario, String rol) async {
    try {
      await _repository.cambiarRol(idGrupo, idUsuario, rol);
      await listarMiembros(idGrupo);
    } catch (e) {
      emit(GrupoError(e is AppException ? e.mensaje : 'No se pudo cambiar el rol.'));
    }
  }
}
