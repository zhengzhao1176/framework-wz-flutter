import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/async_view.dart';
import '../application/menu_models.dart';
import '../application/menu_providers.dart';

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key, this.collapsed = false, this.onItemTap});

  final bool collapsed;
  final void Function(MenuNode leaf)? onItemTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menus = ref.watch(menuListProvider);
    final width = collapsed ? 64.0 : 200.0;
    final location = GoRouterState.of(context).matchedLocation;

    return Material(
      color: AppColors.bgSidebar,
      child: SizedBox(
        width: width,
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 72,
              child: Center(
                child: AppLogo(size: 52, collapsed: collapsed),
              ),
            ),
            Expanded(
              child: AsyncView<List<MenuNode>>(
                value: menus,
                dataBuilder: (data) => ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    for (final n in data)
                      _MenuItem(
                        node: n,
                        depth: 0,
                        collapsed: collapsed,
                        currentLocation: location,
                        onTap: onItemTap,
                      ),
                  ],
                ),
                loadingBuilder: () => const Center(
                  child: CircularProgressIndicator(color: Colors.white54),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatefulWidget {
  const _MenuItem({
    required this.node,
    required this.depth,
    required this.collapsed,
    required this.currentLocation,
    this.onTap,
  });

  final MenuNode node;
  final int depth;
  final bool collapsed;
  final String currentLocation;
  final void Function(MenuNode leaf)? onTap;

  @override
  State<_MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<_MenuItem> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = _isAncestorOfCurrent(widget.node, widget.currentLocation);
  }

  @override
  void didUpdateWidget(covariant _MenuItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentLocation != widget.currentLocation) {
      if (_isAncestorOfCurrent(widget.node, widget.currentLocation)) {
        setState(() => _expanded = true);
      }
    }
  }

  bool _isAncestorOfCurrent(MenuNode n, String loc) {
    for (final c in n.children) {
      if (c.path != null && loc.startsWith(c.path!)) return true;
      if (_isAncestorOfCurrent(c, loc)) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.node;
    final active = n.path != null && widget.currentLocation.startsWith(n.path!);
    final indent = widget.depth * AppSpacing.md;

    if (n.isLeaf) {
      return _LeafTile(
        node: n,
        indent: indent,
        collapsed: widget.collapsed,
        active: active,
        onTap: () {
          if (n.path != null) {
            widget.onTap?.call(n);
            GoRouter.of(context).go(n.path!);
          }
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GroupTile(
          node: n,
          indent: indent,
          collapsed: widget.collapsed,
          expanded: _expanded,
          onTap: () => setState(() => _expanded = !_expanded),
        ),
        if (_expanded)
          Column(
            children: [
              for (final c in n.children)
                _MenuItem(
                  node: c,
                  depth: widget.depth + 1,
                  collapsed: widget.collapsed,
                  currentLocation: widget.currentLocation,
                  onTap: widget.onTap,
                ),
            ],
          ),
      ],
    );
  }
}

class _LeafTile extends StatelessWidget {
  const _LeafTile({
    required this.node,
    required this.indent,
    required this.collapsed,
    required this.active,
    required this.onTap,
  });

  final MenuNode node;
  final double indent;
  final bool collapsed;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Explicit Semantics with `link`+`button` flags so Selenium / a11y tools
    // can locate each sidebar item by its title. Keys also let widget tests
    // tap items reliably.
    return Semantics(
      key: Key('sidebar.${node.key}'),
      label: node.title,
      button: true,
      link: true,
      enabled: true,
      selected: active,
      onTapHint: '导航到 ${node.title}',
      child: ExcludeSemantics(
        excluding: false,
        child: MergeSemantics(
          child: InkWell(
            onTap: onTap,
            hoverColor: AppColors.bgSidebarHover,
            child: Container(
              height: 50,
              padding: EdgeInsets.only(
                left: AppSpacing.md + indent,
                right: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: active ? const Color(0xFF409EFF) : null,
              ),
              child: Row(
                children: [
                  Icon(
                    node.icon ?? Icons.fiber_manual_record,
                    size: node.icon == null ? 8 : 18,
                    color: active
                        ? AppColors.sidebarTextActive
                        : AppColors.sidebarText,
                  ),
                  if (!collapsed) ...[
                    const SizedBox(width: AppSpacing.sm + 2),
                    Expanded(
                      child: Text(
                        node.title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: active
                              ? AppColors.sidebarTextActive
                              : AppColors.sidebarText,
                          fontWeight: active ? FontWeight.w500 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({
    required this.node,
    required this.indent,
    required this.collapsed,
    required this.expanded,
    required this.onTap,
  });

  final MenuNode node;
  final double indent;
  final bool collapsed;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: Key('sidebar.${node.key}'),
      label: node.title,
      button: true,
      enabled: true,
      expanded: expanded,
      onTapHint: expanded ? '折叠 ${node.title}' : '展开 ${node.title}',
      child: MergeSemantics(
        child: InkWell(
          onTap: onTap,
          hoverColor: AppColors.bgSidebarHover,
          child: Container(
            height: 50,
            padding: EdgeInsets.only(
              left: AppSpacing.md + indent,
              right: AppSpacing.md,
            ),
            child: Row(
              children: [
                Icon(
                  node.icon ?? Icons.folder_outlined,
                  size: 18,
                  color: AppColors.sidebarText,
                ),
                if (!collapsed) ...[
                  const SizedBox(width: AppSpacing.sm + 2),
                  Expanded(
                    child: Text(
                      node.title,
                      style: const TextStyle(
                        color: AppColors.sidebarText,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Icon(
                    expanded ? Icons.expand_more : Icons.chevron_left,
                    size: 16,
                    color: AppColors.sidebarText,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
