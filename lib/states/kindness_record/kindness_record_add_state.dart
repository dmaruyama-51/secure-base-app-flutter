import 'package:freezed_annotation/freezed_annotation.dart';
import '../../models/kindness_giver.dart';

part 'kindness_record_add_state.freezed.dart';

/// やさしさ記録追加ページの状態クラス
@freezed
class KindnessRecordAddState with _$KindnessRecordAddState {
  const factory KindnessRecordAddState({
    @Default([]) List<KindnessGiver> kindnessGivers,
    @Default('') String content,
    KindnessGiver? selectedKindnessGiver,
    @Default(false) bool isLoading,
    @Default(false) bool isSaving,
    String? errorMessage,
    String? successMessage,
    @Default(false) bool shouldNavigateBack,
  }) = _KindnessRecordAddState;
} 