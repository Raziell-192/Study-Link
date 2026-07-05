import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(AuthInicial());

  /// Se llama al arrancar la app (splash) para decidir si va a Login o Home.
  Future<void> verificarSesion() async {
    emit(AuthVerificandoSesion());
    final haySesion = await _repository.haySesionGuardada();
    if (!haySesion) {
      emit(AuthNoAutenticado());
      return;
    }
    try {
      final usuario = await _repository.obtenerMiPerfil();
      emit(AuthAutenticado(usuario));
    } catch (_) {
      // Token guardado pero inválido/expirado (JWT 7 días) -> a login.
      await _repository.logout();
      emit(AuthNoAutenticado());
    }
  }

  /// HU-01
  Future<void> registrar({
    required String matricula,
    required String nombreCompleto,
    required String correo,
    required String contrasena,
  }) async {
    emit(AuthCargando());
    try {
      final usuario = await _repository.registrar(
        matricula: matricula,
        nombreCompleto: nombreCompleto,
        correo: correo,
        contrasena: contrasena,
      );
      emit(AuthRegistroExitoso(usuario));
    } catch (e) {
      emit(AuthError(e is AppException ? e.mensaje : 'No se pudo registrar.'));
    }
  }

  /// HU-02
  Future<void> login({required String correo, required String contrasena}) async {
    emit(AuthCargando());
    try {
      final usuario = await _repository.login(correo: correo, contrasena: contrasena);
      emit(AuthAutenticado(usuario));
    } catch (e) {
      emit(AuthError(e is AppException ? e.mensaje : 'No se pudo iniciar sesión.'));
    }
  }

  /// HU-03
  Future<void> actualizarPerfil({
    String? nombreCompleto,
    String? carrera,
    int? semestre,
    String? fotoPerfil,
  }) async {
    final estadoPrevio = state;
    emit(AuthCargando());
    try {
      final usuario = await _repository.actualizarPerfil(
        nombreCompleto: nombreCompleto,
        carrera: carrera,
        semestre: semestre,
        fotoPerfil: fotoPerfil,
      );
      emit(AuthAutenticado(usuario));
    } catch (e) {
      emit(AuthError(e is AppException ? e.mensaje : 'No se pudo actualizar el perfil.'));
      if (estadoPrevio is AuthAutenticado) emit(estadoPrevio);
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    emit(AuthNoAutenticado());
  }
}
