/// Resultado de HU-05 (Buscar Tutor): usuario + su reputación.
class TutorModel {
  final String idUsuario;
  final String nombreCompleto;
  final String correo;
  final double reputacion;

  TutorModel({
    required this.idUsuario,
    required this.nombreCompleto,
    required this.correo,
    required this.reputacion,
  });

  factory TutorModel.fromJson(Map<String, dynamic> json) {
    return TutorModel(
      idUsuario: json['id_usuario'] as String,
      nombreCompleto: json['nombre_completo'] as String,
      correo: json['correo'] as String,
      reputacion: json['reputacion'] != null ? double.parse(json['reputacion'].toString()) : 0.0,
    );
  }
}