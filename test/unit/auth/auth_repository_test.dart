import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framework_wz/core/error/exceptions.dart';
import 'package:framework_wz/core/network/auth_interceptor.dart';
import 'package:framework_wz/core/network/error_interceptor.dart';
import 'package:framework_wz/core/network/mock_interceptor.dart';
import 'package:framework_wz/core/storage/storage.dart';
import 'package:framework_wz/features/auth/data/auth_repository_impl.dart';
import 'package:framework_wz/features/auth/domain/auth_models.dart';

import '../../helpers/fixture_loader.dart';

/// TC-AUTH-001..006 — repository-level behavior.
void main() {
  late SecureStore secure;
  late PrefsStore prefs;
  late Dio dio;
  late AuthRepositoryImpl repo;

  setUp(() {
    secure = InMemorySecureStore();
    prefs = InMemoryPrefsStore();
    dio = Dio(BaseOptions(baseUrl: 'https://test'));
    dio.interceptors.add(AuthInterceptor(secure));
    dio.interceptors.add(MockInterceptor(
      fixtureLoader: loadFixture,
      delay: Duration.zero,
    ));
    dio.interceptors.add(ErrorInterceptor());
    repo = AuthRepositoryImpl(dio: dio, secure: secure, prefs: prefs);
  });

  test('TC-AUTH-001 admin/123456 returns token & persists', () async {
    final token = await repo.login('admin', '123456');
    expect(token.accessToken.isNotEmpty, isTrue);
    expect(await secure.read(StorageKeys.accessToken), token.accessToken);
    expect(await prefs.getString(StorageKeys.username), 'admin');
  });

  test('TC-AUTH-002 wrong password throws InvalidCredentials, no write', () async {
    expect(
      () => repo.login('admin', 'nope'),
      throwsA(isA<InvalidCredentialsException>()),
    );
    await Future<void>.delayed(const Duration(milliseconds: 1));
    expect(await secure.read(StorageKeys.accessToken), isNull);
  });

  test('TC-AUTH-004 isLoggedIn true after login', () async {
    await repo.login('admin', '123456');
    expect(await repo.isLoggedIn(), isTrue);
  });

  test('TC-AUTH-005 expired token clears storage and returns false', () async {
    await secure.write(StorageKeys.accessToken, 'old');
    await secure.write(StorageKeys.refreshToken, 'old');
    await secure.write(
      StorageKeys.expiresAt,
      DateTime.now().subtract(const Duration(minutes: 1)).toIso8601String(),
    );
    expect(await repo.isLoggedIn(), isFalse);
    expect(await secure.read(StorageKeys.accessToken), isNull);
  });

  test('TC-AUTH-006 logout clears storage and emits LoggedOut', () async {
    await repo.login('admin', '123456');
    final events = repo.events();
    final next = events.firstWhere((e) => e is AuthLoggedOut);
    await repo.logout();
    expect(await secure.read(StorageKeys.accessToken), isNull);
    await expectLater(next, completion(isA<AuthLoggedOut>()));
  });

  test('currentUser maps to Role.admin', () async {
    await repo.login('admin', '123456');
    final me = await repo.currentUser();
    expect(me, isNotNull);
    expect(me!.role, Role.admin);
  });

  test('editor login returns Role.editor', () async {
    await repo.login('editor', '123456');
    expect((await repo.currentUser())!.role, Role.editor);
  });
}
