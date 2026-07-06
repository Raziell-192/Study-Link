import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/repositories/evento_repository.dart';
import 'evento_state.dart';

class EventoCubit extends Cubit<EventoState> {
  final EventoRepository _repository;

  EventoCubit(this._repository) : super(EventoInicial());

  /// HU-18
  Future<void> crear({
    required String titulo,
    String? descripcion,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    String? idGrupo,
    bool compartido = false,
    int? recordatorioMinutosAntes,
  }) async {
    emit(EventoCargando());
    try {
      final evento = await _repository.crear(
        titulo: titulo,
        descripcion: descripcion,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        idGrupo: idGrupo,
        compartido: compartido,
        recordatorioMinutosAntes: recordatorioMinutosAntes,
      );
      emit(EventoCreado(evento));
    } catch (e) {
      emit(EventoError(e is AppException ? e.mensaje : 'No se pudo crear el evento.'));
    }
  }

  /// HU-18
  Future<void> listarPropios() async {
    emit(EventoCargando());
    try {
      final eventos = await _repository.listarPropios();
      emit(EventosPropiosCargados(eventos));
    } catch (e) {
      emit(EventoError(e is AppException ? e.mensaje : 'No se pudo cargar tu calendario.'));
    }
  }

  /// HU-19
  Future<void> listarPorGrupo(String idGrupo) async {
    emit(EventoCargando());
    try {
      final items = await _repository.listarPorGrupo(idGrupo);
      emit(CalendarioGrupoCargado(items));
    } catch (e) {
      emit(EventoError(e is AppException ? e.mensaje : 'No se pudo cargar el calendario del grupo.'));
    }
  }

  /// HU-18
  Future<void> eliminar(String idEvento) async {
    try {
      await _repository.eliminar(idEvento);
      await listarPropios();
    } catch (e) {
      emit(EventoError(e is AppException ? e.mensaje : 'No se pudo eliminar el evento.'));
    }
  }
}
