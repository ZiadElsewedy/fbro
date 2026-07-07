import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:drop/features/task/domain/entities/task_attachment.dart';

part 'request_event.freezed.dart';

/// What produced an event in a request's timeline. The timeline is **fully
/// event-driven**: every lifecycle transition and every comment is one immutable
/// document in `requests/{id}/events`, so extending it is a single enum value.
///
/// [submitted]        — the request itself (opening): summary + details +
///                      opening attachments. Written by `onRequestCreated`.
/// [comment]          — a normal reply from a participant (requester / approver).
/// [approved] /
/// [rejected] /
/// [completed] /
/// [cancelled]        — lifecycle markers, written server-side by
///                      `onRequestUpdated`; rendered as centered system chips.
/// [attachmentAdded]  — media added to an existing request (a comment carrying
///                      only attachments).
enum RequestEventKind {
  submitted,
  comment,
  approved,
  rejected,
  completed,
  cancelled,
  attachmentAdded;

  String get value => name;

  bool get isSubmitted => this == RequestEventKind.submitted;
  bool get isComment => this == RequestEventKind.comment;
  bool get isAttachmentAdded => this == RequestEventKind.attachmentAdded;

  /// A lifecycle/status marker rendered as a centered chip, not a bubble.
  bool get isSystem =>
      this == RequestEventKind.approved ||
      this == RequestEventKind.rejected ||
      this == RequestEventKind.completed ||
      this == RequestEventKind.cancelled;

  /// A message-style event that aligns to a side + can carry text/media.
  bool get isMessage =>
      this == RequestEventKind.comment ||
      this == RequestEventKind.attachmentAdded;

  static RequestEventKind fromString(String? raw) {
    for (final k in RequestEventKind.values) {
      if (k.name == raw) return k;
    }
    return RequestEventKind.comment;
  }
}

/// Who authored an event — drives bubble alignment / labelling independent of the
/// raw uid.
enum RequestEventActor {
  requester,
  approver,
  system;

  String get value => name;

  static RequestEventActor fromString(String? raw) {
    for (final a in RequestEventActor.values) {
      if (a.name == raw) return a;
    }
    return RequestEventActor.system;
  }
}

/// One event in a request timeline — a document in `requests/{id}/events`.
/// Append-only + immutable: a comment is a single `add`, so there is no
/// whole-array read-modify-write (the class of bug the old case `activityLog`
/// array suffered). Reuses the task [TaskAttachment] media pipeline.
@freezed
class RequestEvent with _$RequestEvent {
  const RequestEvent._();

  const factory RequestEvent({
    required String id,

    /// Author uid, or '' for a system event.
    @Default('') String authorId,

    /// Denormalized author name ("System" for lifecycle events).
    String? authorName,
    @Default(RequestEventActor.system) RequestEventActor actor,
    @Default(RequestEventKind.comment) RequestEventKind kind,
    String? text,
    @Default(<TaskAttachment>[]) List<TaskAttachment> attachments,
    required DateTime createdAt,
  }) = _RequestEvent;

  bool get isSystem => kind.isSystem;
  bool get isSubmitted => kind.isSubmitted;
  bool get isComment => kind.isComment;
  bool get hasAttachments => attachments.isNotEmpty;
  bool get hasText => (text ?? '').trim().isNotEmpty;
}
