/// Excepción de dominio uniforme. Todo repositorio traduce errores de Dio/Isar
/// a esto, para que la capa de presentación nunca dependa de detalles de red.
class AppException implements Exception {
  final String mensaje;
  final int? codigoHttp;

  AppException(this.mensaje, {this.codigoHttp});

  @override
  String toString() => mensaje;
}

class SinConexionException extends AppException {
  SinConexionException() : super('Sin conexión a internet. Mostrando datos guardados localmente.');
}

class NoAutorizadoException extends AppException {
  NoAutorizadoException() : super('Sesión expirada. Inicia sesión de nuevo.', codigoHttp: 401);
}
