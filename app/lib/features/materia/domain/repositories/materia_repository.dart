import '../../data/models/materia_model.dart';

abstract class MateriaRepository {
  Future<List<MateriaModel>> listar();
}
