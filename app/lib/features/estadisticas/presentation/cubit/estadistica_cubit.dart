import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/repositories/estadistica_repository.dart';
import 'estadistica_state.dart';

class EstadisticaCubit extends Cubit<EstadisticaState> {
  final EstadisticaRepository _repository;

  EstadisticaCubit(this._repository) : super(EstadisticaInicial());

  /// HU-25
  Future<void> cargar() async {
    emit(EstadisticaCargando());
    try {
      final estadisticas = await _repository.misEstadisticas();
      emit(EstadisticaCargada(estadisticas));
    } catch (e) {
      emit(EstadisticaError(e is AppException ? e.mensaje : 'No se pudieron cargar las estadísticas.'));
    }
  }
}
