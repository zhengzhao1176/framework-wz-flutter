import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Intercepts requests and returns canned fixture data for the dev/test build.
///
/// Routing rules are explicit; unrecognized paths fall through to the next
/// interceptor (effectively reaching the real network in non-mock mode).
class MockInterceptor extends Interceptor {
  MockInterceptor({
    this.enabled = true,
    this.fixtureLoader,
    this.delay = const Duration(milliseconds: 80),
  });

  bool enabled;
  final Duration delay;

  /// Optional override used by tests so they don't need rootBundle.
  final Future<String> Function(String assetPath)? fixtureLoader;

  Future<String> _load(String assetPath) =>
      fixtureLoader?.call(assetPath) ?? rootBundle.loadString(assetPath);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!enabled) {
      return handler.next(options);
    }
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    try {
      final response = await _route(options);
      if (response == null) {
        return handler.next(options);
      }
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.reject(e, true);
    } catch (e, st) {
      return handler.reject(
        DioException(
          requestOptions: options,
          error: e,
          stackTrace: st,
          type: DioExceptionType.unknown,
        ),
        true,
      );
    }
  }

  Future<Response<Object?>?> _route(RequestOptions options) async {
    final path = options.path;
    final method = options.method.toUpperCase();

    // ---- AUTH ----
    if (path == '/api/auth/login' && method == 'POST') {
      final body = options.data is Map ? options.data as Map : <String, Object?>{};
      final raw = (body['username'] ?? body['email']) as String?;
      final password = body['password'] as String?;
      // Accept either "admin" or "admin@wz.com" (mirroring original mockjs).
      final username = raw?.split('@').first;
      if ((username == 'admin') && password == '123456') {
        return _fromFixture(options, 'assets/fixtures/auth/login_success.json');
      }
      if ((username == 'editor') && password == '123456') {
        return _fromFixture(options, 'assets/fixtures/auth/login_editor.json');
      }
      if ((username == 'guest') && password == '123456') {
        return _fromFixture(options, 'assets/fixtures/auth/login_guest.json');
      }
      throw _error(options, 401, 'invalid_credentials');
    }
    if (path == '/api/auth/me' && method == 'GET') {
      final auth = options.headers['Authorization']?.toString() ?? '';
      if (auth.contains('admin')) {
        return _fromFixture(options, 'assets/fixtures/auth/me_admin.json');
      }
      if (auth.contains('editor')) {
        return _fromFixture(options, 'assets/fixtures/auth/me_editor.json');
      }
      if (auth.contains('guest')) {
        return _fromFixture(options, 'assets/fixtures/auth/me_guest.json');
      }
      throw _error(options, 401, 'unauthorized');
    }
    if (path == '/api/auth/logout' && method == 'POST') {
      return _ok(options, {'ok': true});
    }

    // ---- MENUS ----
    if (path == '/api/menus' && method == 'GET') {
      final role = options.queryParameters['role']?.toString() ?? 'admin';
      return _fromFixture(options, 'assets/fixtures/menus/menus_$role.json');
    }

    // ---- CHARTS ----
    if (path.startsWith('/api/charts/') && method == 'GET') {
      final type = path.split('/').last;
      // Normalize legacy slugs.
      final canon = switch (type) {
        'line' || 'bar' || 'shop' => 'shopchart',
        'radar' => 'radarchart',
        'pie' || 'cake' || 'gauge' => 'cakechart',
        _ => type,
      };
      return _fromFixture(options, 'assets/fixtures/charts/$canon.json');
    }

    // ---- TABLE ----
    if (path == '/api/users' && method == 'GET') {
      return _fromFixture(options, 'assets/fixtures/table/users_100.json');
    }

    // ---- JSON DEMO ----
    if (path == '/api/json/sample' && method == 'GET') {
      return _fromFixture(options, 'assets/fixtures/json/sample.json');
    }

    return null; // unrecognized — fall through
  }

  Future<Response<Object?>> _fromFixture(
    RequestOptions options,
    String assetPath,
  ) async {
    final raw = await _load(assetPath);
    final data = jsonDecode(raw);
    return Response<Object?>(
      requestOptions: options,
      statusCode: 200,
      data: data,
    );
  }

  Response<Object?> _ok(RequestOptions options, Object? data) {
    return Response<Object?>(
      requestOptions: options,
      statusCode: 200,
      data: data,
    );
  }

  DioException _error(RequestOptions options, int status, String code) {
    return DioException(
      requestOptions: options,
      response: Response<Object?>(
        requestOptions: options,
        statusCode: status,
        data: {'code': code, 'message': code},
      ),
      type: DioExceptionType.badResponse,
    );
  }
}
