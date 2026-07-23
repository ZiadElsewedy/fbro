import 'package:drop/core/enums/user_role.dart';
import 'package:drop/features/auth/domain/entities/user_entity.dart';
import 'package:drop/features/chat/domain/entities/chat_conversation.dart';

/// Presentation-side formatting for the chat feature (the `case_format.dart`
/// sibling). Pure functions only.

/// A stable fallback label for a conversation counterpart, used only when the
/// real profile can't be resolved from the directory (a deep link, or a
/// teammate outside the loaded branch). Deterministic — the same counterpart
/// always renders the same tag — and never exposes the raw internal id.
String chatCounterpartLabel(String counterpartUserId) {
  final compact = counterpartUserId.replaceAll('-', '').toUpperCase();
  if (compact.isEmpty) return 'Teammate';
  final tag = compact.length > 6 ? compact.substring(0, 6) : compact;
  return 'Teammate $tag';
}

/// The best display name for a resolved teammate — their display name, else
/// email, else the deterministic fallback tag for [fallbackId].
String chatDisplayName(UserEntity? user, {required String fallbackId}) {
  if (user == null) return chatCounterpartLabel(fallbackId);
  final name = user.displayName?.trim();
  if (name != null && name.isNotEmpty) return name;
  final email = user.email.trim();
  if (email.isNotEmpty) return email;
  return chatCounterpartLabel(fallbackId);
}

/// Human-readable role label, local to chat so the feature stays self-contained.
String chatRoleLabel(UserRole role) => switch (role) {
      UserRole.admin => 'Admin',
      UserRole.manager => 'Store Manager',
      UserRole.employee => 'Employee',
    };

/// The preview line for a list row. The list endpoint carries no last-message
/// body yet, so this renders an honest state line off
/// [ChatConversationSummary.lastMessageAt]; the live socket fills the real
/// preview once connected.
String chatPreviewLine(ChatConversationSummary conversation) =>
    conversation.lastMessageAt == null
        ? 'No messages yet — say hello'
        : 'Tap to open the conversation';
