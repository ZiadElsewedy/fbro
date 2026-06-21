// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_attachment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TaskAttachment {
  /// Unique attachment id (also the Storage filename stem).
  String get id => throw _privateConstructorUsedError;

  /// Storage download URL.
  String get url => throw _privateConstructorUsedError;
  AttachmentType get type => throw _privateConstructorUsedError;
  DateTime get uploadedAt => throw _privateConstructorUsedError;

  /// uid of the uploader.
  String get uploadedBy => throw _privateConstructorUsedError;

  /// Denormalised uploader display name (best-effort).
  String? get uploadedByName => throw _privateConstructorUsedError;

  /// Create a copy of TaskAttachment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaskAttachmentCopyWith<TaskAttachment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskAttachmentCopyWith<$Res> {
  factory $TaskAttachmentCopyWith(
    TaskAttachment value,
    $Res Function(TaskAttachment) then,
  ) = _$TaskAttachmentCopyWithImpl<$Res, TaskAttachment>;
  @useResult
  $Res call({
    String id,
    String url,
    AttachmentType type,
    DateTime uploadedAt,
    String uploadedBy,
    String? uploadedByName,
  });
}

/// @nodoc
class _$TaskAttachmentCopyWithImpl<$Res, $Val extends TaskAttachment>
    implements $TaskAttachmentCopyWith<$Res> {
  _$TaskAttachmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaskAttachment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? type = null,
    Object? uploadedAt = null,
    Object? uploadedBy = null,
    Object? uploadedByName = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            url: null == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as AttachmentType,
            uploadedAt: null == uploadedAt
                ? _value.uploadedAt
                : uploadedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            uploadedBy: null == uploadedBy
                ? _value.uploadedBy
                : uploadedBy // ignore: cast_nullable_to_non_nullable
                      as String,
            uploadedByName: freezed == uploadedByName
                ? _value.uploadedByName
                : uploadedByName // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TaskAttachmentImplCopyWith<$Res>
    implements $TaskAttachmentCopyWith<$Res> {
  factory _$$TaskAttachmentImplCopyWith(
    _$TaskAttachmentImpl value,
    $Res Function(_$TaskAttachmentImpl) then,
  ) = __$$TaskAttachmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String url,
    AttachmentType type,
    DateTime uploadedAt,
    String uploadedBy,
    String? uploadedByName,
  });
}

/// @nodoc
class __$$TaskAttachmentImplCopyWithImpl<$Res>
    extends _$TaskAttachmentCopyWithImpl<$Res, _$TaskAttachmentImpl>
    implements _$$TaskAttachmentImplCopyWith<$Res> {
  __$$TaskAttachmentImplCopyWithImpl(
    _$TaskAttachmentImpl _value,
    $Res Function(_$TaskAttachmentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TaskAttachment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? type = null,
    Object? uploadedAt = null,
    Object? uploadedBy = null,
    Object? uploadedByName = freezed,
  }) {
    return _then(
      _$TaskAttachmentImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        url: null == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as AttachmentType,
        uploadedAt: null == uploadedAt
            ? _value.uploadedAt
            : uploadedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        uploadedBy: null == uploadedBy
            ? _value.uploadedBy
            : uploadedBy // ignore: cast_nullable_to_non_nullable
                  as String,
        uploadedByName: freezed == uploadedByName
            ? _value.uploadedByName
            : uploadedByName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$TaskAttachmentImpl implements _TaskAttachment {
  const _$TaskAttachmentImpl({
    required this.id,
    required this.url,
    required this.type,
    required this.uploadedAt,
    required this.uploadedBy,
    this.uploadedByName,
  });

  /// Unique attachment id (also the Storage filename stem).
  @override
  final String id;

  /// Storage download URL.
  @override
  final String url;
  @override
  final AttachmentType type;
  @override
  final DateTime uploadedAt;

  /// uid of the uploader.
  @override
  final String uploadedBy;

  /// Denormalised uploader display name (best-effort).
  @override
  final String? uploadedByName;

  @override
  String toString() {
    return 'TaskAttachment(id: $id, url: $url, type: $type, uploadedAt: $uploadedAt, uploadedBy: $uploadedBy, uploadedByName: $uploadedByName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskAttachmentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.uploadedAt, uploadedAt) ||
                other.uploadedAt == uploadedAt) &&
            (identical(other.uploadedBy, uploadedBy) ||
                other.uploadedBy == uploadedBy) &&
            (identical(other.uploadedByName, uploadedByName) ||
                other.uploadedByName == uploadedByName));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    url,
    type,
    uploadedAt,
    uploadedBy,
    uploadedByName,
  );

  /// Create a copy of TaskAttachment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskAttachmentImplCopyWith<_$TaskAttachmentImpl> get copyWith =>
      __$$TaskAttachmentImplCopyWithImpl<_$TaskAttachmentImpl>(
        this,
        _$identity,
      );
}

abstract class _TaskAttachment implements TaskAttachment {
  const factory _TaskAttachment({
    required final String id,
    required final String url,
    required final AttachmentType type,
    required final DateTime uploadedAt,
    required final String uploadedBy,
    final String? uploadedByName,
  }) = _$TaskAttachmentImpl;

  /// Unique attachment id (also the Storage filename stem).
  @override
  String get id;

  /// Storage download URL.
  @override
  String get url;
  @override
  AttachmentType get type;
  @override
  DateTime get uploadedAt;

  /// uid of the uploader.
  @override
  String get uploadedBy;

  /// Denormalised uploader display name (best-effort).
  @override
  String? get uploadedByName;

  /// Create a copy of TaskAttachment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaskAttachmentImplCopyWith<_$TaskAttachmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
