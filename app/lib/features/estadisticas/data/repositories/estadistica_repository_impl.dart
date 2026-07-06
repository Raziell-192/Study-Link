import '../../domain/repositories/estadistica_repository.dart';
import '../datasources/estadistica_remote_datasource.dart';
import '../models/estadisticas_model.dart';

class EstadisticaRepositoryImpl implements EstadisticaRepository {
  final EstadisticaRemoteDatasource _remote;

  EstadisticaRepositoryImpl({EstadisticaRemoteDatasource? remote})
      : _remote = remote ?? EstadisticaRemoteDatasource();

  @override
  Future<EstadisticasModel> misEstadisticas() => _remote.misEstadisticas();
}
