// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'case_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CaseEntity {
  String get id => throw _privateConstructorUsedError;

  /// Owning branch (the reporter's branch). Scopes every read/query.
  String? get branchId => throw _privateConstructorUsedError;
  String get subject => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  CaseCategory get category => throw _privateConstructorUsedError;
  CaseRecipient get recipient => throw _privateConstructorUsedError;
  CasePrivacy get privacy => throw _privateConstructorUsedError;

  /// A single escalation signal (replaces the old 4-level severity). Urgent
  /// cases sort above normal ones in the inbox and show an urgent badge.
  bool get urgent => throw _privateConstructorUsedError;
  CaseStatus get status => throw _privateConstructorUsedError;

  /// Denormalized sender name — set ONLY when [privacy] is normal; null
  /// otherwise (UI then shows "Confidential Sender").
  String? get reporterDisplayName => throw _privateConstructorUsedError;

  /// Opening media the filer attached (consumed by `onCaseCreated` into the
  /// opening message; Storage `cases/{id}/attachments/{attId}.<ext>`).
  List<TaskAttachment> get attachments => throw _privateConstructorUsedError;

  /// Denormalized last-message preview for the inbox row (bumped server-side).
  String? get lastMessagePreview => throw _privateConstructorUsedError;

  /// Timestamp of the newest message — the inbox orders active cases by this.
  DateTime? get lastMessageAt => throw _privateConstructorUsedError;
  int get messageCount => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  DateTime? get closedAt => throw _privateConstructorUsedError;

  /// Create a copy of CaseEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CaseEntityCopyWith<CaseEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CaseEntityCopyWith<$Res> {
  factory $CaseEntityCopyWith(
    CaseEntity value,
    $Res Function(CaseEntity) then,
  ) = _$CaseEntityCopyWithImpl<$Res, CaseEntity>;
  @useResult
  $Res call({
    String id,
    String? branchId,
    String subject,
    String? description,
    CaseCategory category,
    CaseRecipient recipient,
    CasePrivacy privacy,
    bool urgent,
    CaseStatus status,
    String? reporterDisplayName,
    List<TaskAttachment> attachments,
    String? lastMessagePreview,
    DateTime? lastMessageAt,
    int messageCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? closedAt,
  });
}

/// @nodoc
class _$CaseEntityCopyWithImpl<$Res, $Val extends CaseEntity>
    implements $CaseEntityCopyWith<$Res> {
  _$CaseEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CaseEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? branchId = freezed,
    Object? subject = null,
    Object? description = freezed,
    Object? category = null,
    Object? recipient = null,
    Object? privacy = null,
    Object? urgent = null,
    Object? status = null,
    Object? reporterDisplayName = freezed,
    Object? attachments = null,
    Object? lastMessagePreview = freezed,
    Object? lastMessageAt = freezed,
    Object? messageCount = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? closedAt = freezed,
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
            subject: null == subject
                ? _value.subject
                : subject // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as CaseCategory,
            recipient: null == recipient
                ? _value.recipient
                : recipient // ignore: cast_nullable_to_non_nullable
                      as CaseRecipient,
            privacy: null == privacy
                ? _value.privacy
                : privacy // ignore: cast_nullable_to_non_nullable
                      as CasePrivacy,
            urgent: null == urgent
                ? _value.urgent
                : urgent // ignore: cast_nullable_to_non_nullable
                      as bool,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as CaseStatus,
            reporterDisplayName: freezed == reporterDisplayName
                ? _value.reporterDisplayName
                : reporterDisplayName // ignore: cast_nullable_to_non_nullable
                      as String?,
            attachments: null == attachments
                ? _value.attachments
                : attachments // ignore: cast_nullable_to_non_nullable
                      as List<TaskAttachment>,
            lastMessagePreview: freezed == lastMessagePreview
                ? _value.lastMessagePreview
                : lastMessagePreview // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastMessageAt: freezed == lastMessageAt
                ? _value.lastMessageAt
                : lastMessageAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            messageCount: null == messageCount
                ? _value.messageCount
                : messageCount // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            closedAt: freezed == closedAt
                ? _value.closedAt
                : closedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CaseEntityImplCopyWith<$Res>
    implements $CaseEntityCopyWith<$Res> {
  factory _$$CaseEntityImplCopyWith(
    _$CaseEntityImpl value,
    $Res Function(_$CaseEntityImpl) then,
  ) = __$$CaseEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? branchId,
    String subject,
    String? description,
    CaseCategory category,
    CaseRecipient recipient,
    CasePrivacy privacy,
    bool urgent,
    CaseStatus status,
    String? reporterDisplayName,
    List<TaskAttachment> attachments,
    String? lastMessagePreview,
    DateTime? lastMessageAt,
    int messageCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? closedAt,
  });
}

/// @nodoc
class __$$CaseEntityImplCopyWithImpl<$Res>
    extends _$CaseEntityCopyWithImpl<$Res, _$CaseEntityImpl>
    implements _$$CaseEntityImplCopyWith<$Res> {
  __$$CaseEntityImplCopyWithImpl(
    _$CaseEntityImpl _value,
    $Res Function(_$CaseEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CaseEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? branchId = freezed,
    Object? subject = null,
    Object? description = freezed,
    Object? category = null,
    Object? recipient = null,
    Object? privacy = null,
    Object? urgent = null,
    Object? status = null,
    Object? reporterDisplayName = freezed,
    Object? attachments = null,
    Object? lastMessagePreview = freezed,
    Object? lastMessageAt = freezed,
    Object? messageCount = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? closedAt = freezed,
  }) {
    return _then(
      _$CaseEntityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        branchId: freezed == branchId
            ? _value.branchId
            : branchId // ignore: cast_nullable_to_non_nullable
                  as String?,
        subject: null == subject
            ? _value.subject
            : subject // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as CaseCategory,
        recipient: null == recipient
            ? _value.recipient
            : recipient // ignore: cast_nullable_to_non_nullable
                  as CaseRecipient,
        privacy: null == privacy
            ? _value.privacy
            : privacy // ignore: cast_nullable_to_non_nullable
                  as CasePrivacy,
        urgent: null == urgent
            ? _value.urgent
            : urgent // ignore: cast_nullable_to_non_nullable
                  as bool,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as CaseStatus,
        reporterDisplayName: freezed == reporterDisplayName
            ? _value.reporterDisplayName
            : reporterDisplayName // ignore: cast_nullable_to_non_nullable
                  as String?,
        attachments: null == attachments
            ? _value._attachments
            : attachments // ignore: cast_nullable_to_non_nullable
                  as List<TaskAttachment>,
        lastMessagePreview: freezed == lastMessagePreview
            ? _value.lastMessagePreview
            : lastMessagePreview // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastMessageAt: freezed == lastMessageAt
            ? _value.lastMessageAt
            : lastMessageAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        messageCount: null == messageCount
            ? _value.messageCount
            : messageCount // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        closedAt: freezed == closedAt
            ? _value.closedAt
            : closedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$CaseEntityImpl extends _CaseEntity {
  const _$CaseEntityImpl({
    required this.id,
    this.branchId,
    required this.subject,
    this.description,
    this.category = CaseCategory.operations,
    this.recipient = CaseRecipient.manager,
    this.privacy = CasePrivacy.normal,
    this.urgent = false,
    this.status = CaseStatus.open,
    this.reporterDisplayName,
    final List<TaskAttachment> attachments = const <TaskAttachment>[],
    this.lastMessagePreview,
    this.lastMessageAt,
    this.messageCount = 0,
    this.createdAt,
    this.updatedAt,
    this.closedAt,
  }) : _attachments = attachments,
       super._();

  @override
  final String id;

  /// Owning branch (the reporter's branch). Scopes every read/query.
  @override
  final String? branchId;
  @override
  final String subject;
  @override
  final String? description;
  @override
  @JsonKey()
  final CaseCategory category;
  @override
  @JsonKey()
  final CaseRecipient recipient;
  @override
  @JsonKey()
  final CasePrivacy privacy;

  /// A single escalation signal (replaces the old 4-level severity). Urgent
  /// cases sort above normal ones in the inbox and show an urgent badge.
  @override
  @JsonKey()
  final bool urgent;
  @override
  @JsonKey()
  final CaseStatus status;

  /// Denormalized sender name — set ONLY when [privacy] is normal; null
  /// otherwise (UI then shows "Confidential Sender").
  @override
  final String? reporterDisplayName;

  /// Opening media the filer attached (consumed by `onCaseCreated` into the
  /// opening message; Storage `cases/{id}/attachments/{attId}.<ext>`).
  final List<TaskAttachment> _attachments;

  /// Opening media the filer attached (consumed by `onCaseCreated` into the
  /// opening message; Storage `cases/{id}/attachments/{attId}.<ext>`).
  @override
  @JsonKey()
  List<TaskAttachment> get attachments {
    if (_attachments is EqualUnmodifiableListView) return _attachments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attachments);
  }

  /// Denormalized last-message preview for the inbox row (bumped server-side).
  @override
  final String? lastMessagePreview;

  /// Timestamp of the newest message — the inbox orders active cases by this.
  @override
  final DateTime? lastMessageAt;
  @override
  @JsonKey()
  final int messageCount;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final DateTime? closedAt;

  @override
  String toString() {
    return 'CaseEntity(id: $id, branchId: $branchId, subject: $subject, description: $description, category: $category, recipient: $recipient, privacy: $privacy, urgent: $urgent, status: $status, reporterDisplayName: $reporterDisplayName, attachments: $attachments, lastMessagePreview: $lastMessagePreview, lastMessageAt: $lastMessageAt, messageCount: $messageCount, createdAt: $createdAt, updatedAt: $updatedAt, closedAt: $closedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CaseEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.branchId, branchId) ||
                other.branchId == branchId) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.recipient, recipient) ||
                other.recipient == recipient) &&
            (identical(other.privacy, privacy) || other.privacy == privacy) &&
            (identical(other.urgent, urgent) || other.urgent == urgent) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.reporterDisplayName, reporterDisplayName) ||
                other.reporterDisplayName == reporterDisplayName) &&
            const DeepCollectionEquality().equals(
              other._attachments,
              _attachments,
            ) &&
            (identical(other.lastMessagePreview, lastMessagePreview) ||
                other.lastMessagePreview == lastMessagePreview) &&
            (identical(other.lastMessageAt, lastMessageAt) ||
                other.lastMessageAt == lastMessageAt) &&
            (identical(other.messageCount, messageCount) ||
                other.messageCount == messageCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.closedAt, closedAt) ||
                other.closedAt == closedAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    branchId,
    subject,
    description,
    category,
    recipient,
    privacy,
    urgent,
    status,
    reporterDisplayName,
    const DeepCollectionEquality().hash(_attachments),
    lastMessagePreview,
    lastMessageAt,
    messageCount,
    createdAt,
    updatedAt,
    closedAt,
  );

  /// Create a copy of CaseEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CaseEntityImplCopyWith<_$CaseEntityImpl> get copyWith =>
      __$$CaseEntityImplCopyWithImpl<_$CaseEntityImpl>(this, _$identity);
}

abstract class _CaseEntity extends CaseEntity {
  const factory _CaseEntity({
    required final String id,
    final String? branchId,
    required final String subject,
    final String? description,
    final CaseCategory category,
    final CaseRecipient recipient,
    final CasePrivacy privacy,
    final bool urgent,
    final CaseStatus status,
    final String? reporterDisplayName,
    final List<TaskAttachment> attachments,
    final String? lastMessagePreview,
    final DateTime? lastMessageAt,
    final int messageCount,
    final DateTime? createdAt,
    final DateTime? updatedAt,
    final DateTime? closedAt,
  }) = _$CaseEntityImpl;
  const _CaseEntity._() : super._();

  @override
  String get id;

  /// Owning branch (the reporter's branch). Scopes every read/query.
  @override
  String? get branchId;
  @override
  String get subject;
  @override
  String? get description;
  @override
  CaseCategory get category;
  @override
  CaseRecipient get recipient;
  @override
  CasePrivacy get privacy;

  /// A single escalation signal (replaces the old 4-level severity). Urgent
  /// cases sort above normal ones in the inbox and show an urgent badge.
  @override
  bool get urgent;
  @override
  CaseStatus get status;

  /// Denormalized sender name — set ONLY when [privacy] is normal; null
  /// otherwise (UI then shows "Confidential Sender").
  @override
  String? get reporterDisplayName;

  /// Opening media the filer attached (consumed by `onCaseCreated` into the
  /// opening message; Storage `cases/{id}/attachments/{attId}.<ext>`).
  @override
  List<TaskAttachment> get attachments;

  /// Denormalized last-message preview for the inbox row (bumped server-side).
  @override
  String? get lastMessagePreview;

  /// Timestamp of the newest message — the inbox orders active cases by this.
  @override
  DateTime? get lastMessageAt;
  @override
  int get messageCount;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  DateTime? get closedAt;

  /// Create a copy of CaseEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CaseEntityImplCopyWith<_$CaseEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
