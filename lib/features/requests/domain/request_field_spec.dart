/// The kind of value a dynamic request field captures. Drives which input widget
/// the create form renders and how the value is typed in the request's
/// `details` map (`Map<String, dynamic>`) — numbers stay `num`, dates/times stay
/// `DateTime`, so no string-parsing round-trips.
enum RequestFieldKind {
  /// Single-line free text.
  text,

  /// Multi-line free text (a reason / description).
  multiline,

  /// A whole number (a quantity / amount). Stored as `num`.
  number,

  /// A time of day (an expected return). Stored as `DateTime`; the form uses a
  /// time picker (only the hour/minute are meaningful).
  time,

  /// A calendar date (needed-before). Stored as `DateTime`; the form uses a date
  /// picker.
  date,
}

/// One field in a request type's dynamic form. Pure data — the presentation
/// layer maps [kind] to an input widget and renders [label] / [hint]. Kept in the
/// domain so the schema is unit-testable and Flutter-free.
class RequestFieldSpec {
  /// The stable key this field is stored under in `details` (never shown).
  final String key;

  /// The human label shown above the input and in the detail view.
  final String label;

  final RequestFieldKind kind;

  /// Whether the create form blocks submission until this field has a value.
  final bool required;

  final String? hint;

  const RequestFieldSpec({
    required this.key,
    required this.label,
    this.kind = RequestFieldKind.text,
    this.required = true,
    this.hint,
  });

  bool get isTextual =>
      kind == RequestFieldKind.text || kind == RequestFieldKind.multiline;
}
