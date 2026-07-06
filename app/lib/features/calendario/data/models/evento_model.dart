class EventoModel {
  final String idEvento;
  final String idUsuario;
  final String? idGrupo;
  final String titulo;
  final String? descripcion;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final bool compartido;

  EventoModel({
    required this.idEvento,
    required this.idUsuario,
    this.idGrupo,
    required this.titulo,
    this.descripcion,
    required this.fechaInicio,
    required this.fechaFin,
    required this.compartido,
  });

  factory EventoModel.fromJson(Map<String, dynamic> json) {
    return EventoModel(
      idEvento: json['id_evento'] as String,
      idUsuario: json['id_usuario'] as String,
      idGrupo: json['id_grupo'] as String?,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String?,
      fechaInicio: DateTime.parse(json['fecha_inicio'] as String),
      fechaFin: DateTime.parse(json['fecha_fin'] as String),
      compartido: json['compartido'] as bool,
    );
  }
}

/// HU-19: item de la línea de tiempo combinada de un grupo. `origen` distingue
/// si viene de evento_calendario o de sesion_estudio (backend los fusiona en uno).
class ItemCalendarioModel {
  final String origen; // 'evento' | 'sesion'
  final String idEvento;
  final String titulo;
  final String? descripcion;
  final DateTime fechaInicio;
  final DateTime fechaFin;

  ItemCalendarioModel({
    required this.origen,
    required this.idEvento,
    required this.titulo,
    this.descripcion,
    required this.fechaInicio,
    required this.fechaFin,
  });

  factory ItemCalendarioModel.fromJson(Map<String, dynamic> json) {
    return ItemCalendarioModel(
      origen: json['origen'] as String,
      idEvento: json['id_evento'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String?,
      fechaInicio: DateTime.parse(json['fecha_inicio'] as String),
      fechaFin: DateTime.parse(json['fecha_fin'] as String),
    );
  }
}
