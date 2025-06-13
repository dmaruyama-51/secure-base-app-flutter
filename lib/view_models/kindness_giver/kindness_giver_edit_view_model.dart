import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/kindness_giver.dart';
import '../../repositories/kindness_giver_repository.dart';
import '../../states/kindness_giver/kindness_giver_edit_state.dart';

/// やさしさをくれる人編集のViewModel（新アーキテクチャ版）
class KindnessGiverEditViewModel extends StateNotifier<KindnessGiverEditState> {
  final KindnessGiverRepository _repository;

  KindnessGiverEditViewModel({required KindnessGiver originalKindnessGiver})
    : _repository = KindnessGiverRepository(),
      super(
        KindnessGiverEditState(
          originalKindnessGiver: originalKindnessGiver,
          name: originalKindnessGiver.giverName,
          selectedGender: originalKindnessGiver.genderName ?? '女性',
          selectedRelation: originalKindnessGiver.relationshipName ?? '家族',
        ),
      );

  /// 名前を更新
  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  /// 性別選択時の処理
  Future<void> selectGender(String gender) async {
    final genderId = await _repository.getGenderIdByName(gender);
    state = state.copyWith(selectedGender: gender, selectedGenderId: genderId);
  }

  /// 関係性選択時の処理
  Future<void> selectRelation(String relation) async {
    final relationshipId = await _repository.getRelationshipIdByName(relation);
    state = state.copyWith(
      selectedRelation: relation,
      selectedRelationshipId: relationshipId,
    );
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

    // IDが取得できていない場合は再取得
    if (state.selectedGenderId == null ||
        state.selectedRelationshipId == null) {
      await _ensureIdsAreLoaded();
    }

    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      final updatedKindnessGiver = state.originalKindnessGiver!.copyWith(
        giverName: state.name.trim(),
        genderId: state.selectedGenderId!,
        relationshipId: state.selectedRelationshipId!,
      );

      await _repository.updateKindnessGiver(updatedKindnessGiver);
      state = state.copyWith(
        isSaving: false,
        successMessage: 'メンバーが更新されました',
        shouldNavigateBack: true,
      );
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'メンバーの更新に失敗しました: $e',
      );
    }
  }

  /// IDが読み込まれていることを確認
  Future<void> _ensureIdsAreLoaded() async {
    if (state.selectedGenderId == null) {
      final genderId = await _repository.getGenderIdByName(
        state.selectedGender,
      );
      state = state.copyWith(selectedGenderId: genderId);
    }
    if (state.selectedRelationshipId == null) {
      final relationshipId = await _repository.getRelationshipIdByName(
        state.selectedRelation,
      );
      state = state.copyWith(selectedRelationshipId: relationshipId);
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

  Future<void> initializeWithKindnessGiver(
    KindnessGiver originalKindnessGiver,
  ) async {
    state = state.copyWith(
      originalKindnessGiver: originalKindnessGiver,
      name: originalKindnessGiver.giverName,
      selectedGender: originalKindnessGiver.genderName ?? '女性',
      selectedRelation: originalKindnessGiver.relationshipName ?? '家族',
    );
  }
}

final kindnessGiverEditViewModelProvider = StateNotifierProvider.family<
  KindnessGiverEditViewModel,
  KindnessGiverEditState,
  KindnessGiver
>((ref, originalKindnessGiver) {
  return KindnessGiverEditViewModel(
    originalKindnessGiver: originalKindnessGiver,
  );
});
