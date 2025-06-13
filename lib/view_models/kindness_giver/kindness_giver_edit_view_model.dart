import 'package:flutter/foundation.dart';
import '../../models/kindness_giver.dart';
import '../../repositories/kindness_giver_repository.dart';
import '../../states/kindness_giver/kindness_giver_edit_state.dart';

/// メンバー編集のViewModel
class KindnessGiverEditViewModel extends ChangeNotifier {
  final KindnessGiverRepository _repository;
  KindnessGiverEditState _state;

  KindnessGiverEditViewModel({required KindnessGiver originalKindnessGiver})
    : _repository = KindnessGiverRepository(),
      _state = KindnessGiverEditState(
        originalKindnessGiver: originalKindnessGiver,
        name: originalKindnessGiver.giverName,
        selectedGender: originalKindnessGiver.genderName ?? '女性',
        selectedRelation: originalKindnessGiver.relationshipName ?? '家族',
      );

  KindnessGiverEditState get state => _state;

  void _updateState(KindnessGiverEditState newState) {
    _state = newState;
    notifyListeners();
  }

  /// 名前を更新
  void updateName(String name) {
    _updateState(_state.copyWith(name: name));
  }

  /// 性別選択時の処理
  Future<void> selectGender(String gender) async {
    final genderId = await _repository.getGenderIdByName(gender);
    _updateState(
      _state.copyWith(selectedGender: gender, selectedGenderId: genderId),
    );
  }

  /// 関係性選択時の処理
  Future<void> selectRelation(String relation) async {
    final relationshipId = await _repository.getRelationshipIdByName(relation);
    _updateState(
      _state.copyWith(
        selectedRelation: relation,
        selectedRelationshipId: relationshipId,
      ),
    );
  }

  /// バリデーション
  bool _validateInput() {
    if (_state.name.trim().isEmpty) {
      _updateState(_state.copyWith(errorMessage: '名前を入力してください'));
      return false;
    }

    if (_state.selectedRelation.isEmpty) {
      _updateState(_state.copyWith(errorMessage: '関係性を選択してください'));
      return false;
    }

    _updateState(_state.copyWith(errorMessage: null));
    return true;
  }

  /// やさしさをくれる人更新処理
  Future<void> updateKindnessGiver() async {
    if (!_validateInput()) return;

    // IDが取得できていない場合は再取得
    if (_state.selectedGenderId == null ||
        _state.selectedRelationshipId == null) {
      await _ensureIdsAreLoaded();
    }

    _updateState(_state.copyWith(isSaving: true, errorMessage: null));

    try {
      final updatedKindnessGiver = _state.originalKindnessGiver!.copyWith(
        giverName: _state.name.trim(),
        genderId: _state.selectedGenderId!,
        relationshipId: _state.selectedRelationshipId!,
      );

      await _repository.updateKindnessGiver(updatedKindnessGiver);
      _updateState(
        _state.copyWith(
          isSaving: false,
          successMessage: 'メンバーが更新されました',
          shouldNavigateBack: true,
        ),
      );
    } catch (e) {
      _updateState(
        _state.copyWith(isSaving: false, errorMessage: 'メンバーの更新に失敗しました: $e'),
      );
    }
  }

  /// IDが読み込まれていることを確認
  Future<void> _ensureIdsAreLoaded() async {
    if (_state.selectedGenderId == null) {
      final genderId = await _repository.getGenderIdByName(
        _state.selectedGender,
      );
      _updateState(_state.copyWith(selectedGenderId: genderId));
    }
    if (_state.selectedRelationshipId == null) {
      final relationshipId = await _repository.getRelationshipIdByName(
        _state.selectedRelation,
      );
      _updateState(_state.copyWith(selectedRelationshipId: relationshipId));
    }
  }

  /// メッセージをクリア
  void clearMessages() {
    _updateState(
      _state.copyWith(
        errorMessage: null,
        successMessage: null,
        shouldNavigateBack: false,
      ),
    );
  }

  Future<void> initializeWithKindnessGiver(
    KindnessGiver originalKindnessGiver,
  ) async {
    _updateState(
      _state.copyWith(
        originalKindnessGiver: originalKindnessGiver,
        name: originalKindnessGiver.giverName,
        selectedGender: originalKindnessGiver.genderName ?? '女性',
        selectedRelation: originalKindnessGiver.relationshipName ?? '家族',
      ),
    );
  }
}
