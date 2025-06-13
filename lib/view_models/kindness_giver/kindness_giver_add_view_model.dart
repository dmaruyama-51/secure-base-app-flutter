// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../models/kindness_giver.dart';
import '../../repositories/kindness_giver_repository.dart';

/// メンバー追加のViewModel（Provider対応版）
class KindnessGiverAddViewModel extends ChangeNotifier {
  final KindnessGiverRepository _repository;

  // 状態プロパティ
  String _name = '';
  String _selectedGender = '女性';
  String _selectedRelation = '家族';
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;
  bool _shouldNavigateBack = false;

  KindnessGiverAddViewModel() : _repository = KindnessGiverRepository();

  // ゲッター
  String get name => _name;
  String get selectedGender => _selectedGender;
  String get selectedRelation => _selectedRelation;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get shouldNavigateBack => _shouldNavigateBack;

  /// 名前を更新
  void updateName(String name) {
    _name = name;
    notifyListeners();
  }

  /// 性別を選択
  void selectGender(String gender) {
    _selectedGender = gender;
    notifyListeners();
  }

  /// 関係性を選択
  void selectRelation(String relation) {
    _selectedRelation = relation;
    notifyListeners();
  }

  /// 入力バリデーション
  bool _validateInput() {
    if (_name.trim().isEmpty) {
      _errorMessage = '名前を入力してください';
      notifyListeners();
      return false;
    }
    if (_selectedGender.isEmpty) {
      _errorMessage = '性別を選択してください';
      notifyListeners();
      return false;
    }
    if (_selectedRelation.isEmpty) {
      _errorMessage = '関係性を選択してください';
      notifyListeners();
      return false;
    }
    return true;
  }

  /// やさしさをくれる人を保存
  Future<void> saveKindnessGiver() async {
    if (!_validateInput()) return;

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // マスターデータからIDを取得
      final genderId = await _repository.getGenderIdByName(_selectedGender);
      final relationshipId = await _repository.getRelationshipIdByName(
        _selectedRelation,
      );

      if (genderId == null) {
        _isSaving = false;
        _errorMessage = '選択された性別が見つかりません';
        notifyListeners();
        return;
      }

      if (relationshipId == null) {
        _isSaving = false;
        _errorMessage = '選択された関係性が見つかりません';
        notifyListeners();
        return;
      }

      final kindnessGiver = KindnessGiver.create(
        userId: '', // Repository内で現在のユーザーIDを設定
        giverName: _name.trim(),
        relationshipId: relationshipId,
        genderId: genderId,
      );

      final createdGiver = await _repository.createKindnessGiver(kindnessGiver);

      if (createdGiver.id != null) {
        _isSaving = false;
        _successMessage = 'メンバーを保存しました';
        _shouldNavigateBack = true;
        notifyListeners();
      } else {
        _isSaving = false;
        _errorMessage = '保存に失敗しました';
        notifyListeners();
      }
    } catch (e) {
      _isSaving = false;
      _errorMessage = 'エラーが発生しました: ${e.toString()}';
      notifyListeners();
    }
  }

  /// メッセージをクリア
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    _shouldNavigateBack = false;
    notifyListeners();
  }
}
