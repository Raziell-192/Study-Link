class EstadisticasModel {
  final double horasEstudio;
  final int sesionesCompletadas;
  final int tutoriasImpartidas;
  final int tutoriasRecibidas;

  EstadisticasModel({
    required this.horasEstudio,
    required this.sesionesCompletadas,
    required this.tutoriasImpartidas,
    required this.tutoriasRecibidas,
  });

  factory EstadisticasModel.fromJson(Map<String, dynamic> json) {
    return EstadisticasModel(
      horasEstudio: double.parse(json['horas_estudio'].toString()),
      sesionesCompletadas: json['sesiones_completadas'] as int,
      tutoriasImpartidas: json['tutorias_impartidas'] as int,
      tutoriasRecibidas: json['tutorias_recibidas'] as int,
    );
  }
}
