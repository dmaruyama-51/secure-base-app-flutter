import 'package:flutter/foundation.dart';
import '../../repositories/kindness_giver_repository.dart';
import '../../states/kindness_giver/kindness_giver_add_state.dart';
import '../../models/kindness_giver.dart';

/// メンバー追加のViewModel（Provider対応版）
class KindnessGiverAddViewModel extends ChangeNotifier {
  final KindnessGiverRepository _repository;
  KindnessGiverAddState _state = const KindnessGiverAddState();

  KindnessGiverAddViewModel() : _repository = KindnessGiverRepository();

  KindnessGiverAddState get state => _state;

  void _updateState(KindnessGiverAddState newState) {
    _state = newState;
    notifyListeners();
  }

  /// 名前を更新
  void updateName(String name) {
    _updateState(_state.copyWith(name: name));
  }

  /// 性別を選択
  void selectGender(String gender) {
    _updateState(_state.copyWith(selectedGender: gender));
  }

  /// 関係性を選択
  void selectRelation(String relation) {
    _updateState(_state.copyWith(selectedRelation: relation));
  }

  /// 入力バリデーション
  bool _validateInput() {
    if (_state.name.trim().isEmpty) {
      _updateState(_state.copyWith(errorMessage: '名前を入力してください'));
      return false;
    }
    if (_state.selectedGender.isEmpty) {
      _updateState(_state.copyWith(errorMessage: '性別を選択してください'));
      return false;
    }
    if (_state.selectedRelation.isEmpty) {
      _updateState(_state.copyWith(errorMessage: '関係性を選択してください'));
      return false;
    }
    return true;
  }

  /// やさしさをくれる人を保存
  Future<void> saveKindnessGiver() async {
    if (!_validateInput()) return;

    _updateState(_state.copyWith(isSaving: true, errorMessage: null));

    try {
      // マスターデータからIDを取得
      final genderId = await _repository.getGenderIdByName(
        _state.selectedGender,
      );
      final relationshipId = await _repository.getRelationshipIdByName(
        _state.selectedRelation,
      );

      if (genderId == null) {
        _updateState(
          _state.copyWith(isSaving: false, errorMessage: '選択された性別が見つかりません'),
        );
        return;
      }

      if (relationshipId == null) {
        _updateState(
          _state.copyWith(isSaving: false, errorMessage: '選択された関係性が見つかりません'),
        );
        return;
      }

      final kindnessGiver = KindnessGiver.create(
        userId: '', // Repository内で現在のユーザーIDを設定
        giverName: _state.name.trim(),
        relationshipId: relationshipId,
        genderId: genderId,
      );

      final createdGiver = await _repository.createKindnessGiver(kindnessGiver);

      if (createdGiver.id != null) {
        _updateState(
          _state.copyWith(
            isSaving: false,
            successMessage: 'メンバーを保存しました',
            shouldNavigateBack: true,
          ),
        );
      } else {
        _updateState(
          _state.copyWith(isSaving: false, errorMessage: '保存に失敗しました'),
        );
      }
    } catch (e) {
      _updateState(
        _state.copyWith(
          isSaving: false,
          errorMessage: 'エラーが発生しました: ${e.toString()}',
        ),
      );
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
}
