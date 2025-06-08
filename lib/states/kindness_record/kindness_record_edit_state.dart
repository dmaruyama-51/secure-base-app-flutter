import 'package:freezed_annotation/freezed_annotation.dart';
import '../../models/kindness_giver.dart';
import '../../models/kindness_record.dart';

part 'kindness_record_edit_state.freezed.dart';

/// やさしさ記録編集ページの状態クラス
@freezed
class KindnessRecordEditState with _$KindnessRecordEditState {
  const factory KindnessRecordEditState({
    @Default([]) List<KindnessGiver> kindnessGivers,
    @Default('') String content,
    KindnessGiver? selectedKindnessGiver,
    KindnessRecord? originalRecord,
    @Default(false) bool isLoading,
    @Default(false) bool isSaving,
    String? errorMessage,
    String? successMessage,
    @Default(false) bool shouldNavigateBack,
  }) = _KindnessRecordEditState;
} 