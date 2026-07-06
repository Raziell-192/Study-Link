import 'package:equatable/equatable.dart';
import '../../data/models/evento_model.dart';

abstract class EventoState extends Equatable {
  const EventoState();
  @override
  List<Object?> get props => [];
}

class EventoInicial extends EventoState {}

class EventoCargando extends EventoState {}

class EventoCreado extends EventoState {
  final EventoModel evento;
  const EventoCreado(this.evento);
  @override
  List<Object?> get props => [evento];
}

class EventosPropiosCargados extends EventoState {
  final List<EventoModel> eventos;
  const EventosPropiosCargados(this.eventos);
  @override
  List<Object?> get props => [eventos];
}

class CalendarioGrupoCargado extends EventoState {
  final List<ItemCalendarioModel> items;
  const CalendarioGrupoCargado(this.items);
  @override
  List<Object?> get props => [items];
}

class EventoError extends EventoState {
  final String mensaje;
  const EventoError(this.mensaje);
  @override
  List<Object?> get props => [mensaje];
}
