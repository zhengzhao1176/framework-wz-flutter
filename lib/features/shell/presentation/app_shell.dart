import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../application/menu_models.dart';
import '../application/menu_providers.dart';
import '../application/tabs_controller.dart';
import 'breadcrumb.dart';
import 'sidebar.dart';
import 'top_bar.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  String? _lastSyncedLocation;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    // Re-sync once menus finish loading — handles the case where the user
    // lands on a deep link before MenuRepository resolves.
    ref.listen<AsyncValue<List<MenuNode>>>(menuListProvider, (prev, next) {
      if (prev?.hasValue != true && next.hasValue) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _syncTabs(GoRouterState.of(context).matchedLocation),
        );
      }
    });

    if (location != _lastSyncedLocation) {
      _lastSyncedLocation = location;
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncTabs(location));
    }

    return LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth;
        final isSmall = AppBreakpoints.isSmall(width);
        final isMedium = AppBreakpoints.isMedium(width);
        return Scaffold(
          drawer: isSmall ? const Drawer(child: Sidebar()) : null,
          body: Row(
            children: [
              if (!isSmall) Sidebar(collapsed: isMedium),
              Expanded(
                child: Column(
                  children: [
                    TopBar(showMenuButton: isSmall),
                    // Tabs bar removed to match the Vue original (no tabs).
                    const Breadcrumb(),
                    Expanded(
                      child: Container(
                        color: AppColors.bgPage,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: widget.child,
                      ),
                    ),
                    const AppFooter(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _syncTabs(String location) {
    if (!mounted) return;
    if (location == AppRoutes.login) return;
    final menus = ref.read(menuListProvider).valueOrNull ?? const <MenuNode>[];
    final trail = pathTo(location, menus);
    if (trail.isEmpty) return;
    final leaf = trail.last;
    if (leaf.path == null) return;
    ref.read(tabsControllerProvider.notifier).open(
          TabItem(key: leaf.key, title: leaf.title, path: leaf.path!),
        );
  }
}
