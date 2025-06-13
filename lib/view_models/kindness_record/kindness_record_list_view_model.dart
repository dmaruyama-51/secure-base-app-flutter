import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/kindness_record_repository.dart';
import '../../states/kindness_record/kindness_record_list_state.dart';

// StateNotifierベースのKindnessRecordListViewModel
class KindnessRecordListViewModel
    extends StateNotifier<KindnessRecordListState> {
  final KindnessRecordRepository _kindnessRecordRepository;

  // コンストラクタを修正してRepositoryを直接インスタンス化
  KindnessRecordListViewModel()
    : _kindnessRecordRepository = KindnessRecordRepository(),
      super(const KindnessRecordListState());

  // やさしさ記録一覧を取得する
  Future<void> loadKindnessRecords() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final records = await _kindnessRecordRepository.fetchKindnessRecords();
      state = state.copyWith(kindnessRecords: records, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'データの取得に失敗しました');
    }
  }
}

// ViewModelプロバイダーを簡素化
final kindnessRecordListViewModelProvider =
    StateNotifierProvider<KindnessRecordListViewModel, KindnessRecordListState>(
      (ref) {
        return KindnessRecordListViewModel();
      },
    );
