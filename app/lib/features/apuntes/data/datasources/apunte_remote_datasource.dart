import '../../../../core/network/api_client.dart';
import '../models/apunte_model.dart';

class ApunteRemoteDatasource {
  final _dio = ApiClient.instance.dio;

  static const tiposValidos = ['PDF', 'Imagen', 'Enlace', 'Presentacion'];

  /// HU-11. POST /api/apuntes
  /// Sin Firebase Storage real (decisión de PROGRESS.md): archivo_url es un
  /// string que el usuario proporciona, no se sube ningún binario aquí.
  Future<ApunteModel> subir({
    required String idMateria,
    required String titulo,
    String? descripcion,
    required String tipoArchivo,
    required String archivoUrl,
  }) async {
    try {
      final response = await _dio.post('/apuntes', data: {
        'id_materia': idMateria,
        'titulo': titulo,
        if (descripcion != null) 'descripcion': descripcion,
        'tipo_archivo': tipoArchivo,
        'archivo_url': archivoUrl,
      });
      return ApunteModel.fromJson(response.data['apunte']);
    } catch (e) {
      throw ApiClient.instance.traducirError(e);
    }
  }

  /// HU-12. GET /api/apuntes/materia/:id_materia
  Future<List<ApunteModel>> listarPorMateria(String idMateria) async {
    try {
      final response = await _dio.get('/apuntes/materia/$idMateria');
      final lista = response.data['apuntes'] as List;
      return lista.map((e) => ApunteModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiClient.instance.traducirError(e);
    }
  }

  /// HU-12. GET /api/apuntes/buscar?q=...&id_materia=...
  Future<List<ApunteModel>> buscar(String q, {String? idMateria}) async {
    try {
      final response = await _dio.get('/apuntes/buscar', queryParameters: {
        'q': q,
        if (idMateria != null) 'id_materia': idMateria,
      });
      final lista = response.data['apuntes'] as List;
      return lista.map((e) => ApunteModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiClient.instance.traducirError(e);
    }
  }

  /// HU-13. GET /api/apuntes/:id_apunte
  Future<ApunteModel> obtener(String idApunte) async {
    try {
      final response = await _dio.get('/apuntes/$idApunte');
      return ApunteModel.fromJson(response.data['apunte']);
    } catch (e) {
      throw ApiClient.instance.traducirError(e);
    }
  }

  /// HU-13. DELETE /api/apuntes/:id_apunte
  Future<void> eliminar(String idApunte) async {
    try {
      await _dio.delete('/apuntes/$idApunte');
    } catch (e) {
      throw ApiClient.instance.traducirError(e);
    }
  }
}
