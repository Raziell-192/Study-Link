import 'package:equatable/equatable.dart';
import '../../data/models/solicitud_model.dart';
import '../../data/models/tutor_model.dart';

abstract class SolicitudState extends Equatable {
  const SolicitudState();
  @override
  List<Object?> get props => [];
}

class SolicitudInicial extends SolicitudState {}

class SolicitudCargando extends SolicitudState {}

class SolicitudCreada extends SolicitudState {
  final SolicitudModel solicitud;
  const SolicitudCreada(this.solicitud);
  @override
  List<Object?> get props => [solicitud];
}

class SolicitudListaCargada extends SolicitudState {
  final List<SolicitudModel> solicitudes;
  const SolicitudListaCargada(this.solicitudes);
  @override
  List<Object?> get props => [solicitudes];
}

class TutoresCargados extends SolicitudState {
  final List<TutorModel> tutores;
  const TutoresCargados(this.tutores);
  @override
  List<Object?> get props => [tutores];
}

class SolicitudAceptada extends SolicitudState {
  final SolicitudModel solicitud;
  const SolicitudAceptada(this.solicitud);
  @override
  List<Object?> get props => [solicitud];
}

class SolicitudError extends SolicitudState {
  final String mensaje;
  const SolicitudError(this.mensaje);
  @override
  List<Object?> get props => [mensaje];
}