import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/storage.dart';
import '../data/auth_repository_impl.dart';
import '../domain/auth_models.dart';
import '../domain/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    dio: ref.watch(dioProvider),
    secure: ref.watch(secureStoreProvider),
    prefs: ref.watch(prefsStoreProvider),
  );
});

final isLoggedInProvider = FutureProvider<bool>((ref) async {
  return ref.watch(authRepositoryProvider).isLoggedIn();
});

final currentUserProvider = FutureProvider<UserProfile?>((ref) async {
  return ref.watch(authRepositoryProvider).currentUser();
});

final authEventStreamProvider = StreamProvider<AuthEvent>((ref) {
  return ref.watch(authRepositoryProvider).events();
});

/// Drives the login form. Holds [loading] + last [error].
class LoginController extends StateNotifier<LoginState> {
  LoginController(this._repo, this._ref) : super(const LoginState.idle());
  final AuthRepository _repo;
  final Ref _ref;

  Future<bool> submit(String username, String password) async {
    if (username.isEmpty) {
      state = const LoginState.invalid(field: 'username', message: '请输入用户名');
      return false;
    }
    if (password.isEmpty) {
      state = const LoginState.invalid(field: 'password', message: '请输入密码');
      return false;
    }
    state = const LoginState.loading();
    try {
      await _repo.login(username, password);
      // Force downstream providers (currentUser, menus) to re-read now that
      // we have a fresh token in storage.
      _ref.invalidate(isLoggedInProvider);
      _ref.invalidate(currentUserProvider);
      state = const LoginState.success();
      return true;
    } catch (e) {
      state = LoginState.failure('$e'.replaceFirst('Exception: ', ''));
      return false;
    }
  }

  void reset() => state = const LoginState.idle();
}

sealed class LoginState {
  const LoginState();
  const factory LoginState.idle() = LoginIdle;
  const factory LoginState.loading() = LoginLoading;
  const factory LoginState.success() = LoginSuccess;
  const factory LoginState.invalid({required String field, required String message}) =
      LoginInvalid;
  const factory LoginState.failure(String message) = LoginFailure;
}

class LoginIdle extends LoginState {
  const LoginIdle();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  const LoginSuccess();
}

class LoginInvalid extends LoginState {
  const LoginInvalid({required this.field, required this.message});
  final String field;
  final String message;
}

class LoginFailure extends LoginState {
  const LoginFailure(this.message);
  final String message;
}

final loginControllerProvider =
    StateNotifierProvider.autoDispose<LoginController, LoginState>((ref) {
  return LoginController(ref.watch(authRepositoryProvider), ref);
});
