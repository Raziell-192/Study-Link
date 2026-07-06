import '../../../../core/network/api_client.dart';
import '../models/solicitud_model.dart';
import '../models/tutor_model.dart';

class SolicitudRemoteDatasource {
  final _dio = ApiClient.instance.dio;

  /// HU-04. POST /api/solicitudes
  Future<SolicitudModel> crear({
    required String idMateria,
    required String titulo,
    String? descripcion,
    required String modalidad,
  }) async {
    try {
      final response = await _dio.post('/solicitudes', data: {
        'id_materia': idMateria,
        'titulo': titulo,
        if (descripcion != null) 'descripcion': descripcion,
        'modalidad': modalidad,
      });
      return SolicitudModel.fromJson(response.data['solicitud']);
    } catch (e) {
      throw ApiClient.instance.traducirError(e);
    }
  }

  /// HU-04. GET /api/solicitudes/materia/:id_materia
  Future<List<SolicitudModel>> listarPorMateria(String idMateria) async {
    try {
      final response = await _dio.get('/solicitudes/materia/$idMateria');
      final lista = response.data['solicitudes'] as List;
      return lista.map((e) => SolicitudModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiClient.instance.traducirError(e);
    }
  }

  /// HU-05. GET /api/usuarios/tutores/:id_materia
  Future<List<TutorModel>> buscarTutores(String idMateria) async {
    try {
      final response = await _dio.get('/usuarios/tutores/$idMateria');
      final lista = response.data['tutores'] as List;
      return lista.map((e) => TutorModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiClient.instance.traducirError(e);
    }
  }

  /// HU-06. PATCH /api/solicitudes/:id_solicitud/aceptar
  Future<SolicitudModel> aceptar(String idSolicitud) async {
    try {
      final response = await _dio.patch('/solicitudes/$idSolicitud/aceptar');
      return SolicitudModel.fromJson(response.data['solicitud']);
    } catch (e) {
      throw ApiClient.instance.traducirError(e);
    }
  }
}