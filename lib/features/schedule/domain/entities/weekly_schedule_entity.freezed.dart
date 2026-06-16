// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weekly_schedule_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$WeeklyScheduleEntity {
  String get id => throw _privateConstructorUsedError;
  String get branchId => throw _privateConstructorUsedError;

  /// The Sunday (00:00) that starts this week.
  DateTime get weekStart => throw _privateConstructorUsedError;

  /// Roster: `day → shift → list of employee uids`.
  Map<ScheduleDay, Map<ScheduleShift, List<String>>> get assignments =>
      throw _privateConstructorUsedError;

  /// uid of the manager/admin who created the schedule.
  String? get createdBy => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Create a copy of WeeklyScheduleEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeeklyScheduleEntityCopyWith<WeeklyScheduleEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeeklyScheduleEntityCopyWith<$Res> {
  factory $WeeklyScheduleEntityCopyWith(
    WeeklyScheduleEntity value,
    $Res Function(WeeklyScheduleEntity) then,
  ) = _$WeeklyScheduleEntityCopyWithImpl<$Res, WeeklyScheduleEntity>;
  @useResult
  $Res call({
    String id,
    String branchId,
    DateTime weekStart,
    Map<ScheduleDay, Map<ScheduleShift, List<String>>> assignments,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$WeeklyScheduleEntityCopyWithImpl<
  $Res,
  $Val extends WeeklyScheduleEntity
>
    implements $WeeklyScheduleEntityCopyWith<$Res> {
  _$WeeklyScheduleEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeeklyScheduleEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? branchId = null,
    Object? weekStart = null,
    Object? assignments = null,
    Object? createdBy = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            branchId: null == branchId
                ? _value.branchId
                : branchId // ignore: cast_nullable_to_non_nullable
                      as String,
            weekStart: null == weekStart
                ? _value.weekStart
                : weekStart // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            assignments: null == assignments
                ? _value.assignments
                : assignments // ignore: cast_nullable_to_non_nullable
                      as Map<ScheduleDay, Map<ScheduleShift, List<String>>>,
            createdBy: freezed == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WeeklyScheduleEntityImplCopyWith<$Res>
    implements $WeeklyScheduleEntityCopyWith<$Res> {
  factory _$$WeeklyScheduleEntityImplCopyWith(
    _$WeeklyScheduleEntityImpl value,
    $Res Function(_$WeeklyScheduleEntityImpl) then,
  ) = __$$WeeklyScheduleEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String branchId,
    DateTime weekStart,
    Map<ScheduleDay, Map<ScheduleShift, List<String>>> assignments,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$WeeklyScheduleEntityImplCopyWithImpl<$Res>
    extends _$WeeklyScheduleEntityCopyWithImpl<$Res, _$WeeklyScheduleEntityImpl>
    implements _$$WeeklyScheduleEntityImplCopyWith<$Res> {
  __$$WeeklyScheduleEntityImplCopyWithImpl(
    _$WeeklyScheduleEntityImpl _value,
    $Res Function(_$WeeklyScheduleEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeeklyScheduleEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? branchId = null,
    Object? weekStart = null,
    Object? assignments = null,
    Object? createdBy = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$WeeklyScheduleEntityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        branchId: null == branchId
            ? _value.branchId
            : branchId // ignore: cast_nullable_to_non_nullable
                  as String,
        weekStart: null == weekStart
            ? _value.weekStart
            : weekStart // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        assignments: null == assignments
            ? _value._assignments
            : assignments // ignore: cast_nullable_to_non_nullable
                  as Map<ScheduleDay, Map<ScheduleShift, List<String>>>,
        createdBy: freezed == createdBy
            ? _value.createdBy
            : createdBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$WeeklyScheduleEntityImpl extends _WeeklyScheduleEntity {
  const _$WeeklyScheduleEntityImpl({
    required this.id,
    required this.branchId,
    required this.weekStart,
    final Map<ScheduleDay, Map<ScheduleShift, List<String>>> assignments =
        const <ScheduleDay, Map<ScheduleShift, List<String>>>{},
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  }) : _assignments = assignments,
       super._();

  @override
  final String id;
  @override
  final String branchId;

  /// The Sunday (00:00) that starts this week.
  @override
  final DateTime weekStart;

  /// Roster: `day → shift → list of employee uids`.
  final Map<ScheduleDay, Map<ScheduleShift, List<String>>> _assignments;

  /// Roster: `day → shift → list of employee uids`.
  @override
  @JsonKey()
  Map<ScheduleDay, Map<ScheduleShift, List<String>>> get assignments {
    if (_assignments is EqualUnmodifiableMapView) return _assignments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_assignments);
  }

  /// uid of the manager/admin who created the schedule.
  @override
  final String? createdBy;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'WeeklyScheduleEntity(id: $id, branchId: $branchId, weekStart: $weekStart, assignments: $assignments, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeeklyScheduleEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.branchId, branchId) ||
                other.branchId == branchId) &&
            (identical(other.weekStart, weekStart) ||
                other.weekStart == weekStart) &&
            const DeepCollectionEquality().equals(
              other._assignments,
              _assignments,
            ) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    branchId,
    weekStart,
    const DeepCollectionEquality().hash(_assignments),
    createdBy,
    createdAt,
    updatedAt,
  );

  /// Create a copy of WeeklyScheduleEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeeklyScheduleEntityImplCopyWith<_$WeeklyScheduleEntityImpl>
  get copyWith =>
      __$$WeeklyScheduleEntityImplCopyWithImpl<_$WeeklyScheduleEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _WeeklyScheduleEntity extends WeeklyScheduleEntity {
  const factory _WeeklyScheduleEntity({
    required final String id,
    required final String branchId,
    required final DateTime weekStart,
    final Map<ScheduleDay, Map<ScheduleShift, List<String>>> assignments,
    final String? createdBy,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$WeeklyScheduleEntityImpl;
  const _WeeklyScheduleEntity._() : super._();

  @override
  String get id;
  @override
  String get branchId;

  /// The Sunday (00:00) that starts this week.
  @override
  DateTime get weekStart;

  /// Roster: `day → shift → list of employee uids`.
  @override
  Map<ScheduleDay, Map<ScheduleShift, List<String>>> get assignments;

  /// uid of the manager/admin who created the schedule.
  @override
  String? get createdBy;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of WeeklyScheduleEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeeklyScheduleEntityImplCopyWith<_$WeeklyScheduleEntityImpl>
  get copyWith => throw _privateConstructorUsedError;
}
