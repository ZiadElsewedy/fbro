import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drop/core/enums/report_category.dart';
import 'package:drop/core/enums/report_privacy.dart';
import 'package:drop/core/enums/report_recipient.dart';
import 'package:drop/core/enums/report_severity.dart';
import 'package:drop/core/enums/report_status.dart';
import 'package:drop/core/errors/failures.dart';
import 'package:drop/features/auth/domain/entities/user_entity.dart';
import 'package:drop/features/auth/domain/usecases/get_users_by_branch.dart';
import 'package:drop/features/branch/domain/repositories/branch_repository.dart';
import 'package:drop/features/reports/domain/entities/report_entity.dart';
import 'package:drop/features/reports/domain/entities/report_identity.dart';
import 'package:drop/features/reports/domain/report_urgency.dart';
import 'package:drop/features/reports/domain/repositories/report_repository.dart';
import 'package:drop/features/reports/domain/usecases/create_report.dart';
import 'package:drop/features/reports/domain/usecases/update_report.dart';
import 'package:drop/features/reports/domain/usecases/upload_report_attachment.dart';
import 'package:drop/features/task/domain/entities/activity_entry.dart';
import 'package:drop/features/task/presentation/cubit/task_cubit.dart' show PickedAttachment;
import 'report_state.dart';

/// Drives the Reports Center for all three roles. The list is scoped by role:
///   admin    → every report (realtime stream);
///   manager  → own-branch, non-admin-routed reports (realtime) + any report
///              they filed themselves;
///   employee → their own reports (one-shot fetch via the private `reporter`
///              collectionGroup; the report doc carries no creator uid).
///
/// Writes go through use cases. Notifications are produced **server-side**
/// (`onReportCreated` / `onReportUpdated`) — a manager can't read a confidential
/// reporter's identity to notify them, so the client never fans out report
/// notifications.
class ReportCubit extends Cubit<ReportState> {
  final ReportRepository _repository;
  final BranchRepository _branchRepository;
  final CreateReport _createReport;
  final UpdateReport _updateReport;
  final UploadReportAttachment _uploadReportAttachment;
  final GetUsersByBranch _getUsersByBranch;

  UserEntity? _user;
  StreamSubscription<List<ReportEntity>>? _scopeSub;
  List<ReportEntity> _scopeReports = const [];
  List<ReportEntity> _mineReports = const [];
  bool _mutating = false;

  final Map<String, UserEntity> _directory = {};
  final Set<String> _fetchedBranches = {};
  final Map<String, String> _branchNames = {};

  Map<String, UserEntity> get directory => Map.unmodifiable(_directory);
  Map<String, String> get branchNames => Map.unmodifiable(_branchNames);

  ReportCubit({
    required this._repository,
    required this._branchRepository,
    required this._createReport,
    required this._updateReport,
    required this._uploadReportAttachment,
    required this._getUsersByBranch,
  }) : super(const ReportState.initial());

  List<ReportEntity> get _reports =>
      state.maybeWhen(loaded: (r, _, _) => r, orElse: () => const []);

  ReportEntity? reportById(String id) {
    for (final r in _reports) {
      if (r.id == id) return r;
    }
    return null;
  }

  static String _scopeKey(UserEntity u) =>
      '${u.uid}:${u.role.value}:${u.branchId ?? ''}';

  Future<void> load(UserEntity user, {bool forceRefresh = false}) async {
    final inError = state.maybeWhen(error: (_) => true, orElse: () => false);
    final sameScope = _user != null && _scopeKey(_user!) == _scopeKey(user);
    if (!forceRefresh && !inError && _scopeSubActive && sameScope) return;

    if (!sameScope) {
      _directory.clear();
      _fetchedBranches.clear();
      _branchNames.clear();
      _scopeReports = const [];
      _mineReports = const [];
    }
    _user = user;
    _loadBranchNames();

    final hasReports =
        state.maybeWhen(loaded: (_, _, _) => true, orElse: () => false);
    if (!hasReports) emit(const ReportState.loading());

    await _scopeSub?.cancel();
    _scopeSub = null;

    developer.log(
      '[REPORTS] load: role=${user.role.value}, uid=${user.uid}, '
      'branch=${user.branchId ?? '-'}',
      name: 'REPORTS',
    );
    if (user.role.isAdmin) {
      // Admin sees everything (including their own) via the collection stream.
      developer.log('[REPORTS] scope=all (watchAllReports stream)', name: 'REPORTS');
      _subscribeScope(_repository.watchAllReports());
    } else if (user.role.isManager) {
      developer.log('[REPORTS] scope=branch stream + own', name: 'REPORTS');
      _subscribeScope(_repository.watchBranchReports(user.branchId ?? ''));
      await _loadMine(user); // + any admin-routed report they filed
    } else {
      developer.log('[REPORTS] scope=own (getMyReports, no stream)', name: 'REPORTS');
      await _loadMine(user); // employee: own reports only (no stream)
    }
  }

  bool get _scopeSubActive => _scopeSub != null || _user?.role.isEmployee == true;

  void _subscribeScope(Stream<List<ReportEntity>> stream) {
    _scopeSub = stream.listen(
      (reports) {
        _scopeReports = reports;
        _emitMerged();
      },
      onError: (Object error, StackTrace st) {
        // `$error` on a FirebaseException prints `[cloud_firestore/<code>] msg`.
        developer.log('[REPORTS] stream exception: $error',
            name: 'REPORTS', error: error, stackTrace: st);
        emit(const ReportState.error('Failed to load reports. Please try again.'));
      },
    );
  }

  Future<void> _loadMine(UserEntity user) async {
    developer.log('[REPORTS] loading own reports...', name: 'REPORTS');
    try {
      _mineReports = await _repository.getMyReports(user.uid);
      developer.log('[REPORTS] loaded ${_mineReports.length} own report(s)',
          name: 'REPORTS');
      _emitMerged();
    } catch (e, st) {
      developer.log('[REPORTS] getMyReports failed: $e',
          name: 'REPORTS', error: e, stackTrace: st);
      // Non-fatal for manager (they still have the branch stream); for an
      // employee it surfaces as an error so a retry can recover.
      if (user.role.isEmployee && _mineReports.isEmpty) {
        emit(const ReportState.error('Failed to load your reports.'));
      }
    }
  }

  Future<void> refresh() async {
    final user = _user;
    if (user != null) await load(user, forceRefresh: true);
  }

  /// Merges the role stream + the caller's own reports (deduped by id) and emits
  /// the urgency-ordered list, preserving any in-flight busy flag.
  void _emitMerged() {
    if (isClosed) return;
    final merged = <String, ReportEntity>{};
    for (final r in _scopeReports) {
      merged[r.id] = r;
    }
    for (final r in _mineReports) {
      merged.putIfAbsent(r.id, () => r);
    }
    final list = sortReportsByUrgency(merged.values.toList());
    emit(ReportState.loaded(list, busy: _mutating, directory: Map.of(_directory)));
    _ensureDirectory(list);
  }

  Future<void> _loadBranchNames() async {
    try {
      final list = await _branchRepository.getBranches();
      for (final b in list) {
        _branchNames[b.id] = b.name;
      }
    } catch (_) {}
  }

  Future<void> _ensureDirectory(List<ReportEntity> reports) async {
    final branchIds = <String>{
      for (final r in reports)
        if ((r.branchId ?? '').isNotEmpty) r.branchId!,
    }..removeAll(_fetchedBranches);
    if (branchIds.isEmpty) return;

    var changed = false;
    for (final branchId in branchIds) {
      _fetchedBranches.add(branchId);
      try {
        final users = await _getUsersByBranch(branchId);
        for (final u in users) {
          _directory[u.uid] = u;
          changed = true;
        }
      } catch (_) {}
    }
    if (changed && !isClosed) {
      state.mapOrNull(
        loaded: (s) => emit(s.copyWith(directory: Map.of(_directory))),
      );
    }
  }

  // ─── Filing a report (any role) ────────────────────────────────
  Future<bool> submitReport({
    required String title,
    String? description,
    required ReportCategory category,
    required ReportRecipient recipient,
    required ReportPrivacy privacy,
    required ReportSeverity severity,
    List<PickedAttachment> attachments = const [],
  }) async {
    final user = _user;
    if (user == null) return false;
    final now = DateTime.now();
    final base = ReportEntity(
      id: '',
      branchId: user.branchId,
      title: title.trim(),
      description: description?.trim(),
      category: category,
      recipient: recipient,
      privacy: privacy,
      severity: severity,
      status: ReportStatus.newReport,
      // Denormalized name only for a normal report (the model enforces this too).
      reporterDisplayName: privacy.exposesName ? user.displayName : null,
      activityLog: [
        ActivityEntry(
          status: 'created',
          actorId: _reporterActorId(privacy),
          actorName: _reporterActorName(privacy),
          at: now,
        ),
      ],
    );
    final identity = ReportIdentity(
      reportId: '',
      createdByUserId: user.uid,
      createdByName: user.displayName,
      privacy: privacy,
      branchId: user.branchId,
    );

    final ok = await _mutate(() async {
      var created = await _createReport(base, identity);
      if (attachments.isNotEmpty) {
        final uploaded = await Future.wait([
          for (final a in attachments)
            _uploadReportAttachment(
              reportId: created.id,
              file: a.file,
              type: a.type,
              // De-identify the uploader on a confidential/anonymous report.
              uploadedBy: _reporterActorId(privacy),
              uploadedByName: _reporterActorName(privacy),
              durationMs: a.durationMs,
            ),
        ]);
        created = created.copyWith(attachments: uploaded);
        await _updateReport(created);
      }
    });
    // The employee / manager "mine" list is a one-shot fetch — re-pull it so the
    // freshly-filed report appears immediately (the admin stream self-updates).
    if (ok && !user.role.isAdmin) await _loadMine(user);
    return ok;
  }

  // ─── Recipient actions (manager / admin) — status only, no ownership ──
  Future<void> markUnderReview(ReportEntity r) =>
      _setStatus(r, ReportStatus.underReview);
  Future<void> markWaitingReply(ReportEntity r) =>
      _setStatus(r, ReportStatus.waitingReply);
  Future<void> resolve(ReportEntity r) =>
      _setStatus(r, ReportStatus.resolved);

  /// Reopen a resolved report → back Under Review.
  Future<void> reopen(ReportEntity r) =>
      _setStatus(r, ReportStatus.underReview);

  Future<bool> _setStatus(ReportEntity report, ReportStatus to) {
    if (report.status == to || !report.status.canTransitionTo(to)) {
      // Silent no-op if it's already there / not a legal move (keeps the UI calm).
      return Future.value(false);
    }
    return _mutate(() async {
      final now = DateTime.now();
      await _updateReport(report.copyWith(
        status: to,
        resolvedAt: to == ReportStatus.resolved ? now : null,
        activityLog: [
          ...report.activityLog,
          ActivityEntry(
            status: to.value,
            actorId: _user?.uid ?? '',
            actorName: _user?.displayName,
            at: now,
          ),
        ],
      ));
    });
  }

  // ─── Conversation replies (reporter OR recipient) ──────────────
  Future<void> addComment(ReportEntity report, String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _user == null) return Future<void>.value();
    // The employee viewing this is always the reporter of their own report —
    // de-identify their reply on a confidential report so the manager reading
    // the thread can't resolve them.
    final asReporter = _user!.role.isEmployee;
    final hide = asReporter && report.privacy.isConfidential;
    final actorId = hide ? '' : _user!.uid;
    final actorName = hide ? report.senderLabel : _user!.displayName;
    return _mutate(() => _updateReport(report.copyWith(
          activityLog: [
            ...report.activityLog,
            ActivityEntry(
              status: ReportEntity.commentStatus,
              actorId: actorId,
              actorName: actorName,
              at: DateTime.now(),
              note: trimmed,
            ),
          ],
        )));
  }

  /// Fetches a single report by id (a deep-link that isn't in the current
  /// scoped list). Returns null if it doesn't exist / isn't readable.
  Future<ReportEntity?> fetchReport(String reportId) async {
    try {
      return await _repository.getReport(reportId);
    } catch (_) {
      return null;
    }
  }

  /// Reads the private reporter identity — an admin revealing a confidential
  /// sender (or the owner reading their own). Returns null on failure/absence.
  Future<ReportIdentity?> revealReporter(String reportId) async {
    try {
      return await _repository.revealReporter(reportId);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteReport(String reportId) =>
      _mutate(() => _repository.deleteReport(reportId));

  // ─── Directory helper for the assignee picker ──────────────────
  Future<List<UserEntity>> branchMembers(String branchId) async {
    try {
      return await _getUsersByBranch(branchId);
    } catch (_) {
      return const [];
    }
  }

  // ─── Internals ─────────────────────────────────────────────────
  // A confidential report hides the reporter — their opening entry + uploads
  // carry no uid/name (only an admin can reveal them via the identity subdoc).
  String _reporterActorId(ReportPrivacy p) =>
      p.isNormal ? (_user?.uid ?? '') : '';

  String? _reporterActorName(ReportPrivacy p) =>
      p.isNormal ? _user?.displayName : 'Confidential Sender';

  Future<bool> _mutate(Future<void> Function() action) async {
    if (_user == null || _mutating) return false;
    final prev = _reports;
    _mutating = true;
    emit(ReportState.loaded(prev, busy: true, directory: Map.of(_directory)));
    try {
      await action();
      _mutating = false;
      emit(ReportState.loaded(_reports,
          busy: false, directory: Map.of(_directory)));
      // Non-admin roles read (some of) their list from the one-shot `mine`
      // fetch, which no stream refreshes — re-pull it so a comment / transition
      // on an own report reflects immediately (the admin stream self-updates).
      final user = _user;
      if (user != null && !user.role.isAdmin) await _loadMine(user);
      return true;
    } on Failure catch (e) {
      _mutating = false;
      emit(ReportState.error(e.message));
      emit(ReportState.loaded(prev, directory: Map.of(_directory)));
      return false;
    } catch (_) {
      _mutating = false;
      emit(const ReportState.error('Something went wrong. Please try again.'));
      emit(ReportState.loaded(prev, directory: Map.of(_directory)));
      return false;
    }
  }

  @override
  Future<void> close() {
    _scopeSub?.cancel();
    return super.close();
  }
}
