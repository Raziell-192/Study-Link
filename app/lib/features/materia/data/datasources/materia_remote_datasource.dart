import '../../../../core/network/api_client.dart';
import '../models/materia_model.dart';

class MateriaRemoteDatasource {
  final _dio = ApiClient.instance.dio;

  /// GET /api/materias
  Future<List<MateriaModel>> listar() async {
    try {
      final response = await _dio.get('/materias');
      final lista = response.data['materias'] as List;
      return lista.map((e) => MateriaModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiClient.instance.traducirError(e);
    }
  }
}
