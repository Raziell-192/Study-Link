/// Espeja la tabla `usuario` del backend (sin `contrasena`, el backend nunca la devuelve).
class UsuarioModel {
  final String idUsuario;
  final String matricula;
  final String nombreCompleto;
  final String correo;
  final String? carrera;
  final int? semestre;
  final String? fotoPerfil;
  final double reputacion;

  UsuarioModel({
    required this.idUsuario,
    required this.matricula,
    required this.nombreCompleto,
    required this.correo,
    this.carrera,
    this.semestre,
    this.fotoPerfil,
    this.reputacion = 0.0,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      idUsuario: json['id_usuario'] as String,
      matricula: json['matricula'] as String,
      nombreCompleto: json['nombre_completo'] as String,
      correo: json['correo'] as String,
      carrera: json['carrera'] as String?,
      semestre: json['semestre'] as int?,
      fotoPerfil: json['foto_perfil'] as String?,
      reputacion: json['reputacion'] != null ? double.parse(json['reputacion'].toString()) : 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_usuario': idUsuario,
        'matricula': matricula,
        'nombre_completo': nombreCompleto,
        'correo': correo,
        'carrera': carrera,
        'semestre': semestre,
        'foto_perfil': fotoPerfil,
        'reputacion': reputacion,
      };
}
