// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../models/kindness_giver.dart';

/// メンバー一覧のViewModel
class KindnessGiverListViewModel extends ChangeNotifier {
  // 状態プロパティ
  List<KindnessGiver> _kindnessGivers = const [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  bool _showDeleteConfirmation = false;
  KindnessGiver? _kindnessGiverToDelete;

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
      _kindnessGivers = await KindnessGiver.fetchKindnessGivers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
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
      await KindnessGiver.deleteKindnessGiver(kindnessGiver!.id!);

      // リストから削除
      _kindnessGivers =
          _kindnessGivers
              .where((giver) => giver.id != kindnessGiver.id)
              .toList();
      _successMessage = '${kindnessGiver.name}さんを削除しました';
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
