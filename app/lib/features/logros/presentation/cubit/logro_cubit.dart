import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/repositories/logro_repository.dart';
import 'logro_state.dart';

class LogroCubit extends Cubit<LogroState> {
  final LogroRepository _repository;

  LogroCubit(this._repository) : super(LogroInicial());

  /// HU-30/31: una sola llamada otorga los pendientes y devuelve el estado completo.
  Future<void> cargarMisLogros() async {
    emit(LogroCargando());
    try {
      final resultado = await _repository.misLogros();
      emit(LogroListaCargada(resultado.logros, nuevos: resultado.nuevos));
    } catch (e) {
      emit(LogroError(e is AppException ? e.mensaje : 'No se pudieron cargar los logros.'));
    }
  }
}
