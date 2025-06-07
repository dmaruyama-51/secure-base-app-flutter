// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tutorial_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TutorialState {
  int get currentPage => throw _privateConstructorUsedError;
  String get kindnessGiverName => throw _privateConstructorUsedError;
  String get selectedGender => throw _privateConstructorUsedError;
  String get selectedRelation => throw _privateConstructorUsedError;
  bool get isCompleting => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of TutorialState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TutorialStateCopyWith<TutorialState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TutorialStateCopyWith<$Res> {
  factory $TutorialStateCopyWith(
    TutorialState value,
    $Res Function(TutorialState) then,
  ) = _$TutorialStateCopyWithImpl<$Res, TutorialState>;
  @useResult
  $Res call({
    int currentPage,
    String kindnessGiverName,
    String selectedGender,
    String selectedRelation,
    bool isCompleting,
    String? errorMessage,
  });
}

/// @nodoc
class _$TutorialStateCopyWithImpl<$Res, $Val extends TutorialState>
    implements $TutorialStateCopyWith<$Res> {
  _$TutorialStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TutorialState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentPage = null,
    Object? kindnessGiverName = null,
    Object? selectedGender = null,
    Object? selectedRelation = null,
    Object? isCompleting = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            currentPage:
                null == currentPage
                    ? _value.currentPage
                    : currentPage // ignore: cast_nullable_to_non_nullable
                        as int,
            kindnessGiverName:
                null == kindnessGiverName
                    ? _value.kindnessGiverName
                    : kindnessGiverName // ignore: cast_nullable_to_non_nullable
                        as String,
            selectedGender:
                null == selectedGender
                    ? _value.selectedGender
                    : selectedGender // ignore: cast_nullable_to_non_nullable
                        as String,
            selectedRelation:
                null == selectedRelation
                    ? _value.selectedRelation
                    : selectedRelation // ignore: cast_nullable_to_non_nullable
                        as String,
            isCompleting:
                null == isCompleting
                    ? _value.isCompleting
                    : isCompleting // ignore: cast_nullable_to_non_nullable
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
abstract class _$$TutorialStateImplCopyWith<$Res>
    implements $TutorialStateCopyWith<$Res> {
  factory _$$TutorialStateImplCopyWith(
    _$TutorialStateImpl value,
    $Res Function(_$TutorialStateImpl) then,
  ) = __$$TutorialStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int currentPage,
    String kindnessGiverName,
    String selectedGender,
    String selectedRelation,
    bool isCompleting,
    String? errorMessage,
  });
}

/// @nodoc
class __$$TutorialStateImplCopyWithImpl<$Res>
    extends _$TutorialStateCopyWithImpl<$Res, _$TutorialStateImpl>
    implements _$$TutorialStateImplCopyWith<$Res> {
  __$$TutorialStateImplCopyWithImpl(
    _$TutorialStateImpl _value,
    $Res Function(_$TutorialStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TutorialState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentPage = null,
    Object? kindnessGiverName = null,
    Object? selectedGender = null,
    Object? selectedRelation = null,
    Object? isCompleting = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$TutorialStateImpl(
        currentPage:
            null == currentPage
                ? _value.currentPage
                : currentPage // ignore: cast_nullable_to_non_nullable
                    as int,
        kindnessGiverName:
            null == kindnessGiverName
                ? _value.kindnessGiverName
                : kindnessGiverName // ignore: cast_nullable_to_non_nullable
                    as String,
        selectedGender:
            null == selectedGender
                ? _value.selectedGender
                : selectedGender // ignore: cast_nullable_to_non_nullable
                    as String,
        selectedRelation:
            null == selectedRelation
                ? _value.selectedRelation
                : selectedRelation // ignore: cast_nullable_to_non_nullable
                    as String,
        isCompleting:
            null == isCompleting
                ? _value.isCompleting
                : isCompleting // ignore: cast_nullable_to_non_nullable
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

class _$TutorialStateImpl implements _TutorialState {
  const _$TutorialStateImpl({
    this.currentPage = 0,
    this.kindnessGiverName = '',
    this.selectedGender = '女性',
    this.selectedRelation = '家族',
    this.isCompleting = false,
    this.errorMessage,
  });

  @override
  @JsonKey()
  final int currentPage;
  @override
  @JsonKey()
  final String kindnessGiverName;
  @override
  @JsonKey()
  final String selectedGender;
  @override
  @JsonKey()
  final String selectedRelation;
  @override
  @JsonKey()
  final bool isCompleting;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'TutorialState(currentPage: $currentPage, kindnessGiverName: $kindnessGiverName, selectedGender: $selectedGender, selectedRelation: $selectedRelation, isCompleting: $isCompleting, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TutorialStateImpl &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.kindnessGiverName, kindnessGiverName) ||
                other.kindnessGiverName == kindnessGiverName) &&
            (identical(other.selectedGender, selectedGender) ||
                other.selectedGender == selectedGender) &&
            (identical(other.selectedRelation, selectedRelation) ||
                other.selectedRelation == selectedRelation) &&
            (identical(other.isCompleting, isCompleting) ||
                other.isCompleting == isCompleting) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    currentPage,
    kindnessGiverName,
    selectedGender,
    selectedRelation,
    isCompleting,
    errorMessage,
  );

  /// Create a copy of TutorialState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TutorialStateImplCopyWith<_$TutorialStateImpl> get copyWith =>
      __$$TutorialStateImplCopyWithImpl<_$TutorialStateImpl>(this, _$identity);
}

abstract class _TutorialState implements TutorialState {
  const factory _TutorialState({
    final int currentPage,
    final String kindnessGiverName,
    final String selectedGender,
    final String selectedRelation,
    final bool isCompleting,
    final String? errorMessage,
  }) = _$TutorialStateImpl;

  @override
  int get currentPage;
  @override
  String get kindnessGiverName;
  @override
  String get selectedGender;
  @override
  String get selectedRelation;
  @override
  bool get isCompleting;
  @override
  String? get errorMessage;

  /// Create a copy of TutorialState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TutorialStateImplCopyWith<_$TutorialStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
