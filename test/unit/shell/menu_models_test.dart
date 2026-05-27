import 'package:flutter_test/flutter_test.dart';
import 'package:framework_wz/features/shell/application/menu_models.dart';

void main() {
  final tree = [
    const MenuNode(key: 'dashboard', title: 'Dashboard', path: '/dashboard'),
    MenuNode(
      key: 'charts',
      title: 'Charts',
      children: const [
        MenuNode(key: 'line', title: 'Line', path: '/charts/line'),
        MenuNode(key: 'bar', title: 'Bar', path: '/charts/bar'),
      ],
    ),
    const MenuNode(
      key: 'admin-only',
      title: 'Admin Only',
      path: '/admin',
      roles: ['admin'],
    ),
  ];

  test('flattenLeaves walks every leaf', () {
    final leaves = flattenLeaves(tree).toList();
    expect(leaves.map((n) => n.key), ['dashboard', 'line', 'bar', 'admin-only']);
  });

  test('pathTo returns ancestor chain for nested leaf', () {
    final chain = pathTo('/charts/line', tree);
    expect(chain.map((n) => n.key), ['charts', 'line']);
  });

  test('pathTo empty when no match', () {
    expect(pathTo('/no-such', tree), isEmpty);
  });

  test('allowsRole gates per-role visibility', () {
    expect(tree.last.allowsRole('admin'), isTrue);
    expect(tree.last.allowsRole('guest'), isFalse);
  });
}
