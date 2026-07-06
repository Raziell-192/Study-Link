class LogroModel {
  final String idLogro;
  final String codigo;
  final String nombre;
  final String? descripcion;
  final String? icono;
  final bool obtenido;
  final DateTime? fechaObtenido;

  LogroModel({
    required this.idLogro,
    required this.codigo,
    required this.nombre,
    this.descripcion,
    this.icono,
    this.obtenido = false,
    this.fechaObtenido,
  });

  factory LogroModel.fromJson(Map<String, dynamic> json) {
    return LogroModel(
      idLogro: json['id_logro'] as String,
      codigo: json['codigo'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      icono: json['icono'] as String?,
      obtenido: json['obtenido'] as bool? ?? false,
      fechaObtenido: json['fecha_obtenido'] != null ? DateTime.parse(json['fecha_obtenido']) : null,
    );
  }
}
