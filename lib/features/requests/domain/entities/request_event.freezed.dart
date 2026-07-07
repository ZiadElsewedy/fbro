// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'request_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$RequestEvent {
  String get id => throw _privateConstructorUsedError;

  /// Author uid, or '' for a system event.
  String get authorId => throw _privateConstructorUsedError;

  /// Denormalized author name ("System" for lifecycle events).
  String? get authorName => throw _privateConstructorUsedError;
  RequestEventActor get actor => throw _privateConstructorUsedError;
  RequestEventKind get kind => throw _privateConstructorUsedError;
  String? get text => throw _privateConstructorUsedError;
  List<TaskAttachment> get attachments => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of RequestEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RequestEventCopyWith<RequestEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RequestEventCopyWith<$Res> {
  factory $RequestEventCopyWith(
    RequestEvent value,
    $Res Function(RequestEvent) then,
  ) = _$RequestEventCopyWithImpl<$Res, RequestEvent>;
  @useResult
  $Res call({
    String id,
    String authorId,
    String? authorName,
    RequestEventActor actor,
    RequestEventKind kind,
    String? text,
    List<TaskAttachment> attachments,
    DateTime createdAt,
  });
}

/// @nodoc
class _$RequestEventCopyWithImpl<$Res, $Val extends RequestEvent>
    implements $RequestEventCopyWith<$Res> {
  _$RequestEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RequestEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? authorId = null,
    Object? authorName = freezed,
    Object? actor = null,
    Object? kind = null,
    Object? text = freezed,
    Object? attachments = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            authorId: null == authorId
                ? _value.authorId
                : authorId // ignore: cast_nullable_to_non_nullable
                      as String,
            authorName: freezed == authorName
                ? _value.authorName
                : authorName // ignore: cast_nullable_to_non_nullable
                      as String?,
            actor: null == actor
                ? _value.actor
                : actor // ignore: cast_nullable_to_non_nullable
                      as RequestEventActor,
            kind: null == kind
                ? _value.kind
                : kind // ignore: cast_nullable_to_non_nullable
                      as RequestEventKind,
            text: freezed == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String?,
            attachments: null == attachments
                ? _value.attachments
                : attachments // ignore: cast_nullable_to_non_nullable
                      as List<TaskAttachment>,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RequestEventImplCopyWith<$Res>
    implements $RequestEventCopyWith<$Res> {
  factory _$$RequestEventImplCopyWith(
    _$RequestEventImpl value,
    $Res Function(_$RequestEventImpl) then,
  ) = __$$RequestEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String authorId,
    String? authorName,
    RequestEventActor actor,
    RequestEventKind kind,
    String? text,
    List<TaskAttachment> attachments,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$RequestEventImplCopyWithImpl<$Res>
    extends _$RequestEventCopyWithImpl<$Res, _$RequestEventImpl>
    implements _$$RequestEventImplCopyWith<$Res> {
  __$$RequestEventImplCopyWithImpl(
    _$RequestEventImpl _value,
    $Res Function(_$RequestEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RequestEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? authorId = null,
    Object? authorName = freezed,
    Object? actor = null,
    Object? kind = null,
    Object? text = freezed,
    Object? attachments = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$RequestEventImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        authorId: null == authorId
            ? _value.authorId
            : authorId // ignore: cast_nullable_to_non_nullable
                  as String,
        authorName: freezed == authorName
            ? _value.authorName
            : authorName // ignore: cast_nullable_to_non_nullable
                  as String?,
        actor: null == actor
            ? _value.actor
            : actor // ignore: cast_nullable_to_non_nullable
                  as RequestEventActor,
        kind: null == kind
            ? _value.kind
            : kind // ignore: cast_nullable_to_non_nullable
                  as RequestEventKind,
        text: freezed == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String?,
        attachments: null == attachments
            ? _value._attachments
            : attachments // ignore: cast_nullable_to_non_nullable
                  as List<TaskAttachment>,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$RequestEventImpl extends _RequestEvent {
  const _$RequestEventImpl({
    required this.id,
    this.authorId = '',
    this.authorName,
    this.actor = RequestEventActor.system,
    this.kind = RequestEventKind.comment,
    this.text,
    final List<TaskAttachment> attachments = const <TaskAttachment>[],
    required this.createdAt,
  }) : _attachments = attachments,
       super._();

  @override
  final String id;

  /// Author uid, or '' for a system event.
  @override
  @JsonKey()
  final String authorId;

  /// Denormalized author name ("System" for lifecycle events).
  @override
  final String? authorName;
  @override
  @JsonKey()
  final RequestEventActor actor;
  @override
  @JsonKey()
  final RequestEventKind kind;
  @override
  final String? text;
  final List<TaskAttachment> _attachments;
  @override
  @JsonKey()
  List<TaskAttachment> get attachments {
    if (_attachments is EqualUnmodifiableListView) return _attachments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attachments);
  }

  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'RequestEvent(id: $id, authorId: $authorId, authorName: $authorName, actor: $actor, kind: $kind, text: $text, attachments: $attachments, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RequestEventImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.authorId, authorId) ||
                other.authorId == authorId) &&
            (identical(other.authorName, authorName) ||
                other.authorName == authorName) &&
            (identical(other.actor, actor) || other.actor == actor) &&
            (identical(other.kind, kind) || other.kind == kind) &&
            (identical(other.text, text) || other.text == text) &&
            const DeepCollectionEquality().equals(
              other._attachments,
              _attachments,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    authorId,
    authorName,
    actor,
    kind,
    text,
    const DeepCollectionEquality().hash(_attachments),
    createdAt,
  );

  /// Create a copy of RequestEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RequestEventImplCopyWith<_$RequestEventImpl> get copyWith =>
      __$$RequestEventImplCopyWithImpl<_$RequestEventImpl>(this, _$identity);
}

abstract class _RequestEvent extends RequestEvent {
  const factory _RequestEvent({
    required final String id,
    final String authorId,
    final String? authorName,
    final RequestEventActor actor,
    final RequestEventKind kind,
    final String? text,
    final List<TaskAttachment> attachments,
    required final DateTime createdAt,
  }) = _$RequestEventImpl;
  const _RequestEvent._() : super._();

  @override
  String get id;

  /// Author uid, or '' for a system event.
  @override
  String get authorId;

  /// Denormalized author name ("System" for lifecycle events).
  @override
  String? get authorName;
  @override
  RequestEventActor get actor;
  @override
  RequestEventKind get kind;
  @override
  String? get text;
  @override
  List<TaskAttachment> get attachments;
  @override
  DateTime get createdAt;

  /// Create a copy of RequestEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RequestEventImplCopyWith<_$RequestEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
