import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/domain/auth_models.dart';
import 'menu_models.dart';

abstract class MenuRepository {
  Future<List<MenuNode>> list(Role role);
}

class DioMenuRepository implements MenuRepository {
  DioMenuRepository(this._dio);
  final Dio _dio;

  @override
  Future<List<MenuNode>> list(Role role) async {
    final res = await _dio.get<Object?>(
      '/api/menus',
      queryParameters: {'role': role.name},
    );
    final body = res.data;
    final list = body is List
        ? body
        : (body is Map ? body['items'] as List? ?? const [] : const []);
    return list
        .cast<Map<String, Object?>>()
        .map(MenuNode.fromJson)
        .toList(growable: false);
  }
}

/// Fallback used when the network is unreachable AND no mock is loaded.
/// Mirrors the canonical fixture so tests can verify role gating.
List<MenuNode> defaultMenusForRole(Role role) {
  final all = _allMenus;
  bool keep(MenuNode n) => n.allowsRole(role.name);

  List<MenuNode> prune(List<MenuNode> input) {
    return input
        .where(keep)
        .map((n) => MenuNode(
              key: n.key,
              title: n.title,
              path: n.path,
              icon: n.icon,
              roles: n.roles,
              children: prune(n.children),
            ))
        .toList(growable: false);
  }

  return prune(all);
}

final _allMenusJson = '''
[
  {"key":"dashboard","title":"Dashboard","path":"/dashboard","icon":"dashboard"},
  {"key":"introduction","title":"介绍","path":"/introduction","icon":"intro"},
  {"key":"components","title":"component组件","icon":"bookmark","children":[
    {"key":"buttons","title":"Buttons按钮","path":"/components/buttons"},
    {"key":"hoverbuttons","title":"悬停特效按钮","path":"/components/hoverbuttons"},
    {"key":"alert","title":"Alert警告提示","path":"/components/alert"},
    {"key":"card","title":"Card卡片","path":"/components/card"},
    {"key":"datepicker","title":"DatePicker","path":"/components/datepicker"},
    {"key":"form","title":"Form表单","path":"/components/form"},
    {"key":"modal","title":"Modal对话框","path":"/components/modal"},
    {"key":"select","title":"Select选择器","path":"/components/select"},
    {"key":"spin","title":"Spin加载中","path":"/components/spin"},
    {"key":"steps","title":"Steps步骤条","path":"/components/steps"},
    {"key":"timeline","title":"Timeline时间轴","path":"/components/timeline"},
    {"key":"transfer","title":"Transfer穿梭框","path":"/components/transfer"},
    {"key":"timepicker","title":"Timepicker","path":"/components/timepicker"},
    {"key":"upload","title":"Upload上传","path":"/components/upload"}
  ]},
  {"key":"charts","title":"echart图表","icon":"chart","children":[
    {"key":"shopchart","title":"商场统计图表","path":"/charts/shopchart"},
    {"key":"radarchart","title":"雷达图","path":"/charts/radarchart"},
    {"key":"cakechart","title":"蛋糕销量图表","path":"/charts/cakechart"}
  ]},
  {"key":"table","title":"表格综合实例","path":"/table","icon":"table","roles":["admin"]},
  {"key":"jsontree","title":"JSON视图","path":"/jsontree","icon":"json"},
  {"key":"markdown","title":"Markdown","path":"/markdown","icon":"editor"}
]
''';

final List<MenuNode> _allMenus = (jsonDecode(_allMenusJson) as List)
    .cast<Map<String, Object?>>()
    .map(MenuNode.fromJson)
    .toList(growable: false);

final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  return DioMenuRepository(ref.watch(dioProvider));
});

final menuListProvider = FutureProvider<List<MenuNode>>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  final role = user?.role ?? Role.guest;
  try {
    return await ref.watch(menuRepositoryProvider).list(role);
  } catch (_) {
    return defaultMenusForRole(role);
  }
});
