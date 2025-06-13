import 'package:flutter/foundation.dart';
import '../../repositories/kindness_giver_repository.dart';
import '../../models/kindness_giver.dart';

/// メンバー一覧のViewModel
class KindnessGiverListViewModel extends ChangeNotifier {
  final KindnessGiverRepository _repository;

  // 状態プロパティ
  List<KindnessGiver> _kindnessGivers = const [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  bool _showDeleteConfirmation = false;
  KindnessGiver? _kindnessGiverToDelete;

  KindnessGiverListViewModel() : _repository = KindnessGiverRepository();

  // ゲッター
  List<KindnessGiver> get kindnessGivers => _kindnessGivers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get showDeleteConfirmation => _showDeleteConfirmation;
  KindnessGiver? get kindnessGiverToDelete => _kindnessGiverToDelete;

  /// メンバー一覧を読み込む
  Future<void> loadKindnessGivers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _kindnessGivers = await _repository.fetchKindnessGivers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'メンバー一覧の取得に失敗しました';
      notifyListeners();
    }
  }

  /// 削除確認の要求
  void requestDeleteConfirmation(KindnessGiver kindnessGiver) {
    _kindnessGiverToDelete = kindnessGiver;
    _showDeleteConfirmation = true;
    notifyListeners();
  }

  /// 削除確認のキャンセル
  void cancelDeleteConfirmation() {
    _kindnessGiverToDelete = null;
    _showDeleteConfirmation = false;
    notifyListeners();
  }

  /// 削除の実行
  Future<void> confirmDelete() async {
    final kindnessGiver = _kindnessGiverToDelete;
    if (kindnessGiver?.id == null) return;

    // 確認状態をクリア
    _kindnessGiverToDelete = null;
    _showDeleteConfirmation = false;
    notifyListeners();

    try {
      final success = await _repository.deleteKindnessGiver(kindnessGiver!.id!);

      if (success) {
        _kindnessGivers =
            _kindnessGivers
                .where((giver) => giver.id != kindnessGiver.id)
                .toList();
        _successMessage = '${kindnessGiver.name}さんを削除しました';
        notifyListeners();
      } else {
        _errorMessage = '削除に失敗しました';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = '削除中にエラーが発生しました: $e';
      notifyListeners();
    }
  }
}
