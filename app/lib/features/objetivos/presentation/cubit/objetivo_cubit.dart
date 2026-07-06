import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/repositories/objetivo_repository.dart';
import 'objetivo_state.dart';

class ObjetivoCubit extends Cubit<ObjetivoState> {
  final ObjetivoRepository _repository;

  ObjetivoCubit(this._repository) : super(ObjetivoInicial());

  /// HU-23
  Future<void> crear({
    required String titulo,
    String? descripcion,
    String? fechaLimite,
  }) async {
    emit(ObjetivoCargando());
    try {
      final objetivo = await _repository.crear(
        titulo: titulo,
        descripcion: descripcion,
        fechaLimite: fechaLimite,
      );
      emit(ObjetivoCreado(objetivo));
    } catch (e) {
      emit(ObjetivoError(e is AppException ? e.mensaje : 'No se pudo crear el objetivo.'));
    }
  }

  /// HU-23
  Future<void> listarMios() async {
    emit(ObjetivoCargando());
    try {
      final objetivos = await _repository.listarMios();
      emit(ObjetivoListaCargada(objetivos));
    } catch (e) {
      emit(ObjetivoError(e is AppException ? e.mensaje : 'No se pudieron cargar los objetivos.'));
    }
  }

  /// HU-24
  Future<void> actualizarProgreso(String idObjetivo, int progreso) async {
    try {
      await _repository.actualizarProgreso(idObjetivo, progreso);
      await listarMios();
    } catch (e) {
      emit(ObjetivoError(e is AppException ? e.mensaje : 'No se pudo actualizar el progreso.'));
    }
  }
}
