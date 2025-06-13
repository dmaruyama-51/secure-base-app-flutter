import 'package:flutter/foundation.dart';
import '../../repositories/kindness_record_repository.dart';
import '../../states/kindness_record/kindness_record_list_state.dart';

/// やさしさ記録一覧のViewModel
class KindnessRecordListViewModel extends ChangeNotifier {
  final KindnessRecordRepository _kindnessRecordRepository;
  KindnessRecordListState _state = const KindnessRecordListState();

  KindnessRecordListViewModel()
    : _kindnessRecordRepository = KindnessRecordRepository();

  KindnessRecordListState get state => _state;

  void _updateState(KindnessRecordListState newState) {
    _state = newState;
    notifyListeners();
  }

  /// やさしさ記録一覧を取得する
  Future<void> loadKindnessRecords() async {
    _updateState(_state.copyWith(isLoading: true, errorMessage: null));

    try {
      final records = await _kindnessRecordRepository.fetchKindnessRecords();
      _updateState(_state.copyWith(kindnessRecords: records, isLoading: false));
    } catch (e) {
      _updateState(
        _state.copyWith(isLoading: false, errorMessage: 'データの取得に失敗しました'),
      );
    }
  }

  /// エラーメッセージをクリアする
  void clearMessages() {
    _updateState(_state.copyWith(errorMessage: null));
  }
}
