import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/storage/storage.dart';

@immutable
class TabItem {
  const TabItem({
    required this.key,
    required this.title,
    required this.path,
    this.closable = true,
  });

  final String key;
  final String title;
  final String path;
  final bool closable;

  TabItem copyWith({String? title}) => TabItem(
        key: key,
        title: title ?? this.title,
        path: path,
        closable: closable,
      );

  Map<String, Object?> toJson() => {
        'key': key,
        'title': title,
        'path': path,
        'closable': closable,
      };

  factory TabItem.fromJson(Map<String, Object?> json) => TabItem(
        key: json['key']! as String,
        title: json['title']! as String,
        path: json['path']! as String,
        closable: (json['closable'] as bool?) ?? true,
      );

  @override
  bool operator ==(Object other) =>
      other is TabItem && other.key == key && other.path == path;

  @override
  int get hashCode => Object.hash(key, path);
}

@immutable
class TabsState {
  const TabsState({this.items = const [], this.activeKey});

  final List<TabItem> items;
  final String? activeKey;

  TabItem? get active {
    if (activeKey == null) return null;
    for (final t in items) {
      if (t.key == activeKey) return t;
    }
    return null;
  }

  int get length => items.length;

  TabsState copyWith({List<TabItem>? items, String? activeKey, bool clearActive = false}) {
    return TabsState(
      items: items ?? this.items,
      activeKey: clearActive ? null : (activeKey ?? this.activeKey),
    );
  }
}

class TabsController extends StateNotifier<TabsState> {
  TabsController(this._prefs) : super(const TabsState()) {
    unawaited(_restore());
  }

  final PrefsStore _prefs;

  Future<void> _restore() async {
    final raw = await _prefs.getString(StorageKeys.tabs);
    if (raw == null) return;
    try {
      final json = jsonDecode(raw) as Map<String, Object?>;
      final items = (json['items'] as List? ?? const [])
          .cast<Map<String, Object?>>()
          .map(TabItem.fromJson)
          .toList(growable: false);
      state = TabsState(
        items: items,
        activeKey: json['activeKey'] as String?,
      );
    } catch (_) {
      // ignore corrupt persisted state
    }
  }

  Future<void> _persist() async {
    await _prefs.setString(
      StorageKeys.tabs,
      jsonEncode({
        'items': state.items.map((t) => t.toJson()).toList(),
        'activeKey': state.activeKey,
      }),
    );
  }

  /// Open (or focus) a tab for [path]. Idempotent — opening the same path
  /// twice keeps a single tab and activates it.
  void open(TabItem item) {
    final exists = state.items.any((t) => t.key == item.key);
    final next = exists
        ? state.items
        : <TabItem>[...state.items, item];
    state = TabsState(items: next, activeKey: item.key);
    unawaited(_persist());
  }

  void activate(String key) {
    if (!state.items.any((t) => t.key == key)) return;
    state = state.copyWith(activeKey: key);
    unawaited(_persist());
  }

  /// Closes a tab. Returns the path that should be navigated to next.
  /// Behavior matches TC-TAB-005: prefer the left sibling, then right, then dashboard.
  String? close(String key) {
    final idx = state.items.indexWhere((t) => t.key == key);
    if (idx < 0) return null;
    final closing = state.items[idx];
    if (!closing.closable) return null;

    final wasActive = state.activeKey == key;
    final next = [...state.items]..removeAt(idx);

    if (next.isEmpty) {
      state = const TabsState();
      unawaited(_persist());
      return AppRoutes.dashboard;
    }

    if (wasActive) {
      final newIdx = idx == 0 ? 0 : idx - 1;
      final newActive = next[newIdx];
      state = TabsState(items: next, activeKey: newActive.key);
      unawaited(_persist());
      return newActive.path;
    }

    state = state.copyWith(items: next);
    unawaited(_persist());
    return null;
  }

  void closeOthers(String key) {
    final kept = state.items.where((t) => t.key == key || !t.closable).toList();
    state = TabsState(items: kept, activeKey: key);
    unawaited(_persist());
  }

  String? closeAll() {
    final pinned = state.items.where((t) => !t.closable).toList();
    if (pinned.isEmpty) {
      state = const TabsState();
      unawaited(_persist());
      return AppRoutes.dashboard;
    }
    state = TabsState(items: pinned, activeKey: pinned.first.key);
    unawaited(_persist());
    return pinned.first.path;
  }

  void reset() {
    state = const TabsState();
    unawaited(_persist());
  }
}

final tabsControllerProvider =
    StateNotifierProvider<TabsController, TabsState>((ref) {
  return TabsController(ref.watch(prefsStoreProvider));
});
