import 'package:flutter_test/flutter_test.dart';
import 'package:drop/core/enums/request_status.dart';
import 'package:drop/core/enums/request_type.dart';
import 'package:drop/core/enums/user_role.dart';
import 'package:drop/features/auth/domain/entities/user_entity.dart';
import 'package:drop/features/requests/domain/entities/request_entity.dart';
import 'package:drop/features/requests/domain/request_access.dart';

void main() {
  UserEntity user(String uid, UserRole role, {String? branch}) => UserEntity(
        uid: uid,
        email: '$uid@x.com',
        authProvider: 'password',
        role: role,
        branchId: branch,
      );

  RequestEntity request({
    String requesterId = 'emp1',
    String? branch = 'b1',
    RequestType type = RequestType.leaveStore,
    RequestStatus status = RequestStatus.pending,
  }) =>
      RequestEntity(
        id: 'r1',
        branchId: branch,
        type: type,
        approvalPolicy: type.approvalPolicy,
        status: status,
        requesterId: requesterId,
      );

  group('canAccessRequest', () {
    test('the requester, an admin, and an own-branch manager can access', () {
      final r = request(requesterId: 'emp1', branch: 'b1');
      expect(canAccessRequest(user('emp1', UserRole.employee, branch: 'b1'), r),
          isTrue);
      expect(canAccessRequest(user('admin', UserRole.admin), r), isTrue);
      expect(
          canAccessRequest(user('mgr', UserRole.manager, branch: 'b1'), r),
          isTrue);
    });

    test('a manager of another branch cannot access', () {
      final r = request(branch: 'b1');
      expect(
          canAccessRequest(user('mgr', UserRole.manager, branch: 'b2'), r),
          isFalse);
    });

    test('an unrelated employee cannot access', () {
      final r = request(requesterId: 'emp1', branch: 'b1');
      expect(
          canAccessRequest(user('emp2', UserRole.employee, branch: 'b1'), r),
          isFalse);
    });
  });

  group('canDecideRequest', () {
    test('own-branch manager decides a manager-policy request', () {
      final r = request(type: RequestType.leaveStore, branch: 'b1');
      expect(
          canDecideRequest(user('mgr', UserRole.manager, branch: 'b1'), r),
          isTrue);
    });

    test('manager CANNOT decide an admin-only (cash) request', () {
      final r = request(type: RequestType.cashRequest, branch: 'b1');
      expect(
          canDecideRequest(user('mgr', UserRole.manager, branch: 'b1'), r),
          isFalse);
    });

    test('admin can decide even an admin-only request', () {
      final r = request(type: RequestType.cashRequest, branch: 'b1');
      expect(canDecideRequest(user('admin', UserRole.admin), r), isTrue);
    });

    test('the requesting employee can never decide their own request', () {
      final r = request(requesterId: 'emp1', branch: 'b1');
      expect(
          canDecideRequest(user('emp1', UserRole.employee, branch: 'b1'), r),
          isFalse);
    });
  });

  group('canCancelRequest', () {
    test('requester can cancel only while pending', () {
      final pending = request(requesterId: 'emp1', status: RequestStatus.pending);
      final approved =
          request(requesterId: 'emp1', status: RequestStatus.approved);
      final u = user('emp1', UserRole.employee, branch: 'b1');
      expect(canCancelRequest(u, pending), isTrue);
      expect(canCancelRequest(u, approved), isFalse);
    });

    test('a manager cannot cancel someone else\'s request', () {
      final r = request(requesterId: 'emp1', status: RequestStatus.pending);
      expect(
          canCancelRequest(user('mgr', UserRole.manager, branch: 'b1'), r),
          isFalse);
    });
  });

  group('canCommentOnRequest', () {
    test('participants can comment while active, not once terminal', () {
      final active = request(status: RequestStatus.pending);
      final done = request(status: RequestStatus.completed);
      final mgr = user('mgr', UserRole.manager, branch: 'b1');
      expect(canCommentOnRequest(mgr, active), isTrue);
      expect(canCommentOnRequest(mgr, done), isFalse);
    });
  });
}
