import 'package:equatable/equatable.dart';
import '../../data/models/calificacion_model.dart';

abstract class CalificacionState extends Equatable {
  const CalificacionState();
  @override
  List<Object?> get props => [];
}

class CalificacionInicial extends CalificacionState {}

class CalificacionCargando extends CalificacionState {}

class CalificacionEnviada extends CalificacionState {
  final CalificacionModel calificacion;
  const CalificacionEnviada(this.calificacion);
  @override
  List<Object?> get props => [calificacion];
}

class ReputacionCargada extends CalificacionState {
  final ReputacionModel reputacion;
  const ReputacionCargada(this.reputacion);
  @override
  List<Object?> get props => [reputacion];
}

class CalificacionError extends CalificacionState {
  final String mensaje;
  const CalificacionError(this.mensaje);
  @override
  List<Object?> get props => [mensaje];
}
