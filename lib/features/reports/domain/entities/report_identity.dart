import 'package:drop/core/enums/report_privacy.dart';

/// The reporter's identity for one report — stored in the **private** subdoc
/// `reports/{reportId}/reporter/identity`, readable ONLY by the reporter and an
/// admin (never a branch manager). Kept off the manager-readable report doc so a
/// confidential/anonymous sender can't be resolved from the report itself
/// (Firestore reads are whole-document). Mirrors the compensation-subdoc pattern
/// (`users/{uid}/private/compensation`).
///
/// A plain immutable value object (not freezed) — it never rides on a cubit
/// state, only crosses the data boundary on create + admin reveal.
class ReportIdentity {
  const ReportIdentity({
    required this.reportId,
    required this.createdByUserId,
    this.createdByName,
    this.privacy = ReportPrivacy.normal,
    this.branchId,
    this.createdAt,
  });

  /// The parent report id (denormalized so the owner's collectionGroup query on
  /// `reporter` can resolve the report without walking the path).
  final String reportId;

  /// uid of whoever filed the report.
  final String createdByUserId;

  /// Denormalized display name (best-effort) — the admin reveal + the owner's
  /// own "My Reports" list read it from here.
  final String? createdByName;

  final ReportPrivacy privacy;
  final String? branchId;
  final DateTime? createdAt;
}
