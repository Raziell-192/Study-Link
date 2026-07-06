import '../../data/models/grupo_model.dart';
import '../../data/models/miembro_model.dart';

abstract class GrupoRepository {
  Future<GrupoModel> crear({
    required String nombre,
    String? descripcion,
    required String idMateria,
  });

  Future<MiembroModel> unirse(String idGrupo);

  Future<List<MiembroModel>> listarMiembros(String idGrupo);

  Future<void> expulsar(String idGrupo, String idUsuario);

  Future<MiembroModel> cambiarRol(String idGrupo, String idUsuario, String rol);
}
