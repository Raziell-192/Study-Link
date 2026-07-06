import '../../domain/repositories/grupo_repository.dart';
import '../datasources/grupo_remote_datasource.dart';
import '../models/grupo_model.dart';
import '../models/miembro_model.dart';

class GrupoRepositoryImpl implements GrupoRepository {
  final GrupoRemoteDatasource _remote;

  GrupoRepositoryImpl({GrupoRemoteDatasource? remote})
      : _remote = remote ?? GrupoRemoteDatasource();

  @override
  Future<GrupoModel> crear({
    required String nombre,
    String? descripcion,
    required String idMateria,
  }) {
    return _remote.crear(nombre: nombre, descripcion: descripcion, idMateria: idMateria);
  }

  @override
  Future<MiembroModel> unirse(String idGrupo) => _remote.unirse(idGrupo);

  @override
  Future<List<MiembroModel>> listarMiembros(String idGrupo) => _remote.listarMiembros(idGrupo);

  @override
  Future<void> expulsar(String idGrupo, String idUsuario) => _remote.expulsar(idGrupo, idUsuario);

  @override
  Future<MiembroModel> cambiarRol(String idGrupo, String idUsuario, String rol) =>
      _remote.cambiarRol(idGrupo, idUsuario, rol);
}
