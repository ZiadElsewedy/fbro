import 'package:drop/core/enums/report_recipient.dart';

/// The kind of issue a report raises, stored as a string in
/// `reports/{id}.category`. Kept deliberately short (5) so filing is fast —
/// Reports are structured escalation messages, not a taxonomy. Drives the
/// create-flow picker, the list filter, and a smart-routing suggestion
/// ([defaultRecipient]) that pre-fills the recipient — always overridable.
enum ReportCategory {
  sales,
  inventory,
  staff,
  security,
  operations;

  String get value => name;

  String get label => switch (this) {
        ReportCategory.sales => 'Sales',
        ReportCategory.inventory => 'Inventory',
        ReportCategory.staff => 'Staff',
        ReportCategory.security => 'Security',
        ReportCategory.operations => 'Operations',
      };

  /// One-line hint shown under the category in the picker.
  String get hint => switch (this) {
        ReportCategory.sales => 'Cash, refunds, discounts, mismatches',
        ReportCategory.inventory => 'Stock, missing or damaged items',
        ReportCategory.staff => 'Behavior, conflicts, complaints',
        ReportCategory.security => 'Theft, suspicious activity, safety',
        ReportCategory.operations => 'Store, equipment, day-to-day issues',
      };

  /// Smart-routing default — the recipient the create flow pre-selects (the
  /// reporter can override). Security goes straight to ownership; everything
  /// else is a branch matter the manager handles first.
  ReportRecipient get defaultRecipient => this == ReportCategory.security
      ? ReportRecipient.admin
      : ReportRecipient.manager;

  /// Parses the stored string; unknown/missing → [operations] (the broad
  /// catch-all bucket).
  static ReportCategory fromString(String? raw) {
    for (final c in ReportCategory.values) {
      if (c.name == raw) return c;
    }
    return ReportCategory.operations;
  }
}
