import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framework_wz/features/auth/domain/auth_models.dart';
import 'package:framework_wz/features/permission/permission_page.dart';

/// TC-PERM-001..003 — role gating logic at the widget contract level.
void main() {
  test('TC-PERM-001 admin sees admin-only block', () {
    const gate = PermissionGate(
      allowedRoles: [Role.admin],
      currentRole: Role.admin,
      child: Text('secret'),
    );
    expect(gate.allowed, isTrue);
  });

  test('TC-PERM-002 editor cannot see admin-only block', () {
    const gate = PermissionGate(
      allowedRoles: [Role.admin],
      currentRole: Role.editor,
      child: Text('secret'),
    );
    expect(gate.allowed, isFalse);
  });

  test('mixed allowed list', () {
    const gate = PermissionGate(
      allowedRoles: [Role.admin, Role.editor],
      currentRole: Role.editor,
      child: Text('x'),
    );
    expect(gate.allowed, isTrue);
  });

  test('guest blocked from editor scope', () {
    const gate = PermissionGate(
      allowedRoles: [Role.admin, Role.editor],
      currentRole: Role.guest,
      child: Text('x'),
    );
    expect(gate.allowed, isFalse);
  });
}
