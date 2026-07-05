import '../../../../core/storage/token_storage.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/usuario_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remote;
  final TokenStorage _tokenStorage;

  AuthRepositoryImpl({
    AuthRemoteDatasource? remote,
    TokenStorage? tokenStorage,
  })  : _remote = remote ?? AuthRemoteDatasource(),
        _tokenStorage = tokenStorage ?? TokenStorage.instance;

  @override
  Future<UsuarioModel> registrar({
    required String matricula,
    required String nombreCompleto,
    required String correo,
    required String contrasena,
  }) {
    return _remote.registrar(
      matricula: matricula,
      nombreCompleto: nombreCompleto,
      correo: correo,
      contrasena: contrasena,
    );
  }

  @override
  Future<UsuarioModel> login({required String correo, required String contrasena}) async {
    final resultado = await _remote.login(correo: correo, contrasena: contrasena);
    await _tokenStorage.guardarToken(resultado.token);
    return resultado.usuario;
  }

  @override
  Future<UsuarioModel> obtenerMiPerfil() => _remote.obtenerMiPerfil();

  @override
  Future<UsuarioModel> actualizarPerfil({
    String? nombreCompleto,
    String? carrera,
    int? semestre,
    String? fotoPerfil,
  }) {
    return _remote.actualizarPerfil(
      nombreCompleto: nombreCompleto,
      carrera: carrera,
      semestre: semestre,
      fotoPerfil: fotoPerfil,
    );
  }

  @override
  Future<void> logout() => _tokenStorage.borrarToken();

  @override
  Future<bool> haySesionGuardada() async {
    final token = await _tokenStorage.obtenerToken();
    return token != null;
  }
}
