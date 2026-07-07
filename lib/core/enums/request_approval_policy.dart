import 'package:drop/core/enums/user_role.dart';

/// Who is allowed to decide (approve / reject / complete) an operations request,
/// declared per [RequestType] and denormalized onto `requests/{id}.approvalPolicy`
/// so the Firestore rule, the `onRequest*` Cloud Functions (notification routing),
/// and the status-control UI all enforce the same gate. Adding a new request type
/// can pick any policy without touching security rules.
///
/// Note: an admin is global (admin ⊇ manager) and can decide *anything*, so the
/// only policy that actually *excludes* someone is [adminOnly] (blocks managers).
/// [managerOnly] vs [managerOrAdmin] differ in **who is notified** on create — a
/// manager-only request pings branch managers; a manager-or-admin one also pings
/// admins.
enum RequestApprovalPolicy {
  /// The request's own-branch manager (or an admin). Notifies managers on create.
  managerOnly,

  /// The own-branch manager OR any admin. Notifies managers + admins on create.
  managerOrAdmin,

  /// Admin only — the branch manager cannot decide (e.g. cash handling).
  adminOnly;

  String get value => name;

  bool get isAdminOnly => this == RequestApprovalPolicy.adminOnly;

  /// Whether an admin is a routed recipient on create (drives notifications).
  bool get notifiesAdmins => this != RequestApprovalPolicy.managerOnly;

  /// Whether branch managers are routed recipients on create.
  bool get notifiesManagers => this != RequestApprovalPolicy.adminOnly;

  String get label => switch (this) {
        RequestApprovalPolicy.managerOnly => 'Manager',
        RequestApprovalPolicy.managerOrAdmin => 'Manager or Admin',
        RequestApprovalPolicy.adminOnly => 'Admin only',
      };

  /// Whether a user of [role] may decide a request under this policy.
  /// [isOwnBranchManager] is true when the caller is a manager of the request's
  /// branch (an admin is global, so branch never matters for them). Mirrors the
  /// `firestore.rules` update gate so the UI never offers an action the server
  /// would reject.
  bool canDecide(UserRole role, {required bool isOwnBranchManager}) {
    if (role.isAdmin) return true; // admin ⊇ manager — decides anything
    if (role.isManager && isOwnBranchManager) return !isAdminOnly;
    return false;
  }

  /// Parses the stored string; unknown/missing → [managerOrAdmin] (the safe
  /// default — never silently escalates to admin-only or manager-only).
  static RequestApprovalPolicy fromString(String? raw) {
    for (final p in RequestApprovalPolicy.values) {
      if (p.name == raw) return p;
    }
    return RequestApprovalPolicy.managerOrAdmin;
  }
}
