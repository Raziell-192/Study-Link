class ObjetivoModel {
  final String idObjetivo;
  final String idUsuario;
  final String titulo;
  final String? descripcion;
  final int progreso;
  final String? fechaLimite;
  final DateTime fechaCreacion;
  final String estado;

  ObjetivoModel({
    required this.idObjetivo,
    required this.idUsuario,
    required this.titulo,
    this.descripcion,
    required this.progreso,
    this.fechaLimite,
    required this.fechaCreacion,
    required this.estado,
  });

  factory ObjetivoModel.fromJson(Map<String, dynamic> json) {
    return ObjetivoModel(
      idObjetivo: json['id_objetivo'] as String,
      idUsuario: json['id_usuario'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String?,
      progreso: json['progreso'] as int,
      fechaLimite: json['fecha_limite'] as String?,
      fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
      estado: json['estado'] as String,
    );
  }
}
