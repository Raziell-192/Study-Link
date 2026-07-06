class ApunteModel {
  final String idApunte;
  final String idUsuario;
  final String idMateria;
  final String titulo;
  final String? descripcion;
  final String tipoArchivo;
  final String archivoUrl;
  final DateTime fechaSubida;

  ApunteModel({
    required this.idApunte,
    required this.idUsuario,
    required this.idMateria,
    required this.titulo,
    this.descripcion,
    required this.tipoArchivo,
    required this.archivoUrl,
    required this.fechaSubida,
  });

  factory ApunteModel.fromJson(Map<String, dynamic> json) {
    return ApunteModel(
      idApunte: json['id_apunte'] as String,
      idUsuario: json['id_usuario'] as String,
      idMateria: json['id_materia'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String?,
      tipoArchivo: json['tipo_archivo'] as String,
      archivoUrl: json['archivo_url'] as String,
      fechaSubida: DateTime.parse(json['fecha_subida'] as String),
    );
  }
}
