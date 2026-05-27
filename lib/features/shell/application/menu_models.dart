import 'package:flutter/material.dart';

class MenuNode {
  const MenuNode({
    required this.key,
    required this.title,
    this.path,
    this.icon,
    this.children = const [],
    this.roles = const ['admin', 'editor', 'guest'],
  });

  final String key;
  final String title;
  final String? path;
  final IconData? icon;
  final List<MenuNode> children;
  final List<String> roles;

  bool get isLeaf => children.isEmpty;
  bool get hasChildren => children.isNotEmpty;

  bool allowsRole(String role) => roles.contains(role);

  factory MenuNode.fromJson(Map<String, Object?> json) => MenuNode(
        key: json['key']! as String,
        title: json['title']! as String,
        path: json['path'] as String?,
        icon: _iconFromName(json['icon'] as String?),
        roles: (json['roles'] as List?)?.cast<String>() ??
            const ['admin', 'editor', 'guest'],
        children: (json['children'] as List?)
                ?.cast<Map<String, Object?>>()
                .map(MenuNode.fromJson)
                .toList(growable: false) ??
            const [],
      );
}

IconData? _iconFromName(String? name) {
  switch (name) {
    case 'dashboard':
      return Icons.speed_outlined;
    case 'intro':
      return Icons.thumb_up_outlined;
    case 'bookmark':
      return Icons.bookmark_outline;
    case 'chart':
      return Icons.pie_chart_outline;
    case 'editor':
      return Icons.list_alt;
    case 'json':
      return Icons.merge_outlined;
    case 'table':
      return Icons.description_outlined;
    case 'permission':
      return Icons.lock_outline;
    case 'error':
      return Icons.warning_amber_outlined;
    case 'sub':
      return Icons.folder_outlined;
    default:
      return null;
  }
}

/// Walks every leaf in [roots] in pre-order. Useful for picking an active item.
Iterable<MenuNode> flattenLeaves(Iterable<MenuNode> roots) sync* {
  for (final n in roots) {
    if (n.isLeaf) {
      yield n;
    } else {
      yield* flattenLeaves(n.children);
    }
  }
}

/// Returns the parent chain (root → leaf) leading to the node with [path].
/// Used by the breadcrumb + auto-expand sidebar.
///
/// Prefers the **deepest** matching descendant — a parent node whose own path
/// is a prefix of [location] is only returned alone when no child below it
/// matches more specifically.
List<MenuNode> pathTo(String location, Iterable<MenuNode> roots) {
  for (final n in roots) {
    final inner = pathTo(location, n.children);
    if (inner.isNotEmpty) return [n, ...inner];
    if (n.path != null && location.startsWith(n.path!)) {
      return [n];
    }
  }
  return const [];
}
