import '../../domain/repositories/materia_repository.dart';
import '../datasources/materia_remote_datasource.dart';
import '../models/materia_model.dart';

class MateriaRepositoryImpl implements MateriaRepository {
  final MateriaRemoteDatasource _remote;

  MateriaRepositoryImpl({MateriaRemoteDatasource? remote})
      : _remote = remote ?? MateriaRemoteDatasource();

  @override
  Future<List<MateriaModel>> listar() => _remote.listar();
}
