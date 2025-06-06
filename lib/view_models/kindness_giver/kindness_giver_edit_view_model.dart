import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/kindness_giver.dart';
import '../../repositories/kindness_giver_repository.dart';
import '../../states/kindness_giver/kindness_giver_edit_state.dart';
import '../../providers/kindness_giver/kindness_giver_providers.dart';

/// やさしさをくれる人編集のViewModel（新アーキテクチャ版）
class KindnessGiverEditViewModel extends StateNotifier<KindnessGiverEditState> {
  final KindnessGiverRepository _repository;

  // DIパターン：コンストラクタでRepositoryを受け取る
  KindnessGiverEditViewModel({
    required KindnessGiverRepository repository,
    required KindnessGiver originalKindnessGiver,
  }) : _repository = repository,
       super(
         KindnessGiverEditState(
           originalKindnessGiver: originalKindnessGiver,
           name: originalKindnessGiver.name,
           selectedGender: originalKindnessGiver.gender,
           selectedRelation: originalKindnessGiver.category,
         ),
       );

  /// 名前を更新
  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  /// 性別を選択
  void selectGender(String gender) {
    state = state.copyWith(selectedGender: gender);
  }

  /// 関係性を選択
  void selectRelation(String relation) {
    state = state.copyWith(selectedRelation: relation);
  }

  /// バリデーション
  bool _validateInput() {
    if (state.name.trim().isEmpty) {
      state = state.copyWith(errorMessage: '名前を入力してください');
      return false;
    }

    if (state.selectedRelation.isEmpty) {
      state = state.copyWith(errorMessage: '関係性を選択してください');
      return false;
    }

    state = state.copyWith(errorMessage: null);
    return true;
  }

  /// メンバー更新処理
  Future<void> updateKindnessGiver() async {
    if (!_validateInput()) return;

    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      final updatedKindnessGiver = KindnessGiver(
        id: state.originalKindnessGiver?.id,
        name: state.name.trim(),
        gender: state.selectedGender,
        category: state.selectedRelation,
        avatarUrl: state.originalKindnessGiver?.avatarUrl,
      );

      final result = await _repository.updateKindnessGiver(
        updatedKindnessGiver,
      );

      if (result) {
        state = state.copyWith(
          isSaving: false,
          successMessage: 'メンバー情報を更新しました',
          shouldNavigateBack: true,
        );
      } else {
        state = state.copyWith(isSaving: false, errorMessage: '更新に失敗しました');
      }
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'エラーが発生しました: ${e.toString()}',
      );
    }
  }

  /// メッセージをクリア
  void clearMessages() {
    state = state.copyWith(
      errorMessage: null,
      successMessage: null,
      shouldNavigateBack: false,
    );
  }
}

// ViewModelのProvider（DIで依存関係を注入）
final kindnessGiverEditViewModelProvider = StateNotifierProvider.family<
  KindnessGiverEditViewModel,
  KindnessGiverEditState,
  KindnessGiver
>((ref, originalKindnessGiver) {
  final repository = ref.read(kindnessGiverRepositoryProvider);
  return KindnessGiverEditViewModel(
    repository: repository,
    originalKindnessGiver: originalKindnessGiver,
  );
});
