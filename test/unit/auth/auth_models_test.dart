import 'package:flutter_test/flutter_test.dart';
import 'package:framework_wz/features/auth/domain/auth_models.dart';

void main() {
  group('Role.fromString', () {
    test('maps known roles', () {
      expect(Role.fromString('admin'), Role.admin);
      expect(Role.fromString('editor'), Role.editor);
      expect(Role.fromString('guest'), Role.guest);
    });

    test('unknown / null → guest', () {
      expect(Role.fromString(null), Role.guest);
      expect(Role.fromString('unknown'), Role.guest);
    });
  });

  group('AuthToken', () {
    test('fromJson with expiresIn computes expiresAt', () {
      final t = AuthToken.fromJson({
        'accessToken': 'a',
        'refreshToken': 'r',
        'expiresIn': 60,
      });
      expect(t.accessToken, 'a');
      expect(t.isExpired, isFalse);
    });

    test('fromJson with absolute expiresAt parses ISO', () {
      final t = AuthToken.fromJson({
        'accessToken': 'a',
        'refreshToken': 'r',
        'expiresAt': '2099-01-01T00:00:00Z',
      });
      expect(t.isExpired, isFalse);
    });

    test('isExpired true after expiresAt', () {
      final t = AuthToken(
        accessToken: 'a',
        refreshToken: 'r',
        expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
      );
      expect(t.isExpired, isTrue);
    });

    test('tryFromStrings returns null when any field missing', () {
      expect(AuthToken.tryFromStrings({'accessToken': 'a'}), isNull);
    });

    test('tryFromStrings round-trips via toJsonStrings', () {
      final t = AuthToken(
        accessToken: 'a',
        refreshToken: 'r',
        expiresAt: DateTime(2099, 1, 1),
      );
      final back = AuthToken.tryFromStrings(t.toJsonStrings());
      expect(back, isNotNull);
      expect(back!.accessToken, 'a');
      expect(back.refreshToken, 'r');
      expect(back.expiresAt, DateTime(2099, 1, 1));
    });
  });
}
