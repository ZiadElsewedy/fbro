/// Navigation payload for opening a chat thread (`/chat/:conversationId`
/// route `extra`). Carries the resolved counterpart profile so the thread can
/// show a real name + avatar in its header without a round trip — the backend
/// exposes no name for the counterpart id, so the opener (inbox tile / picker),
/// which already resolved the teammate from the Firebase directory, passes it
/// along. A bare deep link arrives without this and falls back to a generic
/// label.
class ChatThreadArgs {
  const ChatThreadArgs({
    this.counterpartUserId,
    this.counterpartName,
    this.counterpartPhotoUrl,
  });

  /// The counterpart's **backend-internal** id — for own-message alignment
  /// before the first send (never shown to the user).
  final String? counterpartUserId;

  /// The counterpart's real display name (from the Firebase directory).
  final String? counterpartName;

  /// The counterpart's avatar URL, if any.
  final String? counterpartPhotoUrl;
}
