// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance_admin_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AttendanceAdminState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      String branchId,
      List<BranchEntity> branches,
      AttendanceBoard board,
      List<AttendanceCorrectionEntity> corrections,
      DateTime now,
      bool deciding,
    )
    loaded,
    required TResult Function(String message) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      String branchId,
      List<BranchEntity> branches,
      AttendanceBoard board,
      List<AttendanceCorrectionEntity> corrections,
      DateTime now,
      bool deciding,
    )?
    loaded,
    TResult? Function(String message)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      String branchId,
      List<BranchEntity> branches,
      AttendanceBoard board,
      List<AttendanceCorrectionEntity> corrections,
      DateTime now,
      bool deciding,
    )?
    loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AttendanceAdminStateCopyWith<$Res> {
  factory $AttendanceAdminStateCopyWith(
    AttendanceAdminState value,
    $Res Function(AttendanceAdminState) then,
  ) = _$AttendanceAdminStateCopyWithImpl<$Res, AttendanceAdminState>;
}

/// @nodoc
class _$AttendanceAdminStateCopyWithImpl<
  $Res,
  $Val extends AttendanceAdminState
>
    implements $AttendanceAdminStateCopyWith<$Res> {
  _$AttendanceAdminStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AttendanceAdminState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$InitialImplCopyWith<$Res> {
  factory _$$InitialImplCopyWith(
    _$InitialImpl value,
    $Res Function(_$InitialImpl) then,
  ) = __$$InitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$AttendanceAdminStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
    _$InitialImpl _value,
    $Res Function(_$InitialImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AttendanceAdminState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'AttendanceAdminState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$InitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      String branchId,
      List<BranchEntity> branches,
      AttendanceBoard board,
      List<AttendanceCorrectionEntity> corrections,
      DateTime now,
      bool deciding,
    )
    loaded,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      String branchId,
      List<BranchEntity> branches,
      AttendanceBoard board,
      List<AttendanceCorrectionEntity> corrections,
      DateTime now,
      bool deciding,
    )?
    loaded,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      String branchId,
      List<BranchEntity> branches,
      AttendanceBoard board,
      List<AttendanceCorrectionEntity> corrections,
      DateTime now,
      bool deciding,
    )?
    loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements AttendanceAdminState {
  const factory _Initial() = _$InitialImpl;
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
    extends _$AttendanceAdminStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
    _$LoadingImpl _value,
    $Res Function(_$LoadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AttendanceAdminState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadingImpl implements _Loading {
  const _$LoadingImpl();

  @override
  String toString() {
    return 'AttendanceAdminState.loading()';
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
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      String branchId,
      List<BranchEntity> branches,
      AttendanceBoard board,
      List<AttendanceCorrectionEntity> corrections,
      DateTime now,
      bool deciding,
    )
    loaded,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      String branchId,
      List<BranchEntity> branches,
      AttendanceBoard board,
      List<AttendanceCorrectionEntity> corrections,
      DateTime now,
      bool deciding,
    )?
    loaded,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      String branchId,
      List<BranchEntity> branches,
      AttendanceBoard board,
      List<AttendanceCorrectionEntity> corrections,
      DateTime now,
      bool deciding,
    )?
    loaded,
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
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _Loading implements AttendanceAdminState {
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
    String branchId,
    List<BranchEntity> branches,
    AttendanceBoard board,
    List<AttendanceCorrectionEntity> corrections,
    DateTime now,
    bool deciding,
  });
}

/// @nodoc
class __$$LoadedImplCopyWithImpl<$Res>
    extends _$AttendanceAdminStateCopyWithImpl<$Res, _$LoadedImpl>
    implements _$$LoadedImplCopyWith<$Res> {
  __$$LoadedImplCopyWithImpl(
    _$LoadedImpl _value,
    $Res Function(_$LoadedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AttendanceAdminState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? branchId = null,
    Object? branches = null,
    Object? board = null,
    Object? corrections = null,
    Object? now = null,
    Object? deciding = null,
  }) {
    return _then(
      _$LoadedImpl(
        branchId: null == branchId
            ? _value.branchId
            : branchId // ignore: cast_nullable_to_non_nullable
                  as String,
        branches: null == branches
            ? _value._branches
            : branches // ignore: cast_nullable_to_non_nullable
                  as List<BranchEntity>,
        board: null == board
            ? _value.board
            : board // ignore: cast_nullable_to_non_nullable
                  as AttendanceBoard,
        corrections: null == corrections
            ? _value._corrections
            : corrections // ignore: cast_nullable_to_non_nullable
                  as List<AttendanceCorrectionEntity>,
        now: null == now
            ? _value.now
            : now // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        deciding: null == deciding
            ? _value.deciding
            : deciding // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$LoadedImpl implements _Loaded {
  const _$LoadedImpl({
    required this.branchId,
    final List<BranchEntity> branches = const <BranchEntity>[],
    required this.board,
    final List<AttendanceCorrectionEntity> corrections =
        const <AttendanceCorrectionEntity>[],
    required this.now,
    this.deciding = false,
  }) : _branches = branches,
       _corrections = corrections;

  /// The branch currently in view.
  @override
  final String branchId;

  /// Branches the viewer may switch between (admin: all; a manager view would
  /// pass just their own). Drives the picker; a single entry hides it.
  final List<BranchEntity> _branches;

  /// Branches the viewer may switch between (admin: all; a manager view would
  /// pass just their own). Drives the picker; a single entry hides it.
  @override
  @JsonKey()
  List<BranchEntity> get branches {
    if (_branches is EqualUnmodifiableListView) return _branches;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_branches);
  }

  /// The roster × attendance join for today.
  @override
  final AttendanceBoard board;

  /// This branch's still-pending correction requests (the review queue).
  final List<AttendanceCorrectionEntity> _corrections;

  /// This branch's still-pending correction requests (the review queue).
  @override
  @JsonKey()
  List<AttendanceCorrectionEntity> get corrections {
    if (_corrections is EqualUnmodifiableListView) return _corrections;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_corrections);
  }

  /// The moment the board was derived (bumped by a minute tick so no-shows roll
  /// Not started → Late → Absent as time passes).
  @override
  final DateTime now;

  /// A correction decision is in flight.
  @override
  @JsonKey()
  final bool deciding;

  @override
  String toString() {
    return 'AttendanceAdminState.loaded(branchId: $branchId, branches: $branches, board: $board, corrections: $corrections, now: $now, deciding: $deciding)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadedImpl &&
            (identical(other.branchId, branchId) ||
                other.branchId == branchId) &&
            const DeepCollectionEquality().equals(other._branches, _branches) &&
            (identical(other.board, board) || other.board == board) &&
            const DeepCollectionEquality().equals(
              other._corrections,
              _corrections,
            ) &&
            (identical(other.now, now) || other.now == now) &&
            (identical(other.deciding, deciding) ||
                other.deciding == deciding));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    branchId,
    const DeepCollectionEquality().hash(_branches),
    board,
    const DeepCollectionEquality().hash(_corrections),
    now,
    deciding,
  );

  /// Create a copy of AttendanceAdminState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadedImplCopyWith<_$LoadedImpl> get copyWith =>
      __$$LoadedImplCopyWithImpl<_$LoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      String branchId,
      List<BranchEntity> branches,
      AttendanceBoard board,
      List<AttendanceCorrectionEntity> corrections,
      DateTime now,
      bool deciding,
    )
    loaded,
    required TResult Function(String message) error,
  }) {
    return loaded(branchId, branches, board, corrections, now, deciding);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      String branchId,
      List<BranchEntity> branches,
      AttendanceBoard board,
      List<AttendanceCorrectionEntity> corrections,
      DateTime now,
      bool deciding,
    )?
    loaded,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(branchId, branches, board, corrections, now, deciding);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      String branchId,
      List<BranchEntity> branches,
      AttendanceBoard board,
      List<AttendanceCorrectionEntity> corrections,
      DateTime now,
      bool deciding,
    )?
    loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(branchId, branches, board, corrections, now, deciding);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class _Loaded implements AttendanceAdminState {
  const factory _Loaded({
    required final String branchId,
    final List<BranchEntity> branches,
    required final AttendanceBoard board,
    final List<AttendanceCorrectionEntity> corrections,
    required final DateTime now,
    final bool deciding,
  }) = _$LoadedImpl;

  /// The branch currently in view.
  String get branchId;

  /// Branches the viewer may switch between (admin: all; a manager view would
  /// pass just their own). Drives the picker; a single entry hides it.
  List<BranchEntity> get branches;

  /// The roster × attendance join for today.
  AttendanceBoard get board;

  /// This branch's still-pending correction requests (the review queue).
  List<AttendanceCorrectionEntity> get corrections;

  /// The moment the board was derived (bumped by a minute tick so no-shows roll
  /// Not started → Late → Absent as time passes).
  DateTime get now;

  /// A correction decision is in flight.
  bool get deciding;

  /// Create a copy of AttendanceAdminState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoadedImplCopyWith<_$LoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
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
    extends _$AttendanceAdminStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
    _$ErrorImpl _value,
    $Res Function(_$ErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AttendanceAdminState
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
    return 'AttendanceAdminState.error(message: $message)';
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

  /// Create a copy of AttendanceAdminState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      __$$ErrorImplCopyWithImpl<_$ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      String branchId,
      List<BranchEntity> branches,
      AttendanceBoard board,
      List<AttendanceCorrectionEntity> corrections,
      DateTime now,
      bool deciding,
    )
    loaded,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      String branchId,
      List<BranchEntity> branches,
      AttendanceBoard board,
      List<AttendanceCorrectionEntity> corrections,
      DateTime now,
      bool deciding,
    )?
    loaded,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      String branchId,
      List<BranchEntity> branches,
      AttendanceBoard board,
      List<AttendanceCorrectionEntity> corrections,
      DateTime now,
      bool deciding,
    )?
    loaded,
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
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements AttendanceAdminState {
  const factory _Error(final String message) = _$ErrorImpl;

  String get message;

  /// Create a copy of AttendanceAdminState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
