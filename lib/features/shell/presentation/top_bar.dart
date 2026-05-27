import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/domain/auth_models.dart';

/// Replica of the Vue project's `<header class="app-header navbar">`.
/// CSS reference (from static/css/style.css):
///   .app-header.navbar { height:55px; background:#143f6d; }
///   .nav-item          { min-width:50px; }
///   shortcut icons     { color:#2d8cf0; }
class TopBar extends ConsumerWidget {
  const TopBar({super.key, required this.showMenuButton});

  final bool showMenuButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    return Container(
      height: 55,
      decoration: const BoxDecoration(
        color: Color(0xFF143F6D),
        border: Border(bottom: BorderSide(color: Color(0xFFCFD8DC))),
      ),
      child: Row(
        children: [
          Builder(
            builder: (ctx) => IconButton(
              key: const Key('shell.hamburger'),
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                if (showMenuButton) Scaffold.of(ctx).openDrawer();
              },
            ),
          ),
          const Expanded(child: _Shortcuts()),
          const _NotificationBell(),
          const SizedBox(width: AppSpacing.md),
          _UserMenu(user: user),
          const SizedBox(width: AppSpacing.sm),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Icon(Icons.menu, color: Colors.white70, size: 22),
          ),
        ],
      ),
    );
  }
}

class _Shortcuts extends StatelessWidget {
  const _Shortcuts();

  // From src/components/Header.vue: 4 items each `<Icon ... color="#2d8cf0">`.
  static const _items = <_Shortcut>[
    _Shortcut(Icons.mode_edit_outline, '留言管理'),
    _Shortcut(Icons.bar_chart, '浏览排行'),
    _Shortcut(Icons.cloud_outlined, '云服务器'),
    _Shortcut(Icons.emoji_events_outlined, '销量排行'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        for (final s in _items)
          SizedBox(width: 130, height: 55, child: _ShortcutButton(s)),
      ],
    );
  }
}

class _Shortcut {
  const _Shortcut(this.icon, this.label);
  final IconData icon;
  final String label;
}

class _ShortcutButton extends StatelessWidget {
  const _ShortcutButton(this.s);
  final _Shortcut s;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(s.icon, color: const Color(0xFF2D8CF0), size: 24),
          const SizedBox(height: 2),
          Text(
            s.label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded),
          color: Colors.white,
          onPressed: () {},
          tooltip: '通知',
        ),
        Positioned(
          right: 6,
          top: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.danger,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '5',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _UserMenu extends ConsumerWidget {
  const _UserMenu({this.user});
  final UserProfile? user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = user?.name ?? user?.username ?? 'admin';
    return PopupMenuButton<String>(
      tooltip: '用户菜单',
      onSelected: (v) async {
        if (v == 'logout') {
          await ref.read(authRepositoryProvider).logout();
          if (context.mounted) context.go(AppRoutes.login);
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(enabled: false, child: Text(name)),
        PopupMenuItem(enabled: false, child: Text('角色：${user?.role.label ?? '-'}')),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'logout', child: Text('退出登录')),
      ],
      child: Row(
        children: [
          ClipOval(
            child: Image.asset(
              'assets/images/avatar.jpg',
              width: 35,
              height: 35,
              fit: BoxFit.cover,
              // Fall back to a colored initial if the asset is missing.
              errorBuilder: (_, __, ___) => CircleAvatar(
                radius: 17,
                backgroundColor: const Color(0xFFFFD580),
                child: Text(
                  (name.isNotEmpty ? name[0] : '?').toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            user?.username ?? 'admin',
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// `.app-footer { background:#eceff1; color:#263238; min-height:50px; }`
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFFECEFF1),
        border: Border(top: BorderSide(color: Color(0xFFCFD8DC))),
      ),
      child: const Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'WZ',
              style: TextStyle(color: AppColors.primary, fontSize: 13),
            ),
            TextSpan(
              text: ' © 2017 creativeLabs. Powered by ',
              style: TextStyle(color: Color(0xFF263238), fontSize: 13),
            ),
            TextSpan(
              text: 'WZ',
              style: TextStyle(color: AppColors.primary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
