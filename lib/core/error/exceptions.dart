/// Domain-level exceptions used throughout the app.
///
/// Maps from dio / network errors to these via [ErrorInterceptor].
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class InvalidCredentialsException extends AppException {
  const InvalidCredentialsException([super.message = '用户名或密码错误']);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = '会话已过期，请重新登录']);
}

class ForbiddenException extends AppException {
  const ForbiddenException([super.message = '无权访问']);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = '资源不存在']);
}

class NetworkException extends AppException {
  const NetworkException([super.message = '网络异常，请稍后重试', this.reason]);
  final String? reason;
}

class ServerException extends AppException {
  const ServerException([super.message = '服务器开小差了', this.statusCode]);
  final int? statusCode;
}

class UnknownException extends AppException {
  const UnknownException([super.message = '未知错误']);
}
