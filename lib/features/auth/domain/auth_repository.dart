import 'auth_models.dart';

/// Single source of truth for authentication. Implementations live in `data/`.
abstract class AuthRepository {
  Future<AuthToken> login(String username, String password);
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<UserProfile?> currentUser();
  Stream<AuthEvent> events();
}
