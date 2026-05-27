import 'dart:io';

import 'package:dio/dio.dart';

import '../error/exceptions.dart';

/// Maps dio errors → domain [AppException]s so feature code never touches dio.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final ex = _map(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: ex,
        message: ex.message,
      ),
    );
  }

  AppException _map(DioException err) {
    final status = err.response?.statusCode;
    final body = err.response?.data;
    final code = body is Map ? body['code']?.toString() : null;

    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      return const NetworkException('请求超时', 'timeout');
    }
    if (err.error is SocketException) {
      return const NetworkException('无法连接到服务器', 'socket');
    }
    if (status == null) {
      return NetworkException(err.message ?? '网络异常');
    }

    if (status == 401) {
      if (code == 'invalid_credentials') {
        return const InvalidCredentialsException();
      }
      return const UnauthorizedException();
    }
    if (status == 403) return const ForbiddenException();
    if (status == 404) return const NotFoundException();
    if (status >= 500) return ServerException('服务器错误($status)', status);

    final msg = (body is Map ? body['message']?.toString() : null) ?? '请求失败';
    return ServerException(msg, status);
  }
}
