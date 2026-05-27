import 'package:flutter_test/flutter_test.dart';
import 'package:framework_wz/core/router/app_routes.dart';
import 'package:framework_wz/core/storage/storage.dart';
import 'package:framework_wz/features/shell/application/tabs_controller.dart';

/// TC-TAB-001..007 — tabs state machine.
void main() {
  late InMemoryPrefsStore prefs;
  late TabsController ctrl;

  setUp(() {
    prefs = InMemoryPrefsStore();
    ctrl = TabsController(prefs);
  });

  TabItem t(String key, [String? path]) =>
      TabItem(key: key, title: key, path: path ?? '/$key');

  test('TC-TAB-001 opening a path adds a tab and activates it', () {
    ctrl.open(t('dashboard'));
    expect(ctrl.state.length, 1);
    expect(ctrl.state.activeKey, 'dashboard');
  });

  test('TC-TAB-002 reopening same key keeps single tab, just activates', () {
    ctrl.open(t('a'));
    ctrl.open(t('b'));
    ctrl.open(t('c'));
    ctrl.open(t('b'));
    expect(ctrl.state.length, 3);
    expect(ctrl.state.activeKey, 'b');
  });

  test('TC-TAB-004 closing non-active tab keeps active', () {
    ctrl.open(t('a'));
    ctrl.open(t('b'));
    ctrl.open(t('c'));
    ctrl.activate('c');
    final next = ctrl.close('a');
    expect(next, isNull); // no navigation needed
    expect(ctrl.state.length, 2);
    expect(ctrl.state.activeKey, 'c');
  });

  test('TC-TAB-005 closing active prefers left neighbor', () {
    ctrl.open(t('a'));
    ctrl.open(t('b'));
    ctrl.open(t('c'));
    ctrl.activate('b');
    final next = ctrl.close('b');
    expect(ctrl.state.activeKey, 'a');
    expect(next, '/a');
  });

  test('TC-TAB-005 closing first active falls back to next neighbor', () {
    ctrl.open(t('a'));
    ctrl.open(t('b'));
    ctrl.activate('a');
    final next = ctrl.close('a');
    expect(ctrl.state.activeKey, 'b');
    expect(next, '/b');
  });

  test('closing only tab returns to dashboard', () {
    ctrl.open(t('a'));
    final next = ctrl.close('a');
    expect(ctrl.state.length, 0);
    expect(next, AppRoutes.dashboard);
  });

  test('TC-TAB-006 closeOthers keeps only the target', () {
    ctrl.open(t('a'));
    ctrl.open(t('b'));
    ctrl.open(t('c'));
    ctrl.closeOthers('b');
    expect(ctrl.state.length, 1);
    expect(ctrl.state.items.single.key, 'b');
    expect(ctrl.state.activeKey, 'b');
  });

  test('TC-TAB-007 closeAll empties and returns to dashboard', () {
    ctrl.open(t('a'));
    ctrl.open(t('b'));
    final next = ctrl.closeAll();
    expect(ctrl.state.length, 0);
    expect(next, AppRoutes.dashboard);
  });

  test('state persists between controller instances', () async {
    ctrl.open(t('a'));
    ctrl.open(t('b'));
    await Future<void>.delayed(Duration.zero);
    final restored = TabsController(prefs);
    await Future<void>.delayed(Duration.zero);
    expect(restored.state.length, 2);
    expect(restored.state.activeKey, 'b');
  });
}
