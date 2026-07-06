class MateriaModel {
  final String idMateria;
  final String nombre;
  final String? descripcion;

  MateriaModel({
    required this.idMateria,
    required this.nombre,
    this.descripcion,
  });

  factory MateriaModel.fromJson(Map<String, dynamic> json) {
    return MateriaModel(
      idMateria: json['id_materia'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
    );
  }
}
