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
  bool _showArchivedOnly = false;

  // コールバック管理
  VoidCallback? _onRefreshCallback;

  // ゲッター
  List<KindnessGiver> get kindnessGivers => _kindnessGivers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get showArchivedOnly => _showArchivedOnly;

  /// アーカイブ表示の切り替え
  void toggleShowArchived() {
    _showArchivedOnly = !_showArchivedOnly;
    notifyListeners();
    loadKindnessGivers();
  }

  /// アクティブメンバーのみ表示に切り替え
  void showActiveOnly() {
    if (_showArchivedOnly) {
      _showArchivedOnly = false;
      notifyListeners();
      loadKindnessGivers();
    }
  }

  /// アーカイブメンバーのみ表示に切り替え
  void setShowArchivedOnly() {
    if (!_showArchivedOnly) {
      _showArchivedOnly = true;
      notifyListeners();
      loadKindnessGivers();
    }
  }

  /// リフレッシュコールバックを設定
  void setRefreshCallback(VoidCallback? callback) {
    _onRefreshCallback = callback;
  }

  /// コールバック経由でリフレッシュを実行
  void triggerRefresh() {
    _onRefreshCallback?.call();
  }

  /// メンバー一覧を読み込む
  Future<void> loadKindnessGivers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_showArchivedOnly) {
        _kindnessGivers = await KindnessGiver.fetchArchivedKindnessGivers();
      } else {
        _kindnessGivers = await KindnessGiver.fetchActiveKindnessGivers();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// リストを再読み込みする
  Future<void> refreshKindnessGivers() async {
    await loadKindnessGivers();
  }
}
