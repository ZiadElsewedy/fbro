import 'package:drop/features/chat/domain/entities/chat_conversation.dart';
import 'package:drop/features/chat/domain/entities/chat_message.dart';

/// The confirmed, server-authoritative state of one thread, kept for instant
/// re-open. Holds only what has actually come back from the backend — pending
/// (optimistic) sends are deliberately excluded so a reopened thread never
/// shows a stuck "sending" bubble from a torn-down session.
class ChatThreadSnapshot {
  const ChatThreadSnapshot({
    required this.conversation,
    required this.messages,
    this.nextCursor,
    this.myUserId,
  });

  final ChatConversation conversation;
  final List<ChatMessage> messages;
  final String? nextCursor;
  final String? myUserId;
}

/// A tiny in-memory cache of thread snapshots, keyed by conversation id. Lets a
/// re-opened conversation paint its last-known messages **synchronously** (no
/// spinner) while the cubit refreshes from REST in the background. Process-
/// lifetime only — deliberately not persisted; the backend stays the source of
/// truth and a cold start falls back to the normal load.
///
/// A single instance is held in the DI container and shared across every
/// per-thread cubit, so the same conversation reopened later reuses its snapshot.
class ChatThreadCache {
  final Map<String, ChatThreadSnapshot> _store = {};

  ChatThreadSnapshot? get(String conversationId) => _store[conversationId];

  void put(String conversationId, ChatThreadSnapshot snapshot) =>
      _store[conversationId] = snapshot;

  void clear() => _store.clear();
}
