import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../application/menu_models.dart';
import '../application/menu_providers.dart';

class Breadcrumb extends ConsumerWidget {
  const Breadcrumb({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menus = ref.watch(menuListProvider).valueOrNull ?? const <MenuNode>[];
    final location = GoRouterState.of(context).matchedLocation;
    final trail = pathTo(location, menus);

    final crumbs = <Widget>[
      _CrumbLink(label: '首页', onTap: () => context.go('/dashboard')),
    ];
    for (var i = 0; i < trail.length; i++) {
      crumbs.add(const _CrumbSeparator());
      final n = trail[i];
      final isLast = i == trail.length - 1;
      if (isLast || n.path == null) {
        crumbs.add(_CrumbText(n.title));
      } else {
        crumbs.add(_CrumbLink(label: n.title, onTap: () => context.go(n.path!)));
      }
    }

    // Reference (style.css):
    //   .breadcrumb { padding:.75rem 1rem; background:#fff; margin-bottom:1rem }
    //   .breadcrumb-item + .breadcrumb-item::before { color:#b0bec5; content:"/" }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 4,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFCFD8DC))),
      ),
      child: Row(children: crumbs),
    );
  }
}

class _CrumbLink extends StatelessWidget {
  const _CrumbLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          label,
          // iview breadcrumb links use the primary color so users can tell they
          // are clickable.
          style: const TextStyle(color: AppColors.primary, fontSize: 13),
        ),
      ),
    );
  }
}

class _CrumbText extends StatelessWidget {
  const _CrumbText(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Text(
        label,
        // Last (current) crumb is muted text — iview style.
        style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 13),
      ),
    );
  }
}

class _CrumbSeparator extends StatelessWidget {
  const _CrumbSeparator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        '/',
        // breadcrumb-item::before { color:#b0bec5 }
        style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 13),
      ),
    );
  }
}
