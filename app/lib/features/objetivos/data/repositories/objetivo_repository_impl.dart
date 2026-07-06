import '../../domain/repositories/objetivo_repository.dart';
import '../datasources/objetivo_remote_datasource.dart';
import '../models/objetivo_model.dart';

class ObjetivoRepositoryImpl implements ObjetivoRepository {
  final ObjetivoRemoteDatasource _remote;

  ObjetivoRepositoryImpl({ObjetivoRemoteDatasource? remote})
      : _remote = remote ?? ObjetivoRemoteDatasource();

  @override
  Future<ObjetivoModel> crear({
    required String titulo,
    String? descripcion,
    String? fechaLimite,
  }) {
    return _remote.crear(titulo: titulo, descripcion: descripcion, fechaLimite: fechaLimite);
  }

  @override
  Future<List<ObjetivoModel>> listarMios() => _remote.listarMios();

  @override
  Future<ObjetivoModel> actualizarProgreso(String idObjetivo, int progreso) =>
      _remote.actualizarProgreso(idObjetivo, progreso);
}
