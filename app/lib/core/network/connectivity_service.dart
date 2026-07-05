import 'package:connectivity_plus/connectivity_plus.dart';

/// Base de la "estrategia de repositorio condicional" de AppMovil.md 23.2:
/// los repositorios consultan esto antes de decidir si van a la API REST
/// o caen a Isar (datos locales).
class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  final _connectivity = Connectivity();

  Future<bool> hayConexion() async {
    final resultado = await _connectivity.checkConnectivity();
    return !resultado.contains(ConnectivityResult.none);
  }

  Stream<bool> get cambiosConexion => _connectivity.onConnectivityChanged
      .map((resultado) => !resultado.contains(ConnectivityResult.none));
}
