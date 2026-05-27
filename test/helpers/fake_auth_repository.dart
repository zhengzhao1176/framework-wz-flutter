import 'dart:async';

import 'package:framework_wz/core/error/exceptions.dart';
import 'package:framework_wz/features/auth/domain/auth_models.dart';
import 'package:framework_wz/features/auth/domain/auth_repository.dart';

/// Configurable fake — used by widget tests so they don't touch dio/storage.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    this.throwOn,
    this.delay = Duration.zero,
    Role role = Role.admin,
  }) : _role = role;

  final String? throwOn;
  final Duration delay;
  Role _role;

  bool _loggedIn = false;
  final StreamController<AuthEvent> _events = StreamController.broadcast();

  @override
  Future<AuthToken> login(String username, String password) async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    if (throwOn != null && password == throwOn) {
      throw const InvalidCredentialsException();
    }
    _loggedIn = true;
    _role = Role.fromString(username);
    _events.add(AuthLoggedIn(UserProfile(
      id: '1',
      username: username,
      name: username,
      role: _role,
    )));
    return AuthToken(
      accessToken: 'fake-$username',
      refreshToken: 'fake-r',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
  }

  @override
  Future<void> logout() async {
    _loggedIn = false;
    _events.add(const AuthLoggedOut());
  }

  @override
  Future<bool> isLoggedIn() async => _loggedIn;

  @override
  Future<UserProfile?> currentUser() async => _loggedIn
      ? UserProfile(id: '1', username: _role.name, name: _role.label, role: _role)
      : null;

  @override
  Stream<AuthEvent> events() => _events.stream;
}
