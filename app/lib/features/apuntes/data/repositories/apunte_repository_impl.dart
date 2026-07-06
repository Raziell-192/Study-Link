import '../../domain/repositories/apunte_repository.dart';
import '../datasources/apunte_remote_datasource.dart';
import '../models/apunte_model.dart';

class ApunteRepositoryImpl implements ApunteRepository {
  final ApunteRemoteDatasource _remote;

  ApunteRepositoryImpl({ApunteRemoteDatasource? remote})
      : _remote = remote ?? ApunteRemoteDatasource();

  @override
  Future<ApunteModel> subir({
    required String idMateria,
    required String titulo,
    String? descripcion,
    required String tipoArchivo,
    required String archivoUrl,
  }) {
    return _remote.subir(
      idMateria: idMateria,
      titulo: titulo,
      descripcion: descripcion,
      tipoArchivo: tipoArchivo,
      archivoUrl: archivoUrl,
    );
  }

  @override
  Future<List<ApunteModel>> listarPorMateria(String idMateria) => _remote.listarPorMateria(idMateria);

  @override
  Future<List<ApunteModel>> buscar(String q, {String? idMateria}) => _remote.buscar(q, idMateria: idMateria);

  @override
  Future<ApunteModel> obtener(String idApunte) => _remote.obtener(idApunte);

  @override
  Future<void> eliminar(String idApunte) => _remote.eliminar(idApunte);
}
