import 'package:equatable/equatable.dart';
import '../../data/models/grupo_model.dart';
import '../../data/models/miembro_model.dart';

abstract class GrupoState extends Equatable {
  const GrupoState();
  @override
  List<Object?> get props => [];
}

class GrupoInicial extends GrupoState {}

class GrupoCargando extends GrupoState {}

class GrupoCreado extends GrupoState {
  final GrupoModel grupo;
  const GrupoCreado(this.grupo);
  @override
  List<Object?> get props => [grupo];
}

class GrupoUnido extends GrupoState {
  final MiembroModel miembro;
  const GrupoUnido(this.miembro);
  @override
  List<Object?> get props => [miembro];
}

class MiembrosCargados extends GrupoState {
  final List<MiembroModel> miembros;
  const MiembrosCargados(this.miembros);
  @override
  List<Object?> get props => [miembros];
}

class GrupoError extends GrupoState {
  final String mensaje;
  const GrupoError(this.mensaje);
  @override
  List<Object?> get props => [mensaje];
}
