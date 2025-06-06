import 'package:freezed_annotation/freezed_annotation.dart';

part 'kindness_giver_add_state.freezed.dart';

/// やさしさをくれる人追加ページの状態クラス
@freezed
class KindnessGiverAddState with _$KindnessGiverAddState {
  const factory KindnessGiverAddState({
    @Default('') String name,
    @Default('女性') String selectedGender,
    @Default('家族') String selectedRelation,
    @Default(false) bool isSaving,
    String? errorMessage,
    String? successMessage,
    @Default(false) bool shouldNavigateBack,
  }) = _KindnessGiverAddState;
}
