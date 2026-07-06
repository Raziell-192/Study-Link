import '../../../../core/network/api_client.dart';
import '../models/grupo_model.dart';
import '../models/miembro_model.dart';

class GrupoRemoteDatasource {
  final _dio = ApiClient.instance.dio;

  /// HU-08. POST /api/grupos
  Future<GrupoModel> crear({
    required String nombre,
    String? descripcion,
    required String idMateria,
  }) async {
    try {
      final response = await _dio.post('/grupos', data: {
        'nombre': nombre,
        if (descripcion != null) 'descripcion': descripcion,
        'id_materia': idMateria,
      });
      return GrupoModel.fromJson(response.data['grupo']);
    } catch (e) {
      throw ApiClient.instance.traducirError(e);
    }
  }

  /// HU-09. POST /api/grupos/:id_grupo/unirse
  Future<MiembroModel> unirse(String idGrupo) async {
    try {
      final response = await _dio.post('/grupos/$idGrupo/unirse');
      return MiembroModel.fromJson(response.data['miembro']);
    } catch (e) {
      throw ApiClient.instance.traducirError(e);
    }
  }

  /// HU-10. GET /api/grupos/:id_grupo/miembros
  Future<List<MiembroModel>> listarMiembros(String idGrupo) async {
    try {
      final response = await _dio.get('/grupos/$idGrupo/miembros');
      final lista = response.data['miembros'] as List;
      return lista.map((e) => MiembroModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiClient.instance.traducirError(e);
    }
  }

  /// HU-10. DELETE /api/grupos/:id_grupo/miembros/:id_usuario
  Future<void> expulsar(String idGrupo, String idUsuario) async {
    try {
      await _dio.delete('/grupos/$idGrupo/miembros/$idUsuario');
    } catch (e) {
      throw ApiClient.instance.traducirError(e);
    }
  }

  /// HU-10. PATCH /api/grupos/:id_grupo/miembros/:id_usuario
  Future<MiembroModel> cambiarRol(String idGrupo, String idUsuario, String rol) async {
    try {
      final response = await _dio.patch('/grupos/$idGrupo/miembros/$idUsuario/rol', data: {
        'rol': rol,
      });
      return MiembroModel.fromJson(response.data['miembro']);
    } catch (e) {
      throw ApiClient.instance.traducirError(e);
    }
  }
}
