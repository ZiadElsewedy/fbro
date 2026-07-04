// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ReportEntity {
  String get id => throw _privateConstructorUsedError;

  /// Owning branch (the reporter's branch). Scopes every read/query.
  String? get branchId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  ReportCategory get category => throw _privateConstructorUsedError;
  ReportRecipient get recipient => throw _privateConstructorUsedError;
  ReportPrivacy get privacy => throw _privateConstructorUsedError;
  ReportSeverity get severity => throw _privateConstructorUsedError;
  ReportStatus get status => throw _privateConstructorUsedError;

  /// Denormalized sender name — set ONLY when [privacy] is normal; null
  /// otherwise (UI then shows "Confidential Sender"). The raw uid is never
  /// here (see the private `reporter/identity` subdoc).
  String? get reporterDisplayName => throw _privateConstructorUsedError;

  /// Media attached to the report (reuses the task attachment pipeline;
  /// Storage `reports/{id}/attachments/{attId}.<ext>`).
  List<TaskAttachment> get attachments => throw _privateConstructorUsedError;

  /// The conversation thread (opening message context + replies + markers).
  List<ActivityEntry> get activityLog => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  DateTime? get resolvedAt => throw _privateConstructorUsedError;

  /// Create a copy of ReportEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReportEntityCopyWith<ReportEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReportEntityCopyWith<$Res> {
  factory $ReportEntityCopyWith(
    ReportEntity value,
    $Res Function(ReportEntity) then,
  ) = _$ReportEntityCopyWithImpl<$Res, ReportEntity>;
  @useResult
  $Res call({
    String id,
    String? branchId,
    String title,
    String? description,
    ReportCategory category,
    ReportRecipient recipient,
    ReportPrivacy privacy,
    ReportSeverity severity,
    ReportStatus status,
    String? reporterDisplayName,
    List<TaskAttachment> attachments,
    List<ActivityEntry> activityLog,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? resolvedAt,
  });
}

/// @nodoc
class _$ReportEntityCopyWithImpl<$Res, $Val extends ReportEntity>
    implements $ReportEntityCopyWith<$Res> {
  _$ReportEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReportEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? branchId = freezed,
    Object? title = null,
    Object? description = freezed,
    Object? category = null,
    Object? recipient = null,
    Object? privacy = null,
    Object? severity = null,
    Object? status = null,
    Object? reporterDisplayName = freezed,
    Object? attachments = null,
    Object? activityLog = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? resolvedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            branchId: freezed == branchId
                ? _value.branchId
                : branchId // ignore: cast_nullable_to_non_nullable
                      as String?,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as ReportCategory,
            recipient: null == recipient
                ? _value.recipient
                : recipient // ignore: cast_nullable_to_non_nullable
                      as ReportRecipient,
            privacy: null == privacy
                ? _value.privacy
                : privacy // ignore: cast_nullable_to_non_nullable
                      as ReportPrivacy,
            severity: null == severity
                ? _value.severity
                : severity // ignore: cast_nullable_to_non_nullable
                      as ReportSeverity,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ReportStatus,
            reporterDisplayName: freezed == reporterDisplayName
                ? _value.reporterDisplayName
                : reporterDisplayName // ignore: cast_nullable_to_non_nullable
                      as String?,
            attachments: null == attachments
                ? _value.attachments
                : attachments // ignore: cast_nullable_to_non_nullable
                      as List<TaskAttachment>,
            activityLog: null == activityLog
                ? _value.activityLog
                : activityLog // ignore: cast_nullable_to_non_nullable
                      as List<ActivityEntry>,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            resolvedAt: freezed == resolvedAt
                ? _value.resolvedAt
                : resolvedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReportEntityImplCopyWith<$Res>
    implements $ReportEntityCopyWith<$Res> {
  factory _$$ReportEntityImplCopyWith(
    _$ReportEntityImpl value,
    $Res Function(_$ReportEntityImpl) then,
  ) = __$$ReportEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? branchId,
    String title,
    String? description,
    ReportCategory category,
    ReportRecipient recipient,
    ReportPrivacy privacy,
    ReportSeverity severity,
    ReportStatus status,
    String? reporterDisplayName,
    List<TaskAttachment> attachments,
    List<ActivityEntry> activityLog,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? resolvedAt,
  });
}

/// @nodoc
class __$$ReportEntityImplCopyWithImpl<$Res>
    extends _$ReportEntityCopyWithImpl<$Res, _$ReportEntityImpl>
    implements _$$ReportEntityImplCopyWith<$Res> {
  __$$ReportEntityImplCopyWithImpl(
    _$ReportEntityImpl _value,
    $Res Function(_$ReportEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReportEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? branchId = freezed,
    Object? title = null,
    Object? description = freezed,
    Object? category = null,
    Object? recipient = null,
    Object? privacy = null,
    Object? severity = null,
    Object? status = null,
    Object? reporterDisplayName = freezed,
    Object? attachments = null,
    Object? activityLog = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? resolvedAt = freezed,
  }) {
    return _then(
      _$ReportEntityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        branchId: freezed == branchId
            ? _value.branchId
            : branchId // ignore: cast_nullable_to_non_nullable
                  as String?,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as ReportCategory,
        recipient: null == recipient
            ? _value.recipient
            : recipient // ignore: cast_nullable_to_non_nullable
                  as ReportRecipient,
        privacy: null == privacy
            ? _value.privacy
            : privacy // ignore: cast_nullable_to_non_nullable
                  as ReportPrivacy,
        severity: null == severity
            ? _value.severity
            : severity // ignore: cast_nullable_to_non_nullable
                  as ReportSeverity,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ReportStatus,
        reporterDisplayName: freezed == reporterDisplayName
            ? _value.reporterDisplayName
            : reporterDisplayName // ignore: cast_nullable_to_non_nullable
                  as String?,
        attachments: null == attachments
            ? _value._attachments
            : attachments // ignore: cast_nullable_to_non_nullable
                  as List<TaskAttachment>,
        activityLog: null == activityLog
            ? _value._activityLog
            : activityLog // ignore: cast_nullable_to_non_nullable
                  as List<ActivityEntry>,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        resolvedAt: freezed == resolvedAt
            ? _value.resolvedAt
            : resolvedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$ReportEntityImpl extends _ReportEntity {
  const _$ReportEntityImpl({
    required this.id,
    this.branchId,
    required this.title,
    this.description,
    this.category = ReportCategory.operations,
    this.recipient = ReportRecipient.manager,
    this.privacy = ReportPrivacy.normal,
    this.severity = ReportSeverity.medium,
    this.status = ReportStatus.newReport,
    this.reporterDisplayName,
    final List<TaskAttachment> attachments = const <TaskAttachment>[],
    final List<ActivityEntry> activityLog = const <ActivityEntry>[],
    this.createdAt,
    this.updatedAt,
    this.resolvedAt,
  }) : _attachments = attachments,
       _activityLog = activityLog,
       super._();

  @override
  final String id;

  /// Owning branch (the reporter's branch). Scopes every read/query.
  @override
  final String? branchId;
  @override
  final String title;
  @override
  final String? description;
  @override
  @JsonKey()
  final ReportCategory category;
  @override
  @JsonKey()
  final ReportRecipient recipient;
  @override
  @JsonKey()
  final ReportPrivacy privacy;
  @override
  @JsonKey()
  final ReportSeverity severity;
  @override
  @JsonKey()
  final ReportStatus status;

  /// Denormalized sender name — set ONLY when [privacy] is normal; null
  /// otherwise (UI then shows "Confidential Sender"). The raw uid is never
  /// here (see the private `reporter/identity` subdoc).
  @override
  final String? reporterDisplayName;

  /// Media attached to the report (reuses the task attachment pipeline;
  /// Storage `reports/{id}/attachments/{attId}.<ext>`).
  final List<TaskAttachment> _attachments;

  /// Media attached to the report (reuses the task attachment pipeline;
  /// Storage `reports/{id}/attachments/{attId}.<ext>`).
  @override
  @JsonKey()
  List<TaskAttachment> get attachments {
    if (_attachments is EqualUnmodifiableListView) return _attachments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attachments);
  }

  /// The conversation thread (opening message context + replies + markers).
  final List<ActivityEntry> _activityLog;

  /// The conversation thread (opening message context + replies + markers).
  @override
  @JsonKey()
  List<ActivityEntry> get activityLog {
    if (_activityLog is EqualUnmodifiableListView) return _activityLog;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_activityLog);
  }

  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final DateTime? resolvedAt;

  @override
  String toString() {
    return 'ReportEntity(id: $id, branchId: $branchId, title: $title, description: $description, category: $category, recipient: $recipient, privacy: $privacy, severity: $severity, status: $status, reporterDisplayName: $reporterDisplayName, attachments: $attachments, activityLog: $activityLog, createdAt: $createdAt, updatedAt: $updatedAt, resolvedAt: $resolvedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReportEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.branchId, branchId) ||
                other.branchId == branchId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.recipient, recipient) ||
                other.recipient == recipient) &&
            (identical(other.privacy, privacy) || other.privacy == privacy) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.reporterDisplayName, reporterDisplayName) ||
                other.reporterDisplayName == reporterDisplayName) &&
            const DeepCollectionEquality().equals(
              other._attachments,
              _attachments,
            ) &&
            const DeepCollectionEquality().equals(
              other._activityLog,
              _activityLog,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.resolvedAt, resolvedAt) ||
                other.resolvedAt == resolvedAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    branchId,
    title,
    description,
    category,
    recipient,
    privacy,
    severity,
    status,
    reporterDisplayName,
    const DeepCollectionEquality().hash(_attachments),
    const DeepCollectionEquality().hash(_activityLog),
    createdAt,
    updatedAt,
    resolvedAt,
  );

  /// Create a copy of ReportEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReportEntityImplCopyWith<_$ReportEntityImpl> get copyWith =>
      __$$ReportEntityImplCopyWithImpl<_$ReportEntityImpl>(this, _$identity);
}

abstract class _ReportEntity extends ReportEntity {
  const factory _ReportEntity({
    required final String id,
    final String? branchId,
    required final String title,
    final String? description,
    final ReportCategory category,
    final ReportRecipient recipient,
    final ReportPrivacy privacy,
    final ReportSeverity severity,
    final ReportStatus status,
    final String? reporterDisplayName,
    final List<TaskAttachment> attachments,
    final List<ActivityEntry> activityLog,
    final DateTime? createdAt,
    final DateTime? updatedAt,
    final DateTime? resolvedAt,
  }) = _$ReportEntityImpl;
  const _ReportEntity._() : super._();

  @override
  String get id;

  /// Owning branch (the reporter's branch). Scopes every read/query.
  @override
  String? get branchId;
  @override
  String get title;
  @override
  String? get description;
  @override
  ReportCategory get category;
  @override
  ReportRecipient get recipient;
  @override
  ReportPrivacy get privacy;
  @override
  ReportSeverity get severity;
  @override
  ReportStatus get status;

  /// Denormalized sender name — set ONLY when [privacy] is normal; null
  /// otherwise (UI then shows "Confidential Sender"). The raw uid is never
  /// here (see the private `reporter/identity` subdoc).
  @override
  String? get reporterDisplayName;

  /// Media attached to the report (reuses the task attachment pipeline;
  /// Storage `reports/{id}/attachments/{attId}.<ext>`).
  @override
  List<TaskAttachment> get attachments;

  /// The conversation thread (opening message context + replies + markers).
  @override
  List<ActivityEntry> get activityLog;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  DateTime? get resolvedAt;

  /// Create a copy of ReportEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReportEntityImplCopyWith<_$ReportEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
