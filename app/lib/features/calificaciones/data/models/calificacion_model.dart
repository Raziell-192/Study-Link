class CalificacionModel {
  final String idCalificacion;
  final String idSesion;
  final String idTutor;
  final String idTutorado;
  final int puntuacion;
  final String? comentario;
  final DateTime fecha;
  final String? nombreTutorado;
  final String? temaSesion;

  CalificacionModel({
    required this.idCalificacion,
    required this.idSesion,
    required this.idTutor,
    required this.idTutorado,
    required this.puntuacion,
    this.comentario,
    required this.fecha,
    this.nombreTutorado,
    this.temaSesion,
  });

  factory CalificacionModel.fromJson(Map<String, dynamic> json) {
    return CalificacionModel(
      idCalificacion: json['id_calificacion'] as String,
      idSesion: json['id_sesion'] as String,
      idTutor: json['id_tutor'] as String,
      idTutorado: json['id_tutorado'] as String,
      puntuacion: json['puntuacion'] as int,
      comentario: json['comentario'] as String?,
      fecha: DateTime.parse(json['fecha'] as String),
      nombreTutorado: json['nombre_tutorado'] as String?,
      temaSesion: json['tema_sesion'] as String?,
    );
  }
}

class ReputacionModel {
  final String idUsuario;
  final String nombreCompleto;
  final double reputacion;
  final int totalCalificaciones;
  final List<CalificacionModel> calificaciones;

  ReputacionModel({
    required this.idUsuario,
    required this.nombreCompleto,
    required this.reputacion,
    required this.totalCalificaciones,
    required this.calificaciones,
  });

  factory ReputacionModel.fromJson(Map<String, dynamic> json) {
    return ReputacionModel(
      idUsuario: json['id_usuario'] as String,
      nombreCompleto: json['nombre_completo'] as String,
      reputacion: double.parse(json['reputacion'].toString()),
      totalCalificaciones: json['total_calificaciones'] as int,
      calificaciones: (json['calificaciones'] as List)
          .map((e) => CalificacionModel.fromJson(e))
          .toList(),
    );
  }
}
