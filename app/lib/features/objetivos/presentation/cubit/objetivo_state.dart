import 'package:equatable/equatable.dart';
import '../../data/models/objetivo_model.dart';

abstract class ObjetivoState extends Equatable {
  const ObjetivoState();
  @override
  List<Object?> get props => [];
}

class ObjetivoInicial extends ObjetivoState {}

class ObjetivoCargando extends ObjetivoState {}

class ObjetivoCreado extends ObjetivoState {
  final ObjetivoModel objetivo;
  const ObjetivoCreado(this.objetivo);
  @override
  List<Object?> get props => [objetivo];
}

class ObjetivoListaCargada extends ObjetivoState {
  final List<ObjetivoModel> objetivos;
  const ObjetivoListaCargada(this.objetivos);
  @override
  List<Object?> get props => [objetivos];
}

class ObjetivoError extends ObjetivoState {
  final String mensaje;
  const ObjetivoError(this.mensaje);
  @override
  List<Object?> get props => [mensaje];
}
