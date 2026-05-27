/// Role of the current user. Mapped from server-side role string.
enum Role {
  admin,
  editor,
  guest;

  static Role fromString(String? s) => switch (s) {
        'admin' => Role.admin,
        'editor' => Role.editor,
        _ => Role.guest,
      };

  String get label => switch (this) {
        Role.admin => '管理员',
        Role.editor => '编辑',
        Role.guest => '访客',
      };
}

class AuthToken {
  const AuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, String> toJsonStrings() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'expiresAt': expiresAt.toIso8601String(),
      };

  static AuthToken? tryFromStrings(Map<String, String?> source) {
    final a = source['accessToken'];
    final r = source['refreshToken'];
    final e = source['expiresAt'];
    if (a == null || r == null || e == null) return null;
    return AuthToken(
      accessToken: a,
      refreshToken: r,
      expiresAt: DateTime.parse(e),
    );
  }

  factory AuthToken.fromJson(Map<String, Object?> json) {
    final expiresIn = json['expiresIn'];
    DateTime expiresAt;
    if (json['expiresAt'] is String) {
      expiresAt = DateTime.parse(json['expiresAt']! as String);
    } else if (expiresIn is num) {
      expiresAt = DateTime.now().add(Duration(seconds: expiresIn.toInt()));
    } else {
      expiresAt = DateTime.now().add(const Duration(hours: 2));
    }
    return AuthToken(
      accessToken: json['accessToken']! as String,
      refreshToken: (json['refreshToken'] as String?) ?? '',
      expiresAt: expiresAt,
    );
  }
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.username,
    required this.name,
    required this.role,
    this.avatarUrl,
  });

  final String id;
  final String username;
  final String name;
  final Role role;
  final String? avatarUrl;

  factory UserProfile.fromJson(Map<String, Object?> json) => UserProfile(
        id: json['id']!.toString(),
        username: json['username']! as String,
        name: (json['name'] as String?) ?? json['username']! as String,
        role: Role.fromString(json['role'] as String?),
        avatarUrl: json['avatarUrl'] as String?,
      );
}

sealed class AuthEvent {
  const AuthEvent();
}

class AuthLoggedIn extends AuthEvent {
  const AuthLoggedIn(this.profile);
  final UserProfile profile;
}

class AuthLoggedOut extends AuthEvent {
  const AuthLoggedOut();
}
