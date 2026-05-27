import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Abstract secure storage — token / refresh token.
abstract class SecureStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Future<void> clear();
}

class FlutterSecureStore implements SecureStore {
  FlutterSecureStore([FlutterSecureStorage? impl])
      : _impl = impl ?? const FlutterSecureStorage();
  final FlutterSecureStorage _impl;

  @override
  Future<String?> read(String key) => _impl.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _impl.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _impl.delete(key: key);

  @override
  Future<void> clear() => _impl.deleteAll();
}

/// In-memory store — used in tests and for non-sensitive transient data.
class InMemorySecureStore implements SecureStore {
  final Map<String, String> _data = {};

  @override
  Future<String?> read(String key) async => _data[key];

  @override
  Future<void> write(String key, String value) async {
    _data[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _data.remove(key);
  }

  @override
  Future<void> clear() async {
    _data.clear();
  }
}

/// Plain prefs wrapper.
abstract class PrefsStore {
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
  Future<List<String>?> getStringList(String key);
  Future<void> setStringList(String key, List<String> value);
  Future<void> remove(String key);
}

class SharedPrefsStore implements PrefsStore {
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<String?> getString(String key) async => (await _prefs).getString(key);

  @override
  Future<void> setString(String key, String value) async =>
      (await _prefs).setString(key, value);

  @override
  Future<List<String>?> getStringList(String key) async =>
      (await _prefs).getStringList(key);

  @override
  Future<void> setStringList(String key, List<String> value) async =>
      (await _prefs).setStringList(key, value);

  @override
  Future<void> remove(String key) async => (await _prefs).remove(key);
}

class InMemoryPrefsStore implements PrefsStore {
  final Map<String, Object> _data = {};

  @override
  Future<String?> getString(String key) async => _data[key] as String?;

  @override
  Future<void> setString(String key, String value) async {
    _data[key] = value;
  }

  @override
  Future<List<String>?> getStringList(String key) async =>
      (_data[key] as List?)?.cast<String>();

  @override
  Future<void> setStringList(String key, List<String> value) async {
    _data[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _data.remove(key);
  }
}

/// Riverpod providers — override in tests with in-memory variants.
final secureStoreProvider = Provider<SecureStore>((ref) => FlutterSecureStore());
final prefsStoreProvider = Provider<PrefsStore>((ref) => SharedPrefsStore());

/// Storage keys.
class StorageKeys {
  const StorageKeys._();
  static const accessToken = 'auth.accessToken';
  static const refreshToken = 'auth.refreshToken';
  static const expiresAt = 'auth.expiresAt';
  static const username = 'auth.username';
  static const remember = 'auth.remember';
  static const role = 'auth.role';
  static const tabs = 'shell.tabs';
}
