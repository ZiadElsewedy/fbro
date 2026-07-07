import 'package:flutter_test/flutter_test.dart';
import 'package:drop/core/enums/request_approval_policy.dart';
import 'package:drop/core/enums/request_type.dart';
import 'package:drop/core/enums/user_role.dart';
import 'package:drop/features/requests/domain/request_field_spec.dart';
import 'package:drop/features/requests/domain/request_schema.dart';

void main() {
  group('RequestSchema.fieldsFor', () {
    test('every request type declares at least one field', () {
      for (final t in RequestType.values) {
        expect(RequestSchema.fieldsFor(t), isNotEmpty, reason: '$t has no fields');
      }
    });

    test('field keys are unique within a type', () {
      for (final t in RequestType.values) {
        final keys = RequestSchema.fieldsFor(t).map((f) => f.key).toList();
        expect(keys.toSet().length, keys.length, reason: '$t has duplicate keys');
      }
    });

    test('employee discount collects product (required), size (optional), reason',
        () {
      final fields = RequestSchema.fieldsFor(RequestType.employeeDiscount);
      expect(fields.map((f) => f.key), ['product', 'size', 'reason']);
      expect(fields[0].required, isTrue);
      expect(fields[1].required, isFalse);
      expect(fields[2].kind, RequestFieldKind.multiline);
    });

    test('leave store captures a time-typed expected return', () {
      final fields = RequestSchema.fieldsFor(RequestType.leaveStore);
      final returnBy = fields.firstWhere((f) => f.key == 'returnBy');
      expect(returnBy.kind, RequestFieldKind.time);
    });

    test('stock request captures a numeric quantity', () {
      final fields = RequestSchema.fieldsFor(RequestType.stockRequest);
      final qty = fields.firstWhere((f) => f.key == 'quantity');
      expect(qty.kind, RequestFieldKind.number);
    });
  });

  group('RequestSchema.summaryFor', () {
    test('picks the first non-empty textual field', () {
      final summary = RequestSchema.summaryFor(
        RequestType.employeeDiscount,
        {'product': 'Nike Air', 'size': '42', 'reason': 'gift'},
      );
      expect(summary, 'Nike Air');
    });

    test('falls back to the type label when nothing is filled', () {
      expect(
        RequestSchema.summaryFor(RequestType.maintenance, const {}),
        'Maintenance',
      );
    });

    test('skips a blank leading field and uses the next textual one', () {
      final summary = RequestSchema.summaryFor(
        RequestType.employeeDiscount,
        {'product': '   ', 'reason': 'staff purchase'},
      );
      expect(summary, 'staff purchase');
    });
  });

  group('RequestType.approvalPolicy', () {
    test('cash requests are admin-only (reach ownership)', () {
      expect(RequestType.cashRequest.approvalPolicy,
          RequestApprovalPolicy.adminOnly);
    });

    test('everyday floor decisions stay with the manager', () {
      expect(RequestType.leaveStore.approvalPolicy,
          RequestApprovalPolicy.managerOnly);
      expect(RequestType.employeeDiscount.approvalPolicy,
          RequestApprovalPolicy.managerOnly);
    });
  });

  group('RequestApprovalPolicy.canDecide', () {
    test('admin can decide anything, including admin-only', () {
      for (final p in RequestApprovalPolicy.values) {
        expect(p.canDecide(UserRole.admin, isOwnBranchManager: false), isTrue);
      }
    });

    test('own-branch manager can decide unless admin-only', () {
      expect(
          RequestApprovalPolicy.managerOnly
              .canDecide(UserRole.manager, isOwnBranchManager: true),
          isTrue);
      expect(
          RequestApprovalPolicy.adminOnly
              .canDecide(UserRole.manager, isOwnBranchManager: true),
          isFalse);
    });

    test('a manager of another branch cannot decide', () {
      expect(
          RequestApprovalPolicy.managerOrAdmin
              .canDecide(UserRole.manager, isOwnBranchManager: false),
          isFalse);
    });

    test('an employee can never decide', () {
      expect(
          RequestApprovalPolicy.managerOnly
              .canDecide(UserRole.employee, isOwnBranchManager: false),
          isFalse);
    });

    test('notification routing flags follow the policy', () {
      expect(RequestApprovalPolicy.managerOnly.notifiesAdmins, isFalse);
      expect(RequestApprovalPolicy.managerOnly.notifiesManagers, isTrue);
      expect(RequestApprovalPolicy.adminOnly.notifiesManagers, isFalse);
      expect(RequestApprovalPolicy.adminOnly.notifiesAdmins, isTrue);
      expect(RequestApprovalPolicy.managerOrAdmin.notifiesManagers, isTrue);
      expect(RequestApprovalPolicy.managerOrAdmin.notifiesAdmins, isTrue);
    });
  });
}
