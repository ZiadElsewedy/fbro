import 'package:drop/core/enums/request_type.dart';
import 'package:drop/features/requests/domain/request_field_spec.dart';

/// The dynamic-form schema for operations requests — the single source of truth
/// mapping each [RequestType] to the fields it collects. Pure Dart with no
/// infrastructure, so it is trivially unit-tested and **a new type is a one-entry
/// change here** (plus the enum value + its approval policy).
///
/// Field values persist in `requests/{id}.details` as a `Map<String, dynamic>`
/// keyed by [RequestFieldSpec.key], typed per [RequestFieldKind]. Show only the
/// fields relevant to the chosen type — never one giant generic form.
class RequestSchema {
  const RequestSchema._();

  static List<RequestFieldSpec> fieldsFor(RequestType type) {
    switch (type) {
      case RequestType.employeeDiscount:
        return const [
          RequestFieldSpec(key: 'product', label: 'Product'),
          RequestFieldSpec(key: 'size', label: 'Size', required: false),
          RequestFieldSpec(
              key: 'reason',
              label: 'Reason',
              kind: RequestFieldKind.multiline),
        ];
      case RequestType.leaveStore:
        return const [
          RequestFieldSpec(
              key: 'reason',
              label: 'Reason',
              kind: RequestFieldKind.multiline,
              hint: 'Why do you need to step out?'),
          RequestFieldSpec(
              key: 'returnBy',
              label: 'Expected return',
              kind: RequestFieldKind.time),
        ];
      case RequestType.giftApproval:
        return const [
          RequestFieldSpec(key: 'giftType', label: 'Gift type'),
          RequestFieldSpec(
              key: 'reason',
              label: 'Reason',
              kind: RequestFieldKind.multiline),
          RequestFieldSpec(
              key: 'customerName', label: 'Customer name', required: false),
        ];
      case RequestType.stockRequest:
        return const [
          RequestFieldSpec(key: 'product', label: 'Product'),
          RequestFieldSpec(
              key: 'quantity',
              label: 'Quantity',
              kind: RequestFieldKind.number),
          RequestFieldSpec(
              key: 'neededBy',
              label: 'Needed before',
              kind: RequestFieldKind.date,
              required: false),
        ];
      case RequestType.maintenance:
        return const [
          RequestFieldSpec(key: 'location', label: 'Location'),
          RequestFieldSpec(
              key: 'description',
              label: 'Description',
              kind: RequestFieldKind.multiline,
              hint: 'What is broken or unsafe?'),
        ];
      case RequestType.customerIssue:
        return const [
          RequestFieldSpec(
              key: 'description',
              label: 'What happened',
              kind: RequestFieldKind.multiline),
          RequestFieldSpec(
              key: 'customerName', label: 'Customer name', required: false),
        ];
      case RequestType.cashRequest:
        return const [
          RequestFieldSpec(
              key: 'amount', label: 'Amount', kind: RequestFieldKind.number),
          RequestFieldSpec(
              key: 'reason',
              label: 'Reason',
              kind: RequestFieldKind.multiline),
        ];
      case RequestType.equipmentRequest:
        return const [
          RequestFieldSpec(key: 'item', label: 'Item'),
          RequestFieldSpec(
              key: 'reason',
              label: 'Reason',
              kind: RequestFieldKind.multiline),
        ];
      case RequestType.branchSupport:
        return const [
          RequestFieldSpec(
              key: 'description',
              label: 'What you need',
              kind: RequestFieldKind.multiline),
          RequestFieldSpec(
              key: 'neededBy',
              label: 'Needed before',
              kind: RequestFieldKind.date,
              required: false),
        ];
      case RequestType.other:
        return const [
          RequestFieldSpec(
              key: 'details',
              label: 'Details',
              kind: RequestFieldKind.multiline),
        ];
    }
  }

  /// The one-line summary shown on cards / previews / notifications for a request
  /// of [type] given its captured [details]. Picks the first non-empty textual
  /// field (product / reason / description…), falling back to the type label.
  /// Pure + deterministic — presentation formats dates/times separately.
  static String summaryFor(RequestType type, Map<String, dynamic> details) {
    for (final spec in fieldsFor(type)) {
      if (!spec.isTextual) continue;
      final v = (details[spec.key] ?? '').toString().trim();
      if (v.isNotEmpty) return v;
    }
    return type.label;
  }
}
