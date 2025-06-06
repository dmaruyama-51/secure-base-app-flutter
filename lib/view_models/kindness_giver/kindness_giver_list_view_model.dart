import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
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

  /// メンバー編集画面へのナビゲーション
  void navigateToEdit(BuildContext context, KindnessGiver kindnessGiver) {
    GoRouter.of(context).push(
      '/kindness-givers/edit/${kindnessGiver.giverName}',
      extra: kindnessGiver,
    );
  }

  /// メンバー追加画面へのナビゲーション
  void navigateToAdd(BuildContext context) {
    GoRouter.of(context).push('/kindness-givers/add');
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
