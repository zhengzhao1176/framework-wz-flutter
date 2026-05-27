import 'package:flutter_test/flutter_test.dart';
import 'package:framework_wz/core/storage/storage.dart';

void main() {
  group('InMemorySecureStore', () {
    test('write then read returns the value', () async {
      final s = InMemorySecureStore();
      await s.write('k', 'v');
      expect(await s.read('k'), 'v');
    });

    test('delete removes the key', () async {
      final s = InMemorySecureStore();
      await s.write('k', 'v');
      await s.delete('k');
      expect(await s.read('k'), isNull);
    });

    test('clear wipes everything', () async {
      final s = InMemorySecureStore();
      await s.write('a', '1');
      await s.write('b', '2');
      await s.clear();
      expect(await s.read('a'), isNull);
      expect(await s.read('b'), isNull);
    });
  });

  group('InMemoryPrefsStore', () {
    test('round-trip string', () async {
      final p = InMemoryPrefsStore();
      await p.setString('k', 'v');
      expect(await p.getString('k'), 'v');
    });

    test('round-trip string list', () async {
      final p = InMemoryPrefsStore();
      await p.setStringList('xs', ['a', 'b']);
      expect(await p.getStringList('xs'), ['a', 'b']);
    });
  });
}
