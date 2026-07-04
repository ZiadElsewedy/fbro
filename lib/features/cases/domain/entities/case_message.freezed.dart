// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'case_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CaseMessage {
  String get id => throw _privateConstructorUsedError;

  /// Author uid, or '' when de-identified (a confidential reporter, or a
  /// system message).
  String get authorId => throw _privateConstructorUsedError;

  /// Denormalized author name ("Confidential Sender" / "System" when hidden).
  String? get authorName => throw _privateConstructorUsedError;
  CaseAuthorRole get authorRole => throw _privateConstructorUsedError;
  CaseMessageKind get kind => throw _privateConstructorUsedError;
  String? get text => throw _privateConstructorUsedError;
  List<TaskAttachment> get attachments => throw _privateConstructorUsedError;

  /// For a [CaseMessageKind.system] message — the [CaseStatus.value] it marks.
  String? get systemEvent => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of CaseMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CaseMessageCopyWith<CaseMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CaseMessageCopyWith<$Res> {
  factory $CaseMessageCopyWith(
    CaseMessage value,
    $Res Function(CaseMessage) then,
  ) = _$CaseMessageCopyWithImpl<$Res, CaseMessage>;
  @useResult
  $Res call({
    String id,
    String authorId,
    String? authorName,
    CaseAuthorRole authorRole,
    CaseMessageKind kind,
    String? text,
    List<TaskAttachment> attachments,
    String? systemEvent,
    DateTime createdAt,
  });
}

/// @nodoc
class _$CaseMessageCopyWithImpl<$Res, $Val extends CaseMessage>
    implements $CaseMessageCopyWith<$Res> {
  _$CaseMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CaseMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? authorId = null,
    Object? authorName = freezed,
    Object? authorRole = null,
    Object? kind = null,
    Object? text = freezed,
    Object? attachments = null,
    Object? systemEvent = freezed,
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
            authorRole: null == authorRole
                ? _value.authorRole
                : authorRole // ignore: cast_nullable_to_non_nullable
                      as CaseAuthorRole,
            kind: null == kind
                ? _value.kind
                : kind // ignore: cast_nullable_to_non_nullable
                      as CaseMessageKind,
            text: freezed == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String?,
            attachments: null == attachments
                ? _value.attachments
                : attachments // ignore: cast_nullable_to_non_nullable
                      as List<TaskAttachment>,
            systemEvent: freezed == systemEvent
                ? _value.systemEvent
                : systemEvent // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$CaseMessageImplCopyWith<$Res>
    implements $CaseMessageCopyWith<$Res> {
  factory _$$CaseMessageImplCopyWith(
    _$CaseMessageImpl value,
    $Res Function(_$CaseMessageImpl) then,
  ) = __$$CaseMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String authorId,
    String? authorName,
    CaseAuthorRole authorRole,
    CaseMessageKind kind,
    String? text,
    List<TaskAttachment> attachments,
    String? systemEvent,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$CaseMessageImplCopyWithImpl<$Res>
    extends _$CaseMessageCopyWithImpl<$Res, _$CaseMessageImpl>
    implements _$$CaseMessageImplCopyWith<$Res> {
  __$$CaseMessageImplCopyWithImpl(
    _$CaseMessageImpl _value,
    $Res Function(_$CaseMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CaseMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? authorId = null,
    Object? authorName = freezed,
    Object? authorRole = null,
    Object? kind = null,
    Object? text = freezed,
    Object? attachments = null,
    Object? systemEvent = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$CaseMessageImpl(
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
        authorRole: null == authorRole
            ? _value.authorRole
            : authorRole // ignore: cast_nullable_to_non_nullable
                  as CaseAuthorRole,
        kind: null == kind
            ? _value.kind
            : kind // ignore: cast_nullable_to_non_nullable
                  as CaseMessageKind,
        text: freezed == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String?,
        attachments: null == attachments
            ? _value._attachments
            : attachments // ignore: cast_nullable_to_non_nullable
                  as List<TaskAttachment>,
        systemEvent: freezed == systemEvent
            ? _value.systemEvent
            : systemEvent // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$CaseMessageImpl extends _CaseMessage {
  const _$CaseMessageImpl({
    required this.id,
    this.authorId = '',
    this.authorName,
    this.authorRole = CaseAuthorRole.reporter,
    this.kind = CaseMessageKind.message,
    this.text,
    final List<TaskAttachment> attachments = const <TaskAttachment>[],
    this.systemEvent,
    required this.createdAt,
  }) : _attachments = attachments,
       super._();

  @override
  final String id;

  /// Author uid, or '' when de-identified (a confidential reporter, or a
  /// system message).
  @override
  @JsonKey()
  final String authorId;

  /// Denormalized author name ("Confidential Sender" / "System" when hidden).
  @override
  final String? authorName;
  @override
  @JsonKey()
  final CaseAuthorRole authorRole;
  @override
  @JsonKey()
  final CaseMessageKind kind;
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

  /// For a [CaseMessageKind.system] message — the [CaseStatus.value] it marks.
  @override
  final String? systemEvent;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'CaseMessage(id: $id, authorId: $authorId, authorName: $authorName, authorRole: $authorRole, kind: $kind, text: $text, attachments: $attachments, systemEvent: $systemEvent, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CaseMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.authorId, authorId) ||
                other.authorId == authorId) &&
            (identical(other.authorName, authorName) ||
                other.authorName == authorName) &&
            (identical(other.authorRole, authorRole) ||
                other.authorRole == authorRole) &&
            (identical(other.kind, kind) || other.kind == kind) &&
            (identical(other.text, text) || other.text == text) &&
            const DeepCollectionEquality().equals(
              other._attachments,
              _attachments,
            ) &&
            (identical(other.systemEvent, systemEvent) ||
                other.systemEvent == systemEvent) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    authorId,
    authorName,
    authorRole,
    kind,
    text,
    const DeepCollectionEquality().hash(_attachments),
    systemEvent,
    createdAt,
  );

  /// Create a copy of CaseMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CaseMessageImplCopyWith<_$CaseMessageImpl> get copyWith =>
      __$$CaseMessageImplCopyWithImpl<_$CaseMessageImpl>(this, _$identity);
}

abstract class _CaseMessage extends CaseMessage {
  const factory _CaseMessage({
    required final String id,
    final String authorId,
    final String? authorName,
    final CaseAuthorRole authorRole,
    final CaseMessageKind kind,
    final String? text,
    final List<TaskAttachment> attachments,
    final String? systemEvent,
    required final DateTime createdAt,
  }) = _$CaseMessageImpl;
  const _CaseMessage._() : super._();

  @override
  String get id;

  /// Author uid, or '' when de-identified (a confidential reporter, or a
  /// system message).
  @override
  String get authorId;

  /// Denormalized author name ("Confidential Sender" / "System" when hidden).
  @override
  String? get authorName;
  @override
  CaseAuthorRole get authorRole;
  @override
  CaseMessageKind get kind;
  @override
  String? get text;
  @override
  List<TaskAttachment> get attachments;

  /// For a [CaseMessageKind.system] message — the [CaseStatus.value] it marks.
  @override
  String? get systemEvent;
  @override
  DateTime get createdAt;

  /// Create a copy of CaseMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CaseMessageImplCopyWith<_$CaseMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
