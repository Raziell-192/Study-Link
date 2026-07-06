import '../../data/models/apunte_model.dart';

abstract class ApunteRepository {
  Future<ApunteModel> subir({
    required String idMateria,
    required String titulo,
    String? descripcion,
    required String tipoArchivo,
    required String archivoUrl,
  });

  Future<List<ApunteModel>> listarPorMateria(String idMateria);

  Future<List<ApunteModel>> buscar(String q, {String? idMateria});

  Future<ApunteModel> obtener(String idApunte);

  Future<void> eliminar(String idApunte);
}
