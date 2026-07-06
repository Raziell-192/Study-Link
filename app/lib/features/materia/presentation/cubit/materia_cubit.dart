import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/repositories/materia_repository.dart';
import 'materia_state.dart';

class MateriaCubit extends Cubit<MateriaState> {
  final MateriaRepository _repository;

  MateriaCubit(this._repository) : super(MateriaInicial());

  Future<void> listar() async {
    emit(MateriaCargando());
    try {
      final materias = await _repository.listar();
      emit(MateriaListaCargada(materias));
    } catch (e) {
      emit(MateriaError(e is AppException ? e.mensaje : 'No se pudieron cargar las materias.'));
    }
  }
}
