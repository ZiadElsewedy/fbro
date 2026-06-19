import 'package:fbro/features/auth/domain/entities/user_entity.dart';

/// Best display name for a user — their display name, falling back to email.
String userDisplayName(UserEntity u) =>
    (u.displayName != null && u.displayName!.isNotEmpty)
        ? u.displayName!
        : u.email;

/// Resolves a uid to a display name from a list of branch [members].
String nameForUid(String uid, List<UserEntity> members) {
  final u = userForUid(uid, members);
  return u == null ? 'Unknown' : userDisplayName(u);
}

/// Resolves a uid to its [UserEntity] from a list of branch [members], or null.
UserEntity? userForUid(String uid, List<UserEntity> members) {
  for (final m in members) {
    if (m.uid == uid) return m;
  }
  return null;
}

/// True when [uid] is assigned to a slot but no longer belongs to the branch —
/// a **broken/orphaned reference** (the employee was moved to another branch,
/// removed, or their account is gone, while the schedule slot still holds their
/// uid). These must be surfaced explicitly and resolved, never masked as a name.
bool isOrphanAssignment(String uid, List<UserEntity> members) =>
    userForUid(uid, members) == null;

/// A short, readable fragment of a uid for surfacing a broken reference
/// (e.g. `a1b2c3…`), so an admin can identify the stale entry.
String shortUid(String uid) =>
    uid.length <= 6 ? uid : '${uid.substring(0, 6)}…';
