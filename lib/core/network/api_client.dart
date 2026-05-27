import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/storage.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';
import 'mock_interceptor.dart';

class ApiConfig {
  const ApiConfig({
    this.baseUrl = 'https://api.example.com',
    this.useMock = true,
    this.connectTimeout = const Duration(seconds: 10),
    this.receiveTimeout = const Duration(seconds: 10),
  });

  final String baseUrl;
  final bool useMock;
  final Duration connectTimeout;
  final Duration receiveTimeout;
}

const _defaultConfig = ApiConfig(
  useMock: bool.fromEnvironment('USE_MOCK', defaultValue: true),
  baseUrl: String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.example.com',
  ),
);

final apiConfigProvider = Provider<ApiConfig>((_) => _defaultConfig);

final dioProvider = Provider<Dio>((ref) {
  final cfg = ref.watch(apiConfigProvider);
  final store = ref.watch(secureStoreProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: cfg.baseUrl,
      connectTimeout: cfg.connectTimeout,
      receiveTimeout: cfg.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(AuthInterceptor(store));
  if (cfg.useMock) {
    dio.interceptors.add(MockInterceptor());
  }
  dio.interceptors.add(ErrorInterceptor());

  return dio;
});
