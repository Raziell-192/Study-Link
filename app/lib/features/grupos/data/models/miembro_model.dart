class MiembroModel {
  final String idMiembro;
  final String idUsuario;
  final String nombreCompleto;
  final String correo;
  final String rol;
  final DateTime fechaUnion;

  MiembroModel({
    required this.idMiembro,
    required this.idUsuario,
    required this.nombreCompleto,
    required this.correo,
    required this.rol,
    required this.fechaUnion,
  });

  factory MiembroModel.fromJson(Map<String, dynamic> json) {
    return MiembroModel(
      idMiembro: json['id_miembro'] as String,
      idUsuario: json['id_usuario'] as String,
      nombreCompleto: json['nombre_completo'] as String,
      correo: json['correo'] as String,
      rol: json['rol'] as String,
      fechaUnion: DateTime.parse(json['fecha_union'] as String),
    );
  }
}
