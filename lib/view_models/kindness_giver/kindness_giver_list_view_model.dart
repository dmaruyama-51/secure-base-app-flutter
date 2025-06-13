import 'package:flutter/foundation.dart';
import '../../repositories/kindness_giver_repository.dart';
import '../../states/kindness_giver/kindness_giver_list_state.dart';
import '../../models/kindness_giver.dart';

/// メンバー一覧のViewModel
class KindnessGiverListViewModel extends ChangeNotifier {
  final KindnessGiverRepository _repository;
  KindnessGiverListState _state = const KindnessGiverListState();

  KindnessGiverListViewModel() : _repository = KindnessGiverRepository();

  KindnessGiverListState get state => _state;

  void _updateState(KindnessGiverListState newState) {
    _state = newState;
    notifyListeners();
  }

  /// メンバー一覧を読み込む
  Future<void> loadKindnessGivers() async {
    _updateState(_state.copyWith(isLoading: true, errorMessage: null));

    try {
      final kindnessGivers = await _repository.fetchKindnessGivers();
      _updateState(
        _state.copyWith(kindnessGivers: kindnessGivers, isLoading: false),
      );
    } catch (e) {
      String errorMessage = 'メンバー一覧の取得に失敗しました';
      _updateState(
        _state.copyWith(isLoading: false, errorMessage: errorMessage),
      );
    }
  }

  /// 削除確認の要求
  void requestDeleteConfirmation(KindnessGiver kindnessGiver) {
    _updateState(
      _state.copyWith(
        kindnessGiverToDelete: kindnessGiver,
        showDeleteConfirmation: true,
      ),
    );
  }

  /// 削除確認のキャンセル
  void cancelDeleteConfirmation() {
    _updateState(
      _state.copyWith(
        kindnessGiverToDelete: null,
        showDeleteConfirmation: false,
      ),
    );
  }

  /// 削除の実行
  Future<void> confirmDelete() async {
    final kindnessGiver = _state.kindnessGiverToDelete;
    if (kindnessGiver?.id == null) return;

    // 確認状態をクリア
    _updateState(
      _state.copyWith(
        kindnessGiverToDelete: null,
        showDeleteConfirmation: false,
      ),
    );

    try {
      final success = await _repository.deleteKindnessGiver(kindnessGiver!.id!);

      if (success) {
        final updatedList =
            _state.kindnessGivers
                .where((giver) => giver.id != kindnessGiver.id)
                .toList();
        _updateState(
          _state.copyWith(
            kindnessGivers: updatedList,
            successMessage: '${kindnessGiver.name}さんを削除しました',
          ),
        );
      } else {
        _updateState(_state.copyWith(errorMessage: '削除に失敗しました'));
      }
    } catch (e) {
      _updateState(_state.copyWith(errorMessage: '削除中にエラーが発生しました: $e'));
    }
  }
}
