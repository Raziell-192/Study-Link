import '../../data/models/solicitud_model.dart';
import '../../data/models/tutor_model.dart';

abstract class SolicitudRepository {
  Future<SolicitudModel> crear({
    required String idMateria,
    required String titulo,
    String? descripcion,
    required String modalidad,
  });

  Future<List<SolicitudModel>> listarPorMateria(String idMateria);

  Future<List<TutorModel>> buscarTutores(String idMateria);

  Future<SolicitudModel> aceptar(String idSolicitud);
}