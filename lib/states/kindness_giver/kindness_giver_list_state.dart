import 'package:freezed_annotation/freezed_annotation.dart';
import '../../models/kindness_giver.dart';

part 'kindness_giver_list_state.freezed.dart';

/// やさしさをくれる人一覧ページの状態クラス
@freezed
class KindnessGiverListState with _$KindnessGiverListState {
  const factory KindnessGiverListState({
    @Default([]) List<KindnessGiver> kindnessGivers,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _KindnessGiverListState;
}
