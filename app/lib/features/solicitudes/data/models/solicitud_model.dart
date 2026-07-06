class SolicitudModel {
  final String idSolicitud;
  final String idUsuario;
  final String idMateria;
  final String? idTutor;
  final String titulo;
  final String? descripcion;
  final String modalidad;
  final DateTime fechaCreacion;
  final String estado;

  SolicitudModel({
    required this.idSolicitud,
    required this.idUsuario,
    required this.idMateria,
    this.idTutor,
    required this.titulo,
    this.descripcion,
    required this.modalidad,
    required this.fechaCreacion,
    required this.estado,
  });

  factory SolicitudModel.fromJson(Map<String, dynamic> json) {
    return SolicitudModel(
      idSolicitud: json['id_solicitud'] as String,
      idUsuario: json['id_usuario'] as String,
      idMateria: json['id_materia'] as String,
      idTutor: json['id_tutor'] as String?,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String?,
      modalidad: json['modalidad'] as String,
      fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
      estado: json['estado'] as String,
    );
  }
}