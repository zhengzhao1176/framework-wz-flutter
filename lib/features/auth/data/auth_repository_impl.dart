import 'dart:async';

import 'package:dio/dio.dart';

import '../../../core/error/exceptions.dart';
import '../../../core/storage/storage.dart';
import '../domain/auth_models.dart';
import '../domain/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required Dio dio,
    required SecureStore secure,
    required PrefsStore prefs,
  })  : _dio = dio,
        _secure = secure,
        _prefs = prefs;

  final Dio _dio;
  final SecureStore _secure;
  final PrefsStore _prefs;
  final StreamController<AuthEvent> _events = StreamController.broadcast();

  @override
  Stream<AuthEvent> events() => _events.stream;

  @override
  Future<AuthToken> login(String username, String password) async {
    try {
      final res = await _dio.post<Object?>(
        '/api/auth/login',
        data: {'username': username, 'password': password},
      );
      final body = res.data;
      if (body is! Map) {
        throw const ServerException('登录响应无效');
      }
      final token = AuthToken.fromJson(body.cast<String, Object?>());
      await _persistToken(token);
      await _prefs.setString(StorageKeys.username, username);

      final profile = await currentUser();
      if (profile != null) {
        await _prefs.setString(StorageKeys.role, profile.role.name);
        _events.add(AuthLoggedIn(profile));
      }
      return token;
    } on DioException catch (e) {
      final err = e.error;
      if (err is AppException) throw err;
      throw const NetworkException();
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post<Object?>('/api/auth/logout');
    } catch (_) {
      // ignore — local cleanup must still happen
    }
    await _secure.delete(StorageKeys.accessToken);
    await _secure.delete(StorageKeys.refreshToken);
    await _secure.delete(StorageKeys.expiresAt);
    await _prefs.remove(StorageKeys.role);
    _events.add(const AuthLoggedOut());
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await _readToken();
    if (token == null) return false;
    if (token.isExpired) {
      await _secure.clear();
      return false;
    }
    return true;
  }

  @override
  Future<UserProfile?> currentUser() async {
    if (!await isLoggedIn()) return null;
    try {
      final res = await _dio.get<Object?>('/api/auth/me');
      final body = res.data;
      if (body is! Map) return null;
      return UserProfile.fromJson(body.cast<String, Object?>());
    } on DioException catch (e) {
      final err = e.error;
      if (err is UnauthorizedException) return null;
      rethrow;
    }
  }

  Future<void> _persistToken(AuthToken token) async {
    await _secure.write(StorageKeys.accessToken, token.accessToken);
    await _secure.write(StorageKeys.refreshToken, token.refreshToken);
    await _secure.write(
      StorageKeys.expiresAt,
      token.expiresAt.toIso8601String(),
    );
  }

  Future<AuthToken?> _readToken() async {
    return AuthToken.tryFromStrings({
      'accessToken': await _secure.read(StorageKeys.accessToken),
      'refreshToken': await _secure.read(StorageKeys.refreshToken),
      'expiresAt': await _secure.read(StorageKeys.expiresAt),
    });
  }
}
