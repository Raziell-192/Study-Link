import '../../data/models/estadisticas_model.dart';

abstract class EstadisticaRepository {
  Future<EstadisticasModel> misEstadisticas();
}
