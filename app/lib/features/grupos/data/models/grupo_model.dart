class GrupoModel {
  final String idGrupo;
  final String nombre;
  final String? descripcion;
  final DateTime fechaCreacion;
  final String idCreador;
  final String? idMateria;

  GrupoModel({
    required this.idGrupo,
    required this.nombre,
    this.descripcion,
    required this.fechaCreacion,
    required this.idCreador,
    this.idMateria,
  });

  factory GrupoModel.fromJson(Map<String, dynamic> json) {
    return GrupoModel(
      idGrupo: json['id_grupo'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
      idCreador: json['id_creador'] as String,
      idMateria: json['id_materia'] as String?,
    );
  }
}
