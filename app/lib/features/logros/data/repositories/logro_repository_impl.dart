import '../../domain/repositories/logro_repository.dart';
import '../datasources/logro_remote_datasource.dart';
import '../models/logro_model.dart';

class LogroRepositoryImpl implements LogroRepository {
  final LogroRemoteDatasource _remote;

  LogroRepositoryImpl({LogroRemoteDatasource? remote})
      : _remote = remote ?? LogroRemoteDatasource();

  @override
  Future<List<LogroModel>> catalogo() => _remote.catalogo();

  @override
  Future<({List<LogroModel> logros, List<LogroModel> nuevos})> misLogros() => _remote.misLogros();
}
