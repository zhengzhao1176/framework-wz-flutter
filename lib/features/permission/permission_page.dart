import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../auth/application/auth_providers.dart';
import '../auth/domain/auth_models.dart';

/// Demonstrates role-based UI visibility.
///
/// Three blocks:
///  1. admin only
///  2. admin + editor
///  3. everyone
///
/// The role chips are illustrative — switching requires re-login in production.
class PermissionPage extends ConsumerWidget {
  const PermissionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final role = userAsync.valueOrNull?.role ?? Role.guest;

    return ListView(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('当前角色：${role.label}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  '用 admin / editor / guest 三种账户登录可看到不同模块。',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        PermissionGate(
          allowedRoles: const [Role.admin],
          currentRole: role,
          child: _DemoBlock(
            title: '仅管理员可见',
            color: AppColors.primary,
            content: '这里展示用户管理、系统配置等敏感入口。',
            keyName: 'perm.admin',
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        PermissionGate(
          allowedRoles: const [Role.admin, Role.editor],
          currentRole: role,
          child: _DemoBlock(
            title: '管理员 + 编辑可见',
            color: AppColors.success,
            content: '内容编辑、富文本上传等工作流入口。',
            keyName: 'perm.editor',
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        PermissionGate(
          allowedRoles: const [Role.admin, Role.editor, Role.guest],
          currentRole: role,
          child: _DemoBlock(
            title: '所有人可见',
            color: AppColors.warning,
            content: '公开内容、帮助中心、注销账户等。',
            keyName: 'perm.everyone',
          ),
        ),
      ],
    );
  }
}

/// Renders [child] only when [currentRole] is in [allowedRoles].
/// Used both as widget-gate and to verify role-based UI in tests.
class PermissionGate extends StatelessWidget {
  const PermissionGate({
    super.key,
    required this.allowedRoles,
    required this.currentRole,
    required this.child,
    this.fallback,
  });

  final List<Role> allowedRoles;
  final Role currentRole;
  final Widget child;
  final Widget? fallback;

  bool get allowed => allowedRoles.contains(currentRole);

  @override
  Widget build(BuildContext context) {
    if (allowed) return child;
    return fallback ?? const SizedBox.shrink();
  }
}

class _DemoBlock extends StatelessWidget {
  const _DemoBlock({
    required this.title,
    required this.color,
    required this.content,
    required this.keyName,
  });

  final String title;
  final Color color;
  final String content;
  final String keyName;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key(keyName),
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: color, width: 4)),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            Text(content, style: const TextStyle(color: AppColors.textRegular)),
          ],
        ),
      ),
    );
  }
}
