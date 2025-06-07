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
    @Default(false) bool isCompleting,
    @Default(false) bool isRecordingKindness,
    String? errorMessage,
  }) = _TutorialState;
}
