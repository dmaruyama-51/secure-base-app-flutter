import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/kindness_record_repository.dart';
import '../../states/kindness_record/kindness_record_list_state.dart';
import '../../providers/kindness_record/kindness_record_providers.dart';

// StateNotifierベースのKindnessRecordListViewModel
class KindnessRecordListViewModel extends StateNotifier<KindnessRecordListState> {
  final KindnessRecordRepository _kindnessRecordRepository;

  // DIパターン：コンストラクタでRepositoryを受け取る
  KindnessRecordListViewModel({
    required KindnessRecordRepository kindnessRecordRepository,
  })  : _kindnessRecordRepository = kindnessRecordRepository,
        super(const KindnessRecordListState());

  // やさしさ記録一覧を取得する
  Future<void> loadKindnessRecords() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final records = await _kindnessRecordRepository.fetchKindnessRecords();
      state = state.copyWith(
        kindnessRecords: records,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'データの取得に失敗しました',
      );
    }
  }
}

// ViewModelのProvider（DIで依存関係を注入）
final kindnessRecordListViewModelProvider = 
    StateNotifierProvider<KindnessRecordListViewModel, KindnessRecordListState>(
  (ref) {
    // Repository Providerから依存関係を取得
    final kindnessRecordRepository = ref.read(kindnessRecordRepositoryProvider);
    
    return KindnessRecordListViewModel(
      kindnessRecordRepository: kindnessRecordRepository,
    );
  },
); 