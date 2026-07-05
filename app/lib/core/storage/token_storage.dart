import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Guarda el JWT en almacenamiento seguro del dispositivo.
/// Regla de seguridad del backend: el id_usuario nunca sale del body,
/// siempre del token verificado — aquí solo custodiamos ese token.
class TokenStorage {
  TokenStorage._();
  static final TokenStorage instance = TokenStorage._();

  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'studylink_token';

  Future<void> guardarToken(String token) => _storage.write(key: _tokenKey, value: token);

  Future<String?> obtenerToken() => _storage.read(key: _tokenKey);

  Future<void> borrarToken() => _storage.delete(key: _tokenKey);
}
