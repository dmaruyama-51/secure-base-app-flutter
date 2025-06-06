import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/kindness_giver_repository.dart';
import '../../states/kindness_giver/kindness_giver_add_state.dart';
import '../../providers/kindness_giver/kindness_giver_providers.dart';
import '../../models/kindness_giver.dart';

/// やさしさをくれる人追加のViewModel（新アーキテクチャ版）
class KindnessGiverAddViewModel extends StateNotifier<KindnessGiverAddState> {
  final KindnessGiverRepository _repository;

  // DIパターン：コンストラクタでRepositoryを受け取る
  KindnessGiverAddViewModel({required KindnessGiverRepository repository})
    : _repository = repository,
      super(const KindnessGiverAddState());

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

  /// 入力バリデーション
  bool _validateInput() {
    if (state.name.trim().isEmpty) {
      state = state.copyWith(errorMessage: '名前を入力してください');
      return false;
    }
    if (state.selectedGender.isEmpty) {
      state = state.copyWith(errorMessage: '性別を選択してください');
      return false;
    }
    if (state.selectedRelation.isEmpty) {
      state = state.copyWith(errorMessage: '関係性を選択してください');
      return false;
    }
    return true;
  }

  /// メンバーを保存
  Future<void> saveKindnessGiver() async {
    if (!_validateInput()) return;

    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      // マスターデータからIDを取得
      final genderId = await _repository.getGenderIdByName(
        state.selectedGender,
      );
      final relationshipId = await _repository.getRelationshipIdByName(
        state.selectedRelation,
      );

      if (genderId == null) {
        state = state.copyWith(
          isSaving: false,
          errorMessage: '選択された性別が見つかりません',
        );
        return;
      }

      if (relationshipId == null) {
        state = state.copyWith(
          isSaving: false,
          errorMessage: '選択された関係性が見つかりません',
        );
        return;
      }

      final kindnessGiver = KindnessGiver.create(
        userId: '', // Repository内で現在のユーザーIDを設定
        giverName: state.name.trim(),
        relationshipId: relationshipId,
        genderId: genderId,
      );

      final createdGiver = await _repository.createKindnessGiver(kindnessGiver);

      if (createdGiver.id != null) {
        state = state.copyWith(
          isSaving: false,
          successMessage: 'メンバーを保存しました',
          shouldNavigateBack: true,
        );
      } else {
        state = state.copyWith(isSaving: false, errorMessage: '保存に失敗しました');
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
final kindnessGiverAddViewModelProvider =
    StateNotifierProvider<KindnessGiverAddViewModel, KindnessGiverAddState>((
      ref,
    ) {
      final repository = ref.read(kindnessGiverRepositoryProvider);
      return KindnessGiverAddViewModel(repository: repository);
    });
