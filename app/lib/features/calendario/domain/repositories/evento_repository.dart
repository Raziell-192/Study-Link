import '../../data/models/evento_model.dart';

abstract class EventoRepository {
  Future<EventoModel> crear({
    required String titulo,
    String? descripcion,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    String? idGrupo,
    bool compartido = false,
    int? recordatorioMinutosAntes,
  });

  Future<List<EventoModel>> listarPropios();

  Future<List<ItemCalendarioModel>> listarPorGrupo(String idGrupo);

  Future<void> eliminar(String idEvento);
}
