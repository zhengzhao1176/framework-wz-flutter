import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framework_wz/core/error/exceptions.dart';
import 'package:framework_wz/core/network/error_interceptor.dart';
import 'package:framework_wz/core/network/mock_interceptor.dart';

import '../../helpers/fixture_loader.dart';

/// TC-NET-001..002 — mock interceptor returns fixtures + falls through when disabled.
void main() {
  Dio buildDio({required bool enabled}) {
    final dio = Dio(BaseOptions(baseUrl: 'https://test'));
    dio.interceptors.add(MockInterceptor(
      enabled: enabled,
      fixtureLoader: loadFixture,
      delay: Duration.zero,
    ));
    dio.interceptors.add(ErrorInterceptor());
    return dio;
  }

  test('TC-NET-001 GET /api/menus?role=admin returns fixture', () async {
    final dio = buildDio(enabled: true);
    final res = await dio.get<Object?>(
      '/api/menus',
      queryParameters: {'role': 'admin'},
    );
    expect(res.statusCode, 200);
    expect(res.data, isA<List>());
    expect((res.data as List).first, isA<Map>());
  });

  test('POST /api/auth/login admin/123456 returns token JSON', () async {
    final dio = buildDio(enabled: true);
    final res = await dio.post<Object?>(
      '/api/auth/login',
      data: {'username': 'admin', 'password': '123456'},
    );
    expect((res.data as Map)['accessToken'], isNotEmpty);
  });

  test('POST /api/auth/login wrong creds → InvalidCredentialsException', () async {
    final dio = buildDio(enabled: true);
    expect(
      () => dio.post<Object?>(
        '/api/auth/login',
        data: {'username': 'admin', 'password': 'nope'},
      ),
      throwsA(isA<DioException>().having(
        (e) => e.error,
        'error',
        isA<InvalidCredentialsException>(),
      )),
    );
  });

  test('TC-NET-002 disabled → unrecognized path falls through (would hit network)', () async {
    final dio = buildDio(enabled: false);
    // We don't actually make a real network call here; we just assert that
    // disabling means the interceptor doesn't resolve, leaving dio to error
    // out trying to reach the (non-existent) host.
    expect(
      () => dio.get<Object?>(
        '/api/menus',
        queryParameters: {'role': 'admin'},
      ),
      throwsA(isA<Object>()),
    );
  });
}
