import 'package:drop/features/chat/domain/entities/chat_message.dart';

/// A one-line textual preview of a message's content — the body when there is
/// one, otherwise the attachment's filename, otherwise a generic label. Shared
/// by the reply-quote block in a bubble and the "Replying to …" composer banner
/// so both render the same snippet from the same rule.
String chatReplySnippet({String? body, ChatMessageAttachment? attachment}) {
  final text = (body ?? '').trim();
  if (text.isNotEmpty) return text;
  if (attachment != null) return attachment.originalFilename;
  return 'Attachment';
}
