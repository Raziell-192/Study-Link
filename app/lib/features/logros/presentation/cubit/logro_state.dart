import 'package:equatable/equatable.dart';
import '../../data/models/logro_model.dart';

abstract class LogroState extends Equatable {
  const LogroState();
  @override
  List<Object?> get props => [];
}

class LogroInicial extends LogroState {}

class LogroCargando extends LogroState {}

class LogroListaCargada extends LogroState {
  final List<LogroModel> logros;
  final List<LogroModel> nuevos;
  const LogroListaCargada(this.logros, {this.nuevos = const []});
  @override
  List<Object?> get props => [logros, nuevos];
}

class LogroError extends LogroState {
  final String mensaje;
  const LogroError(this.mensaje);
  @override
  List<Object?> get props => [mensaje];
}
