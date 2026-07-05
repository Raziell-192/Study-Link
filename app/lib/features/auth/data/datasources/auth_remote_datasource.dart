import '../../../../core/network/api_client.dart';
import '../models/usuario_model.dart';

class AuthRemoteDatasource {
  final _dio = ApiClient.instance.dio;

  /// HU-01. POST /api/auth/registro
  Future<UsuarioModel> registrar({
    required String matricula,
    required String nombreCompleto,
    required String correo,
    required String contrasena,
  }) async {
    try {
      final response = await _dio.post('/auth/registro', data: {
        'matricula': matricula,
        'nombre_completo': nombreCompleto,
        'correo': correo,
        'contrasena': contrasena,
      });
      return UsuarioModel.fromJson(response.data['usuario']);
    } catch (e) {
      throw ApiClient.instance.traducirError(e);
    }
  }

  /// HU-02. POST /api/auth/login — devuelve (token, usuario).
  Future<({String token, UsuarioModel usuario})> login({
    required String correo,
    required String contrasena,
  }) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'correo': correo,
        'contrasena': contrasena,
      });
      return (
        token: response.data['token'] as String,
        usuario: UsuarioModel.fromJson(response.data['usuario']),
      );
    } catch (e) {
      throw ApiClient.instance.traducirError(e);
    }
  }

  /// HU-03. GET /api/usuarios/perfil
  Future<UsuarioModel> obtenerMiPerfil() async {
    try {
      final response = await _dio.get('/usuarios/perfil');
      return UsuarioModel.fromJson(response.data['usuario']);
    } catch (e) {
      throw ApiClient.instance.traducirError(e);
    }
  }

  /// HU-03. PUT /api/usuarios/perfil
  Future<UsuarioModel> actualizarPerfil({
    String? nombreCompleto,
    String? carrera,
    int? semestre,
    String? fotoPerfil,
  }) async {
    try {
      final response = await _dio.put('/usuarios/perfil', data: {
        if (nombreCompleto != null) 'nombre_completo': nombreCompleto,
        if (carrera != null) 'carrera': carrera,
        if (semestre != null) 'semestre': semestre,
        if (fotoPerfil != null) 'foto_perfil': fotoPerfil,
      });
      return UsuarioModel.fromJson(response.data['usuario']);
    } catch (e) {
      throw ApiClient.instance.traducirError(e);
    }
  }
}
