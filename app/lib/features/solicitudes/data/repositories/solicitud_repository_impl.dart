import '../../domain/repositories/solicitud_repository.dart';
import '../datasources/solicitud_remote_datasource.dart';
import '../models/solicitud_model.dart';
import '../models/tutor_model.dart';

class SolicitudRepositoryImpl implements SolicitudRepository {
  final SolicitudRemoteDatasource _remote;

  SolicitudRepositoryImpl({SolicitudRemoteDatasource? remote})
      : _remote = remote ?? SolicitudRemoteDatasource();

  @override
  Future<SolicitudModel> crear({
    required String idMateria,
    required String titulo,
    String? descripcion,
    required String modalidad,
  }) {
    return _remote.crear(
      idMateria: idMateria,
      titulo: titulo,
      descripcion: descripcion,
      modalidad: modalidad,
    );
  }

  @override
  Future<List<SolicitudModel>> listarPorMateria(String idMateria) =>
      _remote.listarPorMateria(idMateria);

  @override
  Future<List<TutorModel>> buscarTutores(String idMateria) => _remote.buscarTutores(idMateria);

  @override
  Future<SolicitudModel> aceptar(String idSolicitud) => _remote.aceptar(idSolicitud);
}