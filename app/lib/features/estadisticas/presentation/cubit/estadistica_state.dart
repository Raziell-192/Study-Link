import 'package:equatable/equatable.dart';
import '../../data/models/estadisticas_model.dart';

abstract class EstadisticaState extends Equatable {
  const EstadisticaState();
  @override
  List<Object?> get props => [];
}

class EstadisticaInicial extends EstadisticaState {}

class EstadisticaCargando extends EstadisticaState {}

class EstadisticaCargada extends EstadisticaState {
  final EstadisticasModel estadisticas;
  const EstadisticaCargada(this.estadisticas);
  @override
  List<Object?> get props => [estadisticas];
}

class EstadisticaError extends EstadisticaState {
  final String mensaje;
  const EstadisticaError(this.mensaje);
  @override
  List<Object?> get props => [mensaje];
}
