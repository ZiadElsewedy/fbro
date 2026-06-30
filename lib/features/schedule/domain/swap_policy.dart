/// Branch-level **shift-swap policy** (2026-06-25 hardening). A small, optional,
/// configurable rule set an admin attaches to a branch to constrain swaps —
/// deliberately **not** an HR rules engine. Stored as a nested map on the branch
/// doc (`branches/{id}.swapPolicy`); absent → [SwapPolicy.permissive] (the default,
/// so swaps work out of the box for any role).
///
/// A **plain immutable value object** (not freezed) — mirrors the
/// `BroadcastScheduleEntity` precedent, avoiding generated-file drift. Carries
/// value equality so it composes inside the freezed `BranchEntity`.
///
/// Only rules that can **actually change under an exchange** are modelled:
///   - [restrictToSamePosition] — role/position compatibility (Cashier ↔ Cashier;
///     a cross-position swap is blocked unless this is off or a position is unset).
///   - [minRestHours] — minimum rest between an employee's shifts after the swap.
///
/// A per-week shift **cap** is intentionally omitted: an exchange is headcount-
/// neutral per employee (you trade *which* shift, not *how many*), so a weekly cap
/// is invariant under a swap — enforcing it here would be dead validation. Cap that
/// at roster-assignment time instead.
class SwapPolicy {
  /// When true, two employees may swap only if their [UserEntity.position] match
  /// (an unset position on either side stays compatible — the permissive default).
  final bool restrictToSamePosition;

  /// Minimum hours of rest an employee must keep between adjacent shifts after the
  /// swap. Null = rule off. Computed within the loaded week only (see
  /// `SwapValidation`).
  final int? minRestHours;

  const SwapPolicy({
    this.restrictToSamePosition = false,
    this.minRestHours,
  });

  /// The default: no restrictions (any role can swap, no rest rule).
  static const SwapPolicy permissive = SwapPolicy();

  /// Whether the branch has configured any swap rule at all.
  bool get hasAnyRule => restrictToSamePosition || minRestHours != null;

  /// Pure position-compatibility test. Permissive when the rule is off or either
  /// position is unset; otherwise the (trimmed, case-insensitive) positions must
  /// match.
  bool positionsCompatible(String? a, String? b) {
    if (!restrictToSamePosition) return true;
    final pa = (a ?? '').trim().toLowerCase();
    final pb = (b ?? '').trim().toLowerCase();
    if (pa.isEmpty || pb.isEmpty) return true;
    return pa == pb;
  }

  factory SwapPolicy.fromMap(Map<String, dynamic>? map) {
    if (map == null) return permissive;
    final rest = (map['minRestHours'] as num?)?.toInt();
    return SwapPolicy(
      restrictToSamePosition: map['restrictToSamePosition'] as bool? ?? false,
      // Treat 0 / negative as "off" so a cleared field never blocks a swap.
      minRestHours: (rest != null && rest > 0) ? rest : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'restrictToSamePosition': restrictToSamePosition,
        'minRestHours': minRestHours,
      };

  SwapPolicy copyWith({
    bool? restrictToSamePosition,
    int? minRestHours,
    bool clearMinRestHours = false,
  }) =>
      SwapPolicy(
        restrictToSamePosition:
            restrictToSamePosition ?? this.restrictToSamePosition,
        minRestHours: clearMinRestHours ? null : (minRestHours ?? this.minRestHours),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SwapPolicy &&
          other.restrictToSamePosition == restrictToSamePosition &&
          other.minRestHours == minRestHours);

  @override
  int get hashCode => Object.hash(restrictToSamePosition, minRestHours);

  @override
  String toString() =>
      'SwapPolicy(restrictToSamePosition: $restrictToSamePosition, '
      'minRestHours: $minRestHours)';
}
