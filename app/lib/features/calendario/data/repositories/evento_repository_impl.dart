import '../../domain/repositories/evento_repository.dart';
import '../datasources/evento_remote_datasource.dart';
import '../models/evento_model.dart';

class EventoRepositoryImpl implements EventoRepository {
  final EventoRemoteDatasource _remote;

  EventoRepositoryImpl({EventoRemoteDatasource? remote})
      : _remote = remote ?? EventoRemoteDatasource();

  @override
  Future<EventoModel> crear({
    required String titulo,
    String? descripcion,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    String? idGrupo,
    bool compartido = false,
    int? recordatorioMinutosAntes,
  }) {
    return _remote.crear(
      titulo: titulo,
      descripcion: descripcion,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      idGrupo: idGrupo,
      compartido: compartido,
      recordatorioMinutosAntes: recordatorioMinutosAntes,
    );
  }

  @override
  Future<List<EventoModel>> listarPropios() => _remote.listarPropios();

  @override
  Future<List<ItemCalendarioModel>> listarPorGrupo(String idGrupo) => _remote.listarPorGrupo(idGrupo);

  @override
  Future<void> eliminar(String idEvento) => _remote.eliminar(idEvento);
}
