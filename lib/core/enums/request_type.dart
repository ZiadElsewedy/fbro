import 'package:drop/core/enums/request_approval_policy.dart';

/// A predefined operations-request category. Each type declares its own
/// [approvalPolicy] and (via `RequestSchema`) its own dynamic form fields, so a
/// new type is one enum value + one schema entry — no module rewrite, no rules
/// change. Icons + longer copy live in the presentation `request_format.dart`
/// (this enum stays Flutter-free so the domain can unit-test it).
enum RequestType {
  employeeDiscount,
  leaveStore,
  giftApproval,
  stockRequest,
  maintenance,
  customerIssue,
  cashRequest,
  equipmentRequest,
  branchSupport,
  other;

  String get value => name;

  String get label => switch (this) {
        RequestType.employeeDiscount => 'Employee Discount',
        RequestType.leaveStore => 'Leave Store',
        RequestType.giftApproval => 'Gift Approval',
        RequestType.stockRequest => 'Stock Request',
        RequestType.maintenance => 'Maintenance',
        RequestType.customerIssue => 'Customer Issue',
        RequestType.cashRequest => 'Cash Request',
        RequestType.equipmentRequest => 'Equipment Request',
        RequestType.branchSupport => 'Branch Support',
        RequestType.other => 'Other',
      };

  /// A short one-line helper shown under the type in the picker.
  String get blurb => switch (this) {
        RequestType.employeeDiscount => 'Use your staff discount on a purchase',
        RequestType.leaveStore => 'Step out of the store during your shift',
        RequestType.giftApproval => 'Give a customer a complimentary gift',
        RequestType.stockRequest => 'Pull stock from another branch',
        RequestType.maintenance => 'Report something broken or unsafe',
        RequestType.customerIssue => 'Escalate a customer situation',
        RequestType.cashRequest => 'Request a cash float or change',
        RequestType.equipmentRequest => 'Ask for a tool or device',
        RequestType.branchSupport => 'Request help or cover from another branch',
        RequestType.other => 'Something else that needs approval',
      };

  /// Who may decide a request of this type. Denormalized onto the doc so rules +
  /// Cloud Functions + UI enforce the same gate. Cash reaches ownership
  /// (adminOnly); the everyday floor decisions stay with the branch manager.
  RequestApprovalPolicy get approvalPolicy => switch (this) {
        RequestType.cashRequest => RequestApprovalPolicy.adminOnly,
        RequestType.employeeDiscount => RequestApprovalPolicy.managerOnly,
        RequestType.leaveStore => RequestApprovalPolicy.managerOnly,
        RequestType.giftApproval => RequestApprovalPolicy.managerOnly,
        RequestType.maintenance => RequestApprovalPolicy.managerOnly,
        RequestType.equipmentRequest => RequestApprovalPolicy.managerOnly,
        RequestType.customerIssue => RequestApprovalPolicy.managerOrAdmin,
        RequestType.stockRequest => RequestApprovalPolicy.managerOrAdmin,
        RequestType.branchSupport => RequestApprovalPolicy.managerOrAdmin,
        RequestType.other => RequestApprovalPolicy.managerOrAdmin,
      };

  /// Parses the stored string; unknown/missing → [other] (the neutral catch-all).
  static RequestType fromString(String? raw) {
    for (final t in RequestType.values) {
      if (t.name == raw) return t;
    }
    return RequestType.other;
  }
}
