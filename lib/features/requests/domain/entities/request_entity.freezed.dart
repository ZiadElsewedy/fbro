// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'request_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$RequestEntity {
  String get id => throw _privateConstructorUsedError;

  /// Human-friendly reference ("REQ-000123"), server-assigned by
  /// `onRequestCreated` from the `counters/requests` sequence. Null until the
  /// function runs — [refLabel] falls back to a deterministic short code.
  String? get refCode => throw _privateConstructorUsedError;
  int? get seq => throw _privateConstructorUsedError;

  /// Owning branch (the requester's branch). Scopes every read/query.
  String? get branchId => throw _privateConstructorUsedError;
  RequestType get type => throw _privateConstructorUsedError;
  RequestStatus get status => throw _privateConstructorUsedError;
  String get requesterId => throw _privateConstructorUsedError;
  String? get requesterName => throw _privateConstructorUsedError;
  UserRole get requesterRole => throw _privateConstructorUsedError;

  /// The captured values — currently just `{'message': <reason>}`.
  Map<String, dynamic> get details => throw _privateConstructorUsedError;

  /// Opening media the requester attached (consumed by `onRequestCreated` into
  /// the opening event; Storage `requests/{id}/attachments/{attId}.<ext>`).
  List<TaskAttachment> get attachments => throw _privateConstructorUsedError;

  /// Denormalized last-event preview for the inbox row (bumped server-side).
  String? get lastEventPreview => throw _privateConstructorUsedError;
  DateTime? get lastEventAt => throw _privateConstructorUsedError;
  int get eventCount => throw _privateConstructorUsedError;

  /// Who decided (approved / rejected) + when — drives the header + metrics.
  String? get decidedBy => throw _privateConstructorUsedError;
  String? get decidedByName => throw _privateConstructorUsedError;
  DateTime? get decidedAt => throw _privateConstructorUsedError;

  /// Soft delete (admin-only): the doc stays as a record, the inbox filters
  /// it out. Never a hard Firestore delete.
  DateTime? get deletedAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Create a copy of RequestEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RequestEntityCopyWith<RequestEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RequestEntityCopyWith<$Res> {
  factory $RequestEntityCopyWith(
    RequestEntity value,
    $Res Function(RequestEntity) then,
  ) = _$RequestEntityCopyWithImpl<$Res, RequestEntity>;
  @useResult
  $Res call({
    String id,
    String? refCode,
    int? seq,
    String? branchId,
    RequestType type,
    RequestStatus status,
    String requesterId,
    String? requesterName,
    UserRole requesterRole,
    Map<String, dynamic> details,
    List<TaskAttachment> attachments,
    String? lastEventPreview,
    DateTime? lastEventAt,
    int eventCount,
    String? decidedBy,
    String? decidedByName,
    DateTime? decidedAt,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$RequestEntityCopyWithImpl<$Res, $Val extends RequestEntity>
    implements $RequestEntityCopyWith<$Res> {
  _$RequestEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RequestEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? refCode = freezed,
    Object? seq = freezed,
    Object? branchId = freezed,
    Object? type = null,
    Object? status = null,
    Object? requesterId = null,
    Object? requesterName = freezed,
    Object? requesterRole = null,
    Object? details = null,
    Object? attachments = null,
    Object? lastEventPreview = freezed,
    Object? lastEventAt = freezed,
    Object? eventCount = null,
    Object? decidedBy = freezed,
    Object? decidedByName = freezed,
    Object? decidedAt = freezed,
    Object? deletedAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            refCode: freezed == refCode
                ? _value.refCode
                : refCode // ignore: cast_nullable_to_non_nullable
                      as String?,
            seq: freezed == seq
                ? _value.seq
                : seq // ignore: cast_nullable_to_non_nullable
                      as int?,
            branchId: freezed == branchId
                ? _value.branchId
                : branchId // ignore: cast_nullable_to_non_nullable
                      as String?,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as RequestType,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as RequestStatus,
            requesterId: null == requesterId
                ? _value.requesterId
                : requesterId // ignore: cast_nullable_to_non_nullable
                      as String,
            requesterName: freezed == requesterName
                ? _value.requesterName
                : requesterName // ignore: cast_nullable_to_non_nullable
                      as String?,
            requesterRole: null == requesterRole
                ? _value.requesterRole
                : requesterRole // ignore: cast_nullable_to_non_nullable
                      as UserRole,
            details: null == details
                ? _value.details
                : details // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            attachments: null == attachments
                ? _value.attachments
                : attachments // ignore: cast_nullable_to_non_nullable
                      as List<TaskAttachment>,
            lastEventPreview: freezed == lastEventPreview
                ? _value.lastEventPreview
                : lastEventPreview // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastEventAt: freezed == lastEventAt
                ? _value.lastEventAt
                : lastEventAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            eventCount: null == eventCount
                ? _value.eventCount
                : eventCount // ignore: cast_nullable_to_non_nullable
                      as int,
            decidedBy: freezed == decidedBy
                ? _value.decidedBy
                : decidedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            decidedByName: freezed == decidedByName
                ? _value.decidedByName
                : decidedByName // ignore: cast_nullable_to_non_nullable
                      as String?,
            decidedAt: freezed == decidedAt
                ? _value.decidedAt
                : decidedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            deletedAt: freezed == deletedAt
                ? _value.deletedAt
                : deletedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
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
abstract class _$$RequestEntityImplCopyWith<$Res>
    implements $RequestEntityCopyWith<$Res> {
  factory _$$RequestEntityImplCopyWith(
    _$RequestEntityImpl value,
    $Res Function(_$RequestEntityImpl) then,
  ) = __$$RequestEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? refCode,
    int? seq,
    String? branchId,
    RequestType type,
    RequestStatus status,
    String requesterId,
    String? requesterName,
    UserRole requesterRole,
    Map<String, dynamic> details,
    List<TaskAttachment> attachments,
    String? lastEventPreview,
    DateTime? lastEventAt,
    int eventCount,
    String? decidedBy,
    String? decidedByName,
    DateTime? decidedAt,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$RequestEntityImplCopyWithImpl<$Res>
    extends _$RequestEntityCopyWithImpl<$Res, _$RequestEntityImpl>
    implements _$$RequestEntityImplCopyWith<$Res> {
  __$$RequestEntityImplCopyWithImpl(
    _$RequestEntityImpl _value,
    $Res Function(_$RequestEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RequestEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? refCode = freezed,
    Object? seq = freezed,
    Object? branchId = freezed,
    Object? type = null,
    Object? status = null,
    Object? requesterId = null,
    Object? requesterName = freezed,
    Object? requesterRole = null,
    Object? details = null,
    Object? attachments = null,
    Object? lastEventPreview = freezed,
    Object? lastEventAt = freezed,
    Object? eventCount = null,
    Object? decidedBy = freezed,
    Object? decidedByName = freezed,
    Object? decidedAt = freezed,
    Object? deletedAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$RequestEntityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        refCode: freezed == refCode
            ? _value.refCode
            : refCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        seq: freezed == seq
            ? _value.seq
            : seq // ignore: cast_nullable_to_non_nullable
                  as int?,
        branchId: freezed == branchId
            ? _value.branchId
            : branchId // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as RequestType,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as RequestStatus,
        requesterId: null == requesterId
            ? _value.requesterId
            : requesterId // ignore: cast_nullable_to_non_nullable
                  as String,
        requesterName: freezed == requesterName
            ? _value.requesterName
            : requesterName // ignore: cast_nullable_to_non_nullable
                  as String?,
        requesterRole: null == requesterRole
            ? _value.requesterRole
            : requesterRole // ignore: cast_nullable_to_non_nullable
                  as UserRole,
        details: null == details
            ? _value._details
            : details // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        attachments: null == attachments
            ? _value._attachments
            : attachments // ignore: cast_nullable_to_non_nullable
                  as List<TaskAttachment>,
        lastEventPreview: freezed == lastEventPreview
            ? _value.lastEventPreview
            : lastEventPreview // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastEventAt: freezed == lastEventAt
            ? _value.lastEventAt
            : lastEventAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        eventCount: null == eventCount
            ? _value.eventCount
            : eventCount // ignore: cast_nullable_to_non_nullable
                  as int,
        decidedBy: freezed == decidedBy
            ? _value.decidedBy
            : decidedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        decidedByName: freezed == decidedByName
            ? _value.decidedByName
            : decidedByName // ignore: cast_nullable_to_non_nullable
                  as String?,
        decidedAt: freezed == decidedAt
            ? _value.decidedAt
            : decidedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        deletedAt: freezed == deletedAt
            ? _value.deletedAt
            : deletedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
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

class _$RequestEntityImpl extends _RequestEntity {
  const _$RequestEntityImpl({
    required this.id,
    this.refCode,
    this.seq,
    this.branchId,
    required this.type,
    this.status = RequestStatus.pending,
    required this.requesterId,
    this.requesterName,
    this.requesterRole = UserRole.employee,
    final Map<String, dynamic> details = const <String, dynamic>{},
    final List<TaskAttachment> attachments = const <TaskAttachment>[],
    this.lastEventPreview,
    this.lastEventAt,
    this.eventCount = 0,
    this.decidedBy,
    this.decidedByName,
    this.decidedAt,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
  }) : _details = details,
       _attachments = attachments,
       super._();

  @override
  final String id;

  /// Human-friendly reference ("REQ-000123"), server-assigned by
  /// `onRequestCreated` from the `counters/requests` sequence. Null until the
  /// function runs — [refLabel] falls back to a deterministic short code.
  @override
  final String? refCode;
  @override
  final int? seq;

  /// Owning branch (the requester's branch). Scopes every read/query.
  @override
  final String? branchId;
  @override
  final RequestType type;
  @override
  @JsonKey()
  final RequestStatus status;
  @override
  final String requesterId;
  @override
  final String? requesterName;
  @override
  @JsonKey()
  final UserRole requesterRole;

  /// The captured values — currently just `{'message': <reason>}`.
  final Map<String, dynamic> _details;

  /// The captured values — currently just `{'message': <reason>}`.
  @override
  @JsonKey()
  Map<String, dynamic> get details {
    if (_details is EqualUnmodifiableMapView) return _details;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_details);
  }

  /// Opening media the requester attached (consumed by `onRequestCreated` into
  /// the opening event; Storage `requests/{id}/attachments/{attId}.<ext>`).
  final List<TaskAttachment> _attachments;

  /// Opening media the requester attached (consumed by `onRequestCreated` into
  /// the opening event; Storage `requests/{id}/attachments/{attId}.<ext>`).
  @override
  @JsonKey()
  List<TaskAttachment> get attachments {
    if (_attachments is EqualUnmodifiableListView) return _attachments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attachments);
  }

  /// Denormalized last-event preview for the inbox row (bumped server-side).
  @override
  final String? lastEventPreview;
  @override
  final DateTime? lastEventAt;
  @override
  @JsonKey()
  final int eventCount;

  /// Who decided (approved / rejected) + when — drives the header + metrics.
  @override
  final String? decidedBy;
  @override
  final String? decidedByName;
  @override
  final DateTime? decidedAt;

  /// Soft delete (admin-only): the doc stays as a record, the inbox filters
  /// it out. Never a hard Firestore delete.
  @override
  final DateTime? deletedAt;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'RequestEntity(id: $id, refCode: $refCode, seq: $seq, branchId: $branchId, type: $type, status: $status, requesterId: $requesterId, requesterName: $requesterName, requesterRole: $requesterRole, details: $details, attachments: $attachments, lastEventPreview: $lastEventPreview, lastEventAt: $lastEventAt, eventCount: $eventCount, decidedBy: $decidedBy, decidedByName: $decidedByName, decidedAt: $decidedAt, deletedAt: $deletedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RequestEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.refCode, refCode) || other.refCode == refCode) &&
            (identical(other.seq, seq) || other.seq == seq) &&
            (identical(other.branchId, branchId) ||
                other.branchId == branchId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.requesterId, requesterId) ||
                other.requesterId == requesterId) &&
            (identical(other.requesterName, requesterName) ||
                other.requesterName == requesterName) &&
            (identical(other.requesterRole, requesterRole) ||
                other.requesterRole == requesterRole) &&
            const DeepCollectionEquality().equals(other._details, _details) &&
            const DeepCollectionEquality().equals(
              other._attachments,
              _attachments,
            ) &&
            (identical(other.lastEventPreview, lastEventPreview) ||
                other.lastEventPreview == lastEventPreview) &&
            (identical(other.lastEventAt, lastEventAt) ||
                other.lastEventAt == lastEventAt) &&
            (identical(other.eventCount, eventCount) ||
                other.eventCount == eventCount) &&
            (identical(other.decidedBy, decidedBy) ||
                other.decidedBy == decidedBy) &&
            (identical(other.decidedByName, decidedByName) ||
                other.decidedByName == decidedByName) &&
            (identical(other.decidedAt, decidedAt) ||
                other.decidedAt == decidedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    refCode,
    seq,
    branchId,
    type,
    status,
    requesterId,
    requesterName,
    requesterRole,
    const DeepCollectionEquality().hash(_details),
    const DeepCollectionEquality().hash(_attachments),
    lastEventPreview,
    lastEventAt,
    eventCount,
    decidedBy,
    decidedByName,
    decidedAt,
    deletedAt,
    createdAt,
    updatedAt,
  ]);

  /// Create a copy of RequestEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RequestEntityImplCopyWith<_$RequestEntityImpl> get copyWith =>
      __$$RequestEntityImplCopyWithImpl<_$RequestEntityImpl>(this, _$identity);
}

abstract class _RequestEntity extends RequestEntity {
  const factory _RequestEntity({
    required final String id,
    final String? refCode,
    final int? seq,
    final String? branchId,
    required final RequestType type,
    final RequestStatus status,
    required final String requesterId,
    final String? requesterName,
    final UserRole requesterRole,
    final Map<String, dynamic> details,
    final List<TaskAttachment> attachments,
    final String? lastEventPreview,
    final DateTime? lastEventAt,
    final int eventCount,
    final String? decidedBy,
    final String? decidedByName,
    final DateTime? decidedAt,
    final DateTime? deletedAt,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$RequestEntityImpl;
  const _RequestEntity._() : super._();

  @override
  String get id;

  /// Human-friendly reference ("REQ-000123"), server-assigned by
  /// `onRequestCreated` from the `counters/requests` sequence. Null until the
  /// function runs — [refLabel] falls back to a deterministic short code.
  @override
  String? get refCode;
  @override
  int? get seq;

  /// Owning branch (the requester's branch). Scopes every read/query.
  @override
  String? get branchId;
  @override
  RequestType get type;
  @override
  RequestStatus get status;
  @override
  String get requesterId;
  @override
  String? get requesterName;
  @override
  UserRole get requesterRole;

  /// The captured values — currently just `{'message': <reason>}`.
  @override
  Map<String, dynamic> get details;

  /// Opening media the requester attached (consumed by `onRequestCreated` into
  /// the opening event; Storage `requests/{id}/attachments/{attId}.<ext>`).
  @override
  List<TaskAttachment> get attachments;

  /// Denormalized last-event preview for the inbox row (bumped server-side).
  @override
  String? get lastEventPreview;
  @override
  DateTime? get lastEventAt;
  @override
  int get eventCount;

  /// Who decided (approved / rejected) + when — drives the header + metrics.
  @override
  String? get decidedBy;
  @override
  String? get decidedByName;
  @override
  DateTime? get decidedAt;

  /// Soft delete (admin-only): the doc stays as a record, the inbox filters
  /// it out. Never a hard Firestore delete.
  @override
  DateTime? get deletedAt;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of RequestEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RequestEntityImplCopyWith<_$RequestEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
