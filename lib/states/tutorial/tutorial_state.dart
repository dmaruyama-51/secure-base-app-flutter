import 'package:freezed_annotation/freezed_annotation.dart';

part 'tutorial_state.freezed.dart';

@freezed
class TutorialState with _$TutorialState {
  const factory TutorialState({
    @Default(0) int currentPage,
    @Default('') String kindnessGiverName,
    @Default('女性') String selectedGender,
    @Default('家族') String selectedRelation,
    @Default('') String kindnessContent,
    @Default('2週に1回') String selectedReflectionFrequency,
    @Default(false) bool isCompleting,
    @Default(false) bool isRecordingKindness,
    @Default(false) bool isSettingReflection,
    String? errorMessage,
  }) = _TutorialState;
}
