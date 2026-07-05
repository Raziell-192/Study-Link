import 'package:equatable/equatable.dart';
import '../../data/models/usuario_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInicial extends AuthState {}

class AuthVerificandoSesion extends AuthState {}

class AuthCargando extends AuthState {}

class AuthAutenticado extends AuthState {
  final UsuarioModel usuario;
  const AuthAutenticado(this.usuario);
  @override
  List<Object?> get props => [usuario];
}

class AuthNoAutenticado extends AuthState {}

class AuthError extends AuthState {
  final String mensaje;
  const AuthError(this.mensaje);
  @override
  List<Object?> get props => [mensaje];
}

/// HU-01: registro exitoso, pero el flujo pide luego iniciar sesión (el
/// backend no devuelve token en /registro, solo en /login).
class AuthRegistroExitoso extends AuthState {
  final UsuarioModel usuario;
  const AuthRegistroExitoso(this.usuario);
  @override
  List<Object?> get props => [usuario];
}
