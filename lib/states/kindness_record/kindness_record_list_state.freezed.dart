// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'kindness_record_list_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$KindnessRecordListState {
  List<KindnessRecord> get kindnessRecords =>
      throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of KindnessRecordListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $KindnessRecordListStateCopyWith<KindnessRecordListState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KindnessRecordListStateCopyWith<$Res> {
  factory $KindnessRecordListStateCopyWith(
    KindnessRecordListState value,
    $Res Function(KindnessRecordListState) then,
  ) = _$KindnessRecordListStateCopyWithImpl<$Res, KindnessRecordListState>;
  @useResult
  $Res call({
    List<KindnessRecord> kindnessRecords,
    bool isLoading,
    String? errorMessage,
  });
}

/// @nodoc
class _$KindnessRecordListStateCopyWithImpl<
  $Res,
  $Val extends KindnessRecordListState
>
    implements $KindnessRecordListStateCopyWith<$Res> {
  _$KindnessRecordListStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of KindnessRecordListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? kindnessRecords = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            kindnessRecords:
                null == kindnessRecords
                    ? _value.kindnessRecords
                    : kindnessRecords // ignore: cast_nullable_to_non_nullable
                        as List<KindnessRecord>,
            isLoading:
                null == isLoading
                    ? _value.isLoading
                    : isLoading // ignore: cast_nullable_to_non_nullable
                        as bool,
            errorMessage:
                freezed == errorMessage
                    ? _value.errorMessage
                    : errorMessage // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$KindnessRecordListStateImplCopyWith<$Res>
    implements $KindnessRecordListStateCopyWith<$Res> {
  factory _$$KindnessRecordListStateImplCopyWith(
    _$KindnessRecordListStateImpl value,
    $Res Function(_$KindnessRecordListStateImpl) then,
  ) = __$$KindnessRecordListStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<KindnessRecord> kindnessRecords,
    bool isLoading,
    String? errorMessage,
  });
}

/// @nodoc
class __$$KindnessRecordListStateImplCopyWithImpl<$Res>
    extends
        _$KindnessRecordListStateCopyWithImpl<
          $Res,
          _$KindnessRecordListStateImpl
        >
    implements _$$KindnessRecordListStateImplCopyWith<$Res> {
  __$$KindnessRecordListStateImplCopyWithImpl(
    _$KindnessRecordListStateImpl _value,
    $Res Function(_$KindnessRecordListStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of KindnessRecordListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? kindnessRecords = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$KindnessRecordListStateImpl(
        kindnessRecords:
            null == kindnessRecords
                ? _value._kindnessRecords
                : kindnessRecords // ignore: cast_nullable_to_non_nullable
                    as List<KindnessRecord>,
        isLoading:
            null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                    as bool,
        errorMessage:
            freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc

class _$KindnessRecordListStateImpl implements _KindnessRecordListState {
  const _$KindnessRecordListStateImpl({
    final List<KindnessRecord> kindnessRecords = const [],
    this.isLoading = false,
    this.errorMessage,
  }) : _kindnessRecords = kindnessRecords;

  final List<KindnessRecord> _kindnessRecords;
  @override
  @JsonKey()
  List<KindnessRecord> get kindnessRecords {
    if (_kindnessRecords is EqualUnmodifiableListView) return _kindnessRecords;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_kindnessRecords);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'KindnessRecordListState(kindnessRecords: $kindnessRecords, isLoading: $isLoading, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KindnessRecordListStateImpl &&
            const DeepCollectionEquality().equals(
              other._kindnessRecords,
              _kindnessRecords,
            ) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_kindnessRecords),
    isLoading,
    errorMessage,
  );

  /// Create a copy of KindnessRecordListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$KindnessRecordListStateImplCopyWith<_$KindnessRecordListStateImpl>
  get copyWith => __$$KindnessRecordListStateImplCopyWithImpl<
    _$KindnessRecordListStateImpl
  >(this, _$identity);
}

abstract class _KindnessRecordListState implements KindnessRecordListState {
  const factory _KindnessRecordListState({
    final List<KindnessRecord> kindnessRecords,
    final bool isLoading,
    final String? errorMessage,
  }) = _$KindnessRecordListStateImpl;

  @override
  List<KindnessRecord> get kindnessRecords;
  @override
  bool get isLoading;
  @override
  String? get errorMessage;

  /// Create a copy of KindnessRecordListState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$KindnessRecordListStateImplCopyWith<_$KindnessRecordListStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}
