import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framework_wz/core/error/exceptions.dart';
import 'package:framework_wz/core/network/error_interceptor.dart';

/// TC-NET-003..005 — interceptor maps dio errors to domain exceptions.
void main() {
  final interceptor = ErrorInterceptor();

  AppException intercept(DioException source) {
    AppException? captured;
    final handler = _CapturingHandler((e) {
      captured = e.error as AppException;
    });
    interceptor.onError(source, handler);
    return captured!;
  }

  test('401 invalid_credentials → InvalidCredentialsException', () {
    final ex = intercept(DioException(
      requestOptions: RequestOptions(path: '/x'),
      response: Response(
        requestOptions: RequestOptions(path: '/x'),
        statusCode: 401,
        data: {'code': 'invalid_credentials'},
      ),
      type: DioExceptionType.badResponse,
    ));
    expect(ex, isA<InvalidCredentialsException>());
  });

  test('401 generic → UnauthorizedException', () {
    final ex = intercept(DioException(
      requestOptions: RequestOptions(path: '/x'),
      response: Response(
        requestOptions: RequestOptions(path: '/x'),
        statusCode: 401,
      ),
      type: DioExceptionType.badResponse,
    ));
    expect(ex, isA<UnauthorizedException>());
  });

  test('403 → ForbiddenException', () {
    final ex = intercept(DioException(
      requestOptions: RequestOptions(path: '/x'),
      response: Response(
        requestOptions: RequestOptions(path: '/x'),
        statusCode: 403,
      ),
      type: DioExceptionType.badResponse,
    ));
    expect(ex, isA<ForbiddenException>());
  });

  test('500 → ServerException with statusCode', () {
    final ex = intercept(DioException(
      requestOptions: RequestOptions(path: '/x'),
      response: Response(
        requestOptions: RequestOptions(path: '/x'),
        statusCode: 503,
      ),
      type: DioExceptionType.badResponse,
    )) as ServerException;
    expect(ex.statusCode, 503);
  });

  test('connection timeout → NetworkException(timeout)', () {
    final ex = intercept(DioException(
      requestOptions: RequestOptions(path: '/x'),
      type: DioExceptionType.connectionTimeout,
    )) as NetworkException;
    expect(ex.reason, 'timeout');
  });

  test('socket error → NetworkException(socket)', () {
    final ex = intercept(DioException(
      requestOptions: RequestOptions(path: '/x'),
      error: const SocketException('no net'),
      type: DioExceptionType.unknown,
    )) as NetworkException;
    expect(ex.reason, 'socket');
  });
}

class _CapturingHandler extends ErrorInterceptorHandler {
  _CapturingHandler(this._onReject);
  final void Function(DioException) _onReject;

  @override
  void reject(DioException error, [bool callFollowingErrorInterceptor = false]) {
    _onReject(error);
  }
}
