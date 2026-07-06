import 'package:equatable/equatable.dart';
import '../../data/models/materia_model.dart';

abstract class MateriaState extends Equatable {
  const MateriaState();
  @override
  List<Object?> get props => [];
}

class MateriaInicial extends MateriaState {}

class MateriaCargando extends MateriaState {}

class MateriaListaCargada extends MateriaState {
  final List<MateriaModel> materias;
  const MateriaListaCargada(this.materias);
  @override
  List<Object?> get props => [materias];
}

class MateriaError extends MateriaState {
  final String mensaje;
  const MateriaError(this.mensaje);
  @override
  List<Object?> get props => [mensaje];
}
