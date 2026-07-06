import '../../data/models/logro_model.dart';

abstract class LogroRepository {
  Future<List<LogroModel>> catalogo();

  Future<({List<LogroModel> logros, List<LogroModel> nuevos})> misLogros();
}
