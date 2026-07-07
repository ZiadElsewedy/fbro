// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'case_conversation_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CaseConversationState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(
      CaseEntity caseItem,
      List<CaseMessage> messages,
      bool sending,
      bool changingStatus,
    )
    loaded,
    required TResult Function() unavailable,
    required TResult Function(String message) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(
      CaseEntity caseItem,
      List<CaseMessage> messages,
      bool sending,
      bool changingStatus,
    )?
    loaded,
    TResult? Function()? unavailable,
    TResult? Function(String message)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(
      CaseEntity caseItem,
      List<CaseMessage> messages,
      bool sending,
      bool changingStatus,
    )?
    loaded,
    TResult Function()? unavailable,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Unavailable value) unavailable,
    required TResult Function(_Error value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Unavailable value)? unavailable,
    TResult? Function(_Error value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Unavailable value)? unavailable,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CaseConversationStateCopyWith<$Res> {
  factory $CaseConversationStateCopyWith(
    CaseConversationState value,
    $Res Function(CaseConversationState) then,
  ) = _$CaseConversationStateCopyWithImpl<$Res, CaseConversationState>;
}

/// @nodoc
class _$CaseConversationStateCopyWithImpl<
  $Res,
  $Val extends CaseConversationState
>
    implements $CaseConversationStateCopyWith<$Res> {
  _$CaseConversationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CaseConversationState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$LoadingImplCopyWith<$Res> {
  factory _$$LoadingImplCopyWith(
    _$LoadingImpl value,
    $Res Function(_$LoadingImpl) then,
  ) = __$$LoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadingImplCopyWithImpl<$Res>
    extends _$CaseConversationStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
    _$LoadingImpl _value,
    $Res Function(_$LoadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CaseConversationState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadingImpl implements _Loading {
  const _$LoadingImpl();

  @override
  String toString() {
    return 'CaseConversationState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(
      CaseEntity caseItem,
      List<CaseMessage> messages,
      bool sending,
      bool changingStatus,
    )
    loaded,
    required TResult Function() unavailable,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(
      CaseEntity caseItem,
      List<CaseMessage> messages,
      bool sending,
      bool changingStatus,
    )?
    loaded,
    TResult? Function()? unavailable,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(
      CaseEntity caseItem,
      List<CaseMessage> messages,
      bool sending,
      bool changingStatus,
    )?
    loaded,
    TResult Function()? unavailable,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Unavailable value) unavailable,
    required TResult Function(_Error value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Unavailable value)? unavailable,
    TResult? Function(_Error value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Unavailable value)? unavailable,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _Loading implements CaseConversationState {
  const factory _Loading() = _$LoadingImpl;
}

/// @nodoc
abstract class _$$LoadedImplCopyWith<$Res> {
  factory _$$LoadedImplCopyWith(
    _$LoadedImpl value,
    $Res Function(_$LoadedImpl) then,
  ) = __$$LoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    CaseEntity caseItem,
    List<CaseMessage> messages,
    bool sending,
    bool changingStatus,
  });

  $CaseEntityCopyWith<$Res> get caseItem;
}

/// @nodoc
class __$$LoadedImplCopyWithImpl<$Res>
    extends _$CaseConversationStateCopyWithImpl<$Res, _$LoadedImpl>
    implements _$$LoadedImplCopyWith<$Res> {
  __$$LoadedImplCopyWithImpl(
    _$LoadedImpl _value,
    $Res Function(_$LoadedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CaseConversationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? caseItem = null,
    Object? messages = null,
    Object? sending = null,
    Object? changingStatus = null,
  }) {
    return _then(
      _$LoadedImpl(
        null == caseItem
            ? _value.caseItem
            : caseItem // ignore: cast_nullable_to_non_nullable
                  as CaseEntity,
        null == messages
            ? _value._messages
            : messages // ignore: cast_nullable_to_non_nullable
                  as List<CaseMessage>,
        sending: null == sending
            ? _value.sending
            : sending // ignore: cast_nullable_to_non_nullable
                  as bool,
        changingStatus: null == changingStatus
            ? _value.changingStatus
            : changingStatus // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }

  /// Create a copy of CaseConversationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CaseEntityCopyWith<$Res> get caseItem {
    return $CaseEntityCopyWith<$Res>(_value.caseItem, (value) {
      return _then(_value.copyWith(caseItem: value));
    });
  }
}

/// @nodoc

class _$LoadedImpl implements _Loaded {
  const _$LoadedImpl(
    this.caseItem,
    final List<CaseMessage> messages, {
    this.sending = false,
    this.changingStatus = false,
  }) : _messages = messages;

  @override
  final CaseEntity caseItem;
  final List<CaseMessage> _messages;
  @override
  List<CaseMessage> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  @override
  @JsonKey()
  final bool sending;
  @override
  @JsonKey()
  final bool changingStatus;

  @override
  String toString() {
    return 'CaseConversationState.loaded(caseItem: $caseItem, messages: $messages, sending: $sending, changingStatus: $changingStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadedImpl &&
            (identical(other.caseItem, caseItem) ||
                other.caseItem == caseItem) &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            (identical(other.sending, sending) || other.sending == sending) &&
            (identical(other.changingStatus, changingStatus) ||
                other.changingStatus == changingStatus));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    caseItem,
    const DeepCollectionEquality().hash(_messages),
    sending,
    changingStatus,
  );

  /// Create a copy of CaseConversationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadedImplCopyWith<_$LoadedImpl> get copyWith =>
      __$$LoadedImplCopyWithImpl<_$LoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(
      CaseEntity caseItem,
      List<CaseMessage> messages,
      bool sending,
      bool changingStatus,
    )
    loaded,
    required TResult Function() unavailable,
    required TResult Function(String message) error,
  }) {
    return loaded(caseItem, messages, sending, changingStatus);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(
      CaseEntity caseItem,
      List<CaseMessage> messages,
      bool sending,
      bool changingStatus,
    )?
    loaded,
    TResult? Function()? unavailable,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(caseItem, messages, sending, changingStatus);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(
      CaseEntity caseItem,
      List<CaseMessage> messages,
      bool sending,
      bool changingStatus,
    )?
    loaded,
    TResult Function()? unavailable,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(caseItem, messages, sending, changingStatus);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Unavailable value) unavailable,
    required TResult Function(_Error value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Unavailable value)? unavailable,
    TResult? Function(_Error value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Unavailable value)? unavailable,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class _Loaded implements CaseConversationState {
  const factory _Loaded(
    final CaseEntity caseItem,
    final List<CaseMessage> messages, {
    final bool sending,
    final bool changingStatus,
  }) = _$LoadedImpl;

  CaseEntity get caseItem;
  List<CaseMessage> get messages;
  bool get sending;
  bool get changingStatus;

  /// Create a copy of CaseConversationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoadedImplCopyWith<_$LoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UnavailableImplCopyWith<$Res> {
  factory _$$UnavailableImplCopyWith(
    _$UnavailableImpl value,
    $Res Function(_$UnavailableImpl) then,
  ) = __$$UnavailableImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$UnavailableImplCopyWithImpl<$Res>
    extends _$CaseConversationStateCopyWithImpl<$Res, _$UnavailableImpl>
    implements _$$UnavailableImplCopyWith<$Res> {
  __$$UnavailableImplCopyWithImpl(
    _$UnavailableImpl _value,
    $Res Function(_$UnavailableImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CaseConversationState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$UnavailableImpl implements _Unavailable {
  const _$UnavailableImpl();

  @override
  String toString() {
    return 'CaseConversationState.unavailable()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$UnavailableImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(
      CaseEntity caseItem,
      List<CaseMessage> messages,
      bool sending,
      bool changingStatus,
    )
    loaded,
    required TResult Function() unavailable,
    required TResult Function(String message) error,
  }) {
    return unavailable();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(
      CaseEntity caseItem,
      List<CaseMessage> messages,
      bool sending,
      bool changingStatus,
    )?
    loaded,
    TResult? Function()? unavailable,
    TResult? Function(String message)? error,
  }) {
    return unavailable?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(
      CaseEntity caseItem,
      List<CaseMessage> messages,
      bool sending,
      bool changingStatus,
    )?
    loaded,
    TResult Function()? unavailable,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (unavailable != null) {
      return unavailable();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Unavailable value) unavailable,
    required TResult Function(_Error value) error,
  }) {
    return unavailable(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Unavailable value)? unavailable,
    TResult? Function(_Error value)? error,
  }) {
    return unavailable?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Unavailable value)? unavailable,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (unavailable != null) {
      return unavailable(this);
    }
    return orElse();
  }
}

abstract class _Unavailable implements CaseConversationState {
  const factory _Unavailable() = _$UnavailableImpl;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<$Res> {
  factory _$$ErrorImplCopyWith(
    _$ErrorImpl value,
    $Res Function(_$ErrorImpl) then,
  ) = __$$ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<$Res>
    extends _$CaseConversationStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
    _$ErrorImpl _value,
    $Res Function(_$ErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CaseConversationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$ErrorImpl(
        null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$ErrorImpl implements _Error {
  const _$ErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'CaseConversationState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of CaseConversationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      __$$ErrorImplCopyWithImpl<_$ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(
      CaseEntity caseItem,
      List<CaseMessage> messages,
      bool sending,
      bool changingStatus,
    )
    loaded,
    required TResult Function() unavailable,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(
      CaseEntity caseItem,
      List<CaseMessage> messages,
      bool sending,
      bool changingStatus,
    )?
    loaded,
    TResult? Function()? unavailable,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(
      CaseEntity caseItem,
      List<CaseMessage> messages,
      bool sending,
      bool changingStatus,
    )?
    loaded,
    TResult Function()? unavailable,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Unavailable value) unavailable,
    required TResult Function(_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Unavailable value)? unavailable,
    TResult? Function(_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Unavailable value)? unavailable,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements CaseConversationState {
  const factory _Error(final String message) = _$ErrorImpl;

  String get message;

  /// Create a copy of CaseConversationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
