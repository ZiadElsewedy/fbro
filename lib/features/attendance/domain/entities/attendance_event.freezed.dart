// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AttendanceEvent {
  String get id => throw _privateConstructorUsedError;
  AttendanceEventKind get kind => throw _privateConstructorUsedError;

  /// Who performed it (the employee, a manager, or '' for a system action).
  String get actorId => throw _privateConstructorUsedError;
  String? get actorName => throw _privateConstructorUsedError;

  /// Free text — a correction reason or a review comment.
  String? get note => throw _privateConstructorUsedError;

  /// Structured payload for edits/corrections (e.g. the proposed
  /// `clockIn`/`clockOut`, or before/after values). Kept as a small map so the
  /// shape stays flexible without new fields.
  Map<String, dynamic> get data => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of AttendanceEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AttendanceEventCopyWith<AttendanceEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AttendanceEventCopyWith<$Res> {
  factory $AttendanceEventCopyWith(
    AttendanceEvent value,
    $Res Function(AttendanceEvent) then,
  ) = _$AttendanceEventCopyWithImpl<$Res, AttendanceEvent>;
  @useResult
  $Res call({
    String id,
    AttendanceEventKind kind,
    String actorId,
    String? actorName,
    String? note,
    Map<String, dynamic> data,
    DateTime createdAt,
  });
}

/// @nodoc
class _$AttendanceEventCopyWithImpl<$Res, $Val extends AttendanceEvent>
    implements $AttendanceEventCopyWith<$Res> {
  _$AttendanceEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AttendanceEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? kind = null,
    Object? actorId = null,
    Object? actorName = freezed,
    Object? note = freezed,
    Object? data = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            kind: null == kind
                ? _value.kind
                : kind // ignore: cast_nullable_to_non_nullable
                      as AttendanceEventKind,
            actorId: null == actorId
                ? _value.actorId
                : actorId // ignore: cast_nullable_to_non_nullable
                      as String,
            actorName: freezed == actorName
                ? _value.actorName
                : actorName // ignore: cast_nullable_to_non_nullable
                      as String?,
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String?,
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
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
abstract class _$$AttendanceEventImplCopyWith<$Res>
    implements $AttendanceEventCopyWith<$Res> {
  factory _$$AttendanceEventImplCopyWith(
    _$AttendanceEventImpl value,
    $Res Function(_$AttendanceEventImpl) then,
  ) = __$$AttendanceEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    AttendanceEventKind kind,
    String actorId,
    String? actorName,
    String? note,
    Map<String, dynamic> data,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$AttendanceEventImplCopyWithImpl<$Res>
    extends _$AttendanceEventCopyWithImpl<$Res, _$AttendanceEventImpl>
    implements _$$AttendanceEventImplCopyWith<$Res> {
  __$$AttendanceEventImplCopyWithImpl(
    _$AttendanceEventImpl _value,
    $Res Function(_$AttendanceEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AttendanceEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? kind = null,
    Object? actorId = null,
    Object? actorName = freezed,
    Object? note = freezed,
    Object? data = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$AttendanceEventImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        kind: null == kind
            ? _value.kind
            : kind // ignore: cast_nullable_to_non_nullable
                  as AttendanceEventKind,
        actorId: null == actorId
            ? _value.actorId
            : actorId // ignore: cast_nullable_to_non_nullable
                  as String,
        actorName: freezed == actorName
            ? _value.actorName
            : actorName // ignore: cast_nullable_to_non_nullable
                  as String?,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String?,
        data: null == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$AttendanceEventImpl extends _AttendanceEvent {
  const _$AttendanceEventImpl({
    required this.id,
    required this.kind,
    this.actorId = '',
    this.actorName,
    this.note,
    final Map<String, dynamic> data = const <String, dynamic>{},
    required this.createdAt,
  }) : _data = data,
       super._();

  @override
  final String id;
  @override
  final AttendanceEventKind kind;

  /// Who performed it (the employee, a manager, or '' for a system action).
  @override
  @JsonKey()
  final String actorId;
  @override
  final String? actorName;

  /// Free text — a correction reason or a review comment.
  @override
  final String? note;

  /// Structured payload for edits/corrections (e.g. the proposed
  /// `clockIn`/`clockOut`, or before/after values). Kept as a small map so the
  /// shape stays flexible without new fields.
  final Map<String, dynamic> _data;

  /// Structured payload for edits/corrections (e.g. the proposed
  /// `clockIn`/`clockOut`, or before/after values). Kept as a small map so the
  /// shape stays flexible without new fields.
  @override
  @JsonKey()
  Map<String, dynamic> get data {
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_data);
  }

  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'AttendanceEvent(id: $id, kind: $kind, actorId: $actorId, actorName: $actorName, note: $note, data: $data, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AttendanceEventImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.kind, kind) || other.kind == kind) &&
            (identical(other.actorId, actorId) || other.actorId == actorId) &&
            (identical(other.actorName, actorName) ||
                other.actorName == actorName) &&
            (identical(other.note, note) || other.note == note) &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    kind,
    actorId,
    actorName,
    note,
    const DeepCollectionEquality().hash(_data),
    createdAt,
  );

  /// Create a copy of AttendanceEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AttendanceEventImplCopyWith<_$AttendanceEventImpl> get copyWith =>
      __$$AttendanceEventImplCopyWithImpl<_$AttendanceEventImpl>(
        this,
        _$identity,
      );
}

abstract class _AttendanceEvent extends AttendanceEvent {
  const factory _AttendanceEvent({
    required final String id,
    required final AttendanceEventKind kind,
    final String actorId,
    final String? actorName,
    final String? note,
    final Map<String, dynamic> data,
    required final DateTime createdAt,
  }) = _$AttendanceEventImpl;
  const _AttendanceEvent._() : super._();

  @override
  String get id;
  @override
  AttendanceEventKind get kind;

  /// Who performed it (the employee, a manager, or '' for a system action).
  @override
  String get actorId;
  @override
  String? get actorName;

  /// Free text — a correction reason or a review comment.
  @override
  String? get note;

  /// Structured payload for edits/corrections (e.g. the proposed
  /// `clockIn`/`clockOut`, or before/after values). Kept as a small map so the
  /// shape stays flexible without new fields.
  @override
  Map<String, dynamic> get data;
  @override
  DateTime get createdAt;

  /// Create a copy of AttendanceEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AttendanceEventImplCopyWith<_$AttendanceEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
