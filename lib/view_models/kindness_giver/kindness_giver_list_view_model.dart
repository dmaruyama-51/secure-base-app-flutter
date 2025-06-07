import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/kindness_giver_repository.dart';
import '../../states/kindness_giver/kindness_giver_list_state.dart';
import '../../providers/kindness_giver/kindness_giver_providers.dart';
import '../../models/kindness_giver.dart';

/// メンバー一覧のViewModel
class KindnessGiverListViewModel extends StateNotifier<KindnessGiverListState> {
  final KindnessGiverRepository _repository;
  final Ref _ref;

  // DIパターン：コンストラクタでRepositoryを受け取る
  KindnessGiverListViewModel({
    required KindnessGiverRepository repository,
    required Ref ref,
  }) : _repository = repository,
       _ref = ref,
       super(const KindnessGiverListState());

  /// メンバー一覧を読み込む
  Future<void> loadKindnessGivers() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final kindnessGivers = await _repository.fetchKindnessGivers();
      state = state.copyWith(kindnessGivers: kindnessGivers, isLoading: false);
    } catch (e) {
      String errorMessage = 'メンバー一覧の取得に失敗しました';

      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
    }
  }

  /// 削除確認の要求
  void requestDeleteConfirmation(KindnessGiver kindnessGiver) {
    state = state.copyWith(
      kindnessGiverToDelete: kindnessGiver,
      showDeleteConfirmation: true,
    );
  }

  /// 削除確認のキャンセル
  void cancelDeleteConfirmation() {
    state = state.copyWith(
      kindnessGiverToDelete: null,
      showDeleteConfirmation: false,
    );
  }

  /// 削除の実行
  Future<void> confirmDelete() async {
    final kindnessGiver = state.kindnessGiverToDelete;
    if (kindnessGiver?.id == null) return;

    // 確認状態をクリア
    state = state.copyWith(
      kindnessGiverToDelete: null,
      showDeleteConfirmation: false,
    );

    try {
      final success = await _repository.deleteKindnessGiver(kindnessGiver!.id!);

      if (success) {
        final updatedList =
            state.kindnessGivers
                .where((giver) => giver.id != kindnessGiver.id)
                .toList();
        state = state.copyWith(
          kindnessGivers: updatedList,
          successMessage: '${kindnessGiver.name}さんを削除しました',
        );
      } else {
        state = state.copyWith(errorMessage: '削除に失敗しました');
      }
    } catch (e) {
      state = state.copyWith(errorMessage: '削除中にエラーが発生しました: $e');
    }
  }
}

// ViewModelのProvider（DIで依存関係を注入）
final kindnessGiverListViewModelProvider =
    StateNotifierProvider<KindnessGiverListViewModel, KindnessGiverListState>((
      ref,
    ) {
      // Repository Providerから依存関係を取得
      final repository = ref.read(kindnessGiverRepositoryProvider);

      return KindnessGiverListViewModel(repository: repository, ref: ref);
    });
