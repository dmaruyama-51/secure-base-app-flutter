import 'package:freezed_annotation/freezed_annotation.dart';
import '../../models/kindness_giver.dart';

part 'kindness_giver_edit_state.freezed.dart';

/// やさしさをくれる人編集ページの状態クラス
@freezed
class KindnessGiverEditState with _$KindnessGiverEditState {
  const factory KindnessGiverEditState({
    KindnessGiver? originalKindnessGiver,
    @Default('') String name,
    @Default('女性') String selectedGender,
    @Default('家族') String selectedRelation,
    @Default(false) bool isSaving,
    String? errorMessage,
    String? successMessage,
    @Default(false) bool shouldNavigateBack,
  }) = _KindnessGiverEditState;
}
