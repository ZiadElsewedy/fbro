import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:drop/core/enums/attachment_type.dart';
import 'package:drop/core/enums/request_status.dart';
import 'package:drop/core/enums/request_type.dart';
import 'package:drop/core/enums/user_role.dart';
import 'package:drop/features/auth/domain/entities/user_entity.dart';
import 'package:drop/features/requests/domain/entities/request_entity.dart';
import 'package:drop/features/requests/domain/entities/request_event.dart';
import 'package:drop/features/requests/domain/repositories/request_repository.dart';
import 'package:drop/features/requests/domain/usecases/add_request_comment.dart';
import 'package:drop/features/requests/domain/usecases/change_request_status.dart';
import 'package:drop/features/requests/domain/usecases/upload_request_attachment.dart';
import 'package:drop/features/requests/presentation/cubit/request_detail_cubit.dart';
import 'package:drop/features/task/domain/entities/task_attachment.dart';

/// A controllable in-memory [RequestRepository] for the detail cubit — records
/// status changes / comments and lets the test push doc + event snapshots.
class _FakeRequestRepository implements RequestRepository {
  final _requestCtrl = StreamController<RequestEntity?>.broadcast();
  final _eventsCtrl = StreamController<List<RequestEvent>>.broadcast();

  final List<({RequestStatus to, String? by})> statusChanges = [];
  final List<RequestEvent> added = [];

  void pushRequest(RequestEntity? r) => _requestCtrl.add(r);
  void pushEvents(List<RequestEvent> e) => _eventsCtrl.add(e);

  @override
  Stream<RequestEntity?> watchRequest(String requestId) => _requestCtrl.stream;

  @override
  Stream<List<RequestEvent>> watchEvents(String requestId) => _eventsCtrl.stream;

  @override
  Future<void> changeStatus(String requestId, RequestStatus to,
      {String? decidedBy, String? decidedByName}) async {
    statusChanges.add((to: to, by: decidedBy));
  }

  @override
  Future<void> addEvent(String requestId, RequestEvent event) async {
    added.add(event);
  }

  @override
  Future<TaskAttachment> uploadAttachment({
    required String requestId,
    required File file,
    required AttachmentType type,
    required String uploadedBy,
    String? uploadedByName,
    int? durationMs,
    void Function(int, int)? onProgress,
  }) async =>
      TaskAttachment(
        id: 'a',
        url: 'u',
        type: type,
        uploadedAt: DateTime.now(),
        uploadedBy: uploadedBy,
      );

  // Unused by the detail cubit.
  @override
  Stream<List<RequestEntity>> watchAllRequests() => const Stream.empty();
  @override
  Stream<List<RequestEntity>> watchBranchRequests(String branchId) =>
      const Stream.empty();
  @override
  Stream<List<RequestEntity>> watchMyRequests(String uid) => const Stream.empty();
  @override
  Future<RequestEntity?> getRequest(String requestId) async => null;
  @override
  String newRequestId() => 'new';
  @override
  Future<RequestEntity> createRequest(RequestEntity request) async => request;
  @override
  Future<void> deleteRequest(String requestId) async {}
}

void main() {
  UserEntity u(String uid, UserRole role, {String? branch}) => UserEntity(
        uid: uid,
        email: '$uid@x.com',
        authProvider: 'password',
        displayName: uid,
        role: role,
        branchId: branch,
      );

  RequestEntity req({
    RequestStatus status = RequestStatus.pending,
    RequestType type = RequestType.leaveStore,
    String requester = 'emp1',
    String? branch = 'b1',
  }) =>
      RequestEntity(
        id: 'r1',
        branchId: branch,
        type: type,
        status: status,
        requesterId: requester,
      );

  RequestDetailCubit build(_FakeRequestRepository repo, UserEntity? user) =>
      RequestDetailCubit(
        repository: repo,
        changeStatus: ChangeRequestStatus(repo),
        addComment: AddRequestComment(repo),
        uploadAttachment: UploadRequestAttachment(repo),
        user: user,
        requestId: 'r1',
      );

  test('combines the doc + events streams into loaded', () async {
    final repo = _FakeRequestRepository();
    final cubit = build(repo, u('mgr', UserRole.manager, branch: 'b1'));
    repo.pushRequest(req());
    repo.pushEvents([
      RequestEvent(
          id: 'e1', kind: RequestEventKind.comment, createdAt: DateTime(2026)),
    ]);
    await Future<void>.delayed(Duration.zero);

    final loaded = cubit.state.mapOrNull(
      loaded: (s) => (id: s.request.id, count: s.events.length),
    );
    expect(loaded, isNotNull);
    expect(loaded!.id, 'r1');
    expect(loaded.count, 1);
    await cubit.close();
  });

  test('an own-branch manager approving stamps decidedBy', () async {
    final repo = _FakeRequestRepository();
    final cubit = build(repo, u('mgr', UserRole.manager, branch: 'b1'));
    repo.pushRequest(req());
    await Future<void>.delayed(Duration.zero);

    await cubit.approve();
    expect(repo.statusChanges.single.to, RequestStatus.approved);
    expect(repo.statusChanges.single.by, 'mgr');
    await cubit.close();
  });

  test('a manager of another branch CANNOT approve', () async {
    final repo = _FakeRequestRepository();
    final cubit = build(repo, u('mgr', UserRole.manager, branch: 'b2'));
    repo.pushRequest(req(branch: 'b1'));
    await Future<void>.delayed(Duration.zero);

    await cubit.approve();
    expect(repo.statusChanges, isEmpty); // guard blocked the write
    await cubit.close();
  });

  test('approve is rejected when the request is already decided', () async {
    final repo = _FakeRequestRepository();
    final cubit = build(repo, u('mgr', UserRole.manager, branch: 'b1'));
    repo.pushRequest(req(status: RequestStatus.approved));
    await Future<void>.delayed(Duration.zero);

    await cubit.approve();
    expect(repo.statusChanges, isEmpty);
    await cubit.close();
  });

  test('a comment is a single event add, tagged by author role', () async {
    final repo = _FakeRequestRepository();
    final cubit = build(repo, u('emp1', UserRole.employee, branch: 'b1'));
    repo.pushRequest(req(requester: 'emp1'));
    await Future<void>.delayed(Duration.zero);

    final ok = await cubit.addComment('any update?');
    expect(ok, isTrue);
    expect(repo.added.single.actor, RequestEventActor.requester);
    expect(repo.added.single.text, 'any update?');
    await cubit.close();
  });
}
