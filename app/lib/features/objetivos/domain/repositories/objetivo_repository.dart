import '../../data/models/objetivo_model.dart';

abstract class ObjetivoRepository {
  Future<ObjetivoModel> crear({
    required String titulo,
    String? descripcion,
    String? fechaLimite,
  });

  Future<List<ObjetivoModel>> listarMios();

  Future<ObjetivoModel> actualizarProgreso(String idObjetivo, int progreso);
}
