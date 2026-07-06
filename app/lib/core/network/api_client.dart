import 'package:dio/dio.dart';
import '../errors/app_exception.dart';
import '../storage/token_storage.dart';

/// Cambia esto según entorno. El backend corre en localhost:3000 (ver
/// Progreso-Studylink.md sección 9). En emulador Android usar 10.0.2.2.
class ApiConfig {
  static const String _host = String.fromEnvironment('API_HOST', defaultValue: '10.0.2.2');
  static const int _port = 3000;
  static String get baseUrl => 'http://$_host:$_port/api';
}

/// Envoltorio único de Dio para toda la app. Inyecta el JWT en cada
/// request (regla del backend: el id_usuario nunca va en el body, siempre
/// sale del token) y traduce errores HTTP/red a AppException.
class ApiClient {
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.instance.obtenerToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401 || error.response?.statusCode == 403) {
            await TokenStorage.instance.borrarToken();
          }
          handler.next(error);
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._internal();
  late final Dio _dio;

  Dio get dio => _dio;

  /// Traduce cualquier error de Dio a AppException, para que los repositorios
  /// no propaguen tipos de la librería HTTP hacia arriba.
  AppException traducirError(Object error) {
    if (error is DioException) {
      print('DIO ERROR >> tipo=${error.type} mensaje=${error.message} uri=${error.requestOptions.uri}');
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout) {
        return SinConexionException();
      }
      final status = error.response?.statusCode;
      if (status == 401 || status == 403) {
        return NoAutorizadoException();
      }
      final data = error.response?.data;
      final mensajeServidor = (data is Map && data['error'] != null)
          ? data['error'].toString()
          : 'Ocurrió un error inesperado.';
      return AppException(mensajeServidor, codigoHttp: status);
    }
    return AppException('Ocurrió un error inesperado.');
  }
}
