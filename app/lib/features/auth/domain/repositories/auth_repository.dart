import '../../data/models/usuario_model.dart';

abstract class AuthRepository {
  Future<UsuarioModel> registrar({
    required String matricula,
    required String nombreCompleto,
    required String correo,
    required String contrasena,
  });

  Future<UsuarioModel> login({required String correo, required String contrasena});

  Future<UsuarioModel> obtenerMiPerfil();

  Future<UsuarioModel> actualizarPerfil({
    String? nombreCompleto,
    String? carrera,
    int? semestre,
    String? fotoPerfil,
  });

  Future<void> logout();

  /// true si hay un token guardado (no valida contra el server, eso lo hace
  /// la primera llamada autenticada; ver AuthCubit.verificarSesion).
  Future<bool> haySesionGuardada();
}
