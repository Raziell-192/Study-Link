import 'package:equatable/equatable.dart';
import '../../data/models/apunte_model.dart';

abstract class ApunteState extends Equatable {
  const ApunteState();
  @override
  List<Object?> get props => [];
}

class ApunteInicial extends ApunteState {}

class ApunteCargando extends ApunteState {}

class ApunteSubido extends ApunteState {
  final ApunteModel apunte;
  const ApunteSubido(this.apunte);
  @override
  List<Object?> get props => [apunte];
}

class ApunteListaCargada extends ApunteState {
  final List<ApunteModel> apuntes;
  const ApunteListaCargada(this.apuntes);
  @override
  List<Object?> get props => [apuntes];
}

class ApunteEliminado extends ApunteState {}

class ApunteError extends ApunteState {
  final String mensaje;
  const ApunteError(this.mensaje);
  @override
  List<Object?> get props => [mensaje];
}
