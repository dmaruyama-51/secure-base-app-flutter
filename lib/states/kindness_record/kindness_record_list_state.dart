import 'package:freezed_annotation/freezed_annotation.dart';
import '../../models/kindness_record.dart';

part 'kindness_record_list_state.freezed.dart';

/// やさしさ記録一覧ページの状態クラス
@freezed
class KindnessRecordListState with _$KindnessRecordListState {
  const factory KindnessRecordListState({
    @Default([]) List<KindnessRecord> kindnessRecords,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _KindnessRecordListState;
} 