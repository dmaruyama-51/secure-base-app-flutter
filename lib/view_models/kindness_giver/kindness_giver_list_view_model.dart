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

  /// アーカイブセクションが展開されているかどうか
  bool _isArchiveSectionExpanded = false;

  // コールバック管理
  VoidCallback? _onRefreshCallback;

  // ゲッター
  List<KindnessGiver> get kindnessGivers => _kindnessGivers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isArchiveSectionExpanded => _isArchiveSectionExpanded;

  /// リフレッシュコールバックを設定
  void setRefreshCallback(VoidCallback? callback) {
    _onRefreshCallback = callback;
  }

  /// コールバック経由でリフレッシュを実行
  void triggerRefresh() {
    _onRefreshCallback?.call();
  }

  /// メンバー一覧を読み込む（全メンバー：アクティブ+アーカイブ）
  Future<void> loadKindnessGivers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _kindnessGivers = await KindnessGiver.fetchAllKindnessGivers();
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

  /// 統計情報を含む完全なリフレッシュを実行
  /// 統計情報は各カードで個別に読み込まれるため、
  /// ここではメンバー一覧のみを更新する
  Future<void> refreshWithStatistics() async {
    await refreshKindnessGivers();
    // 統計情報は KindnessGiverStatisticsChip で個別に更新される
  }

  /// メンバーをアクティブとアーカイブでグループ分けする
  Map<String, List<KindnessGiver>> getGroupedMembers() {
    final grouped = <String, List<KindnessGiver>>{};

    final activeMembers =
        _kindnessGivers.where((member) => !member.isArchived).toList();
    final archivedMembers =
        _kindnessGivers.where((member) => member.isArchived).toList();

    if (activeMembers.isNotEmpty) {
      grouped['アクティブ'] = activeMembers;
    }

    if (archivedMembers.isNotEmpty) {
      grouped['アーカイブ'] = archivedMembers;
    }

    return grouped;
  }

  /// アーカイブセクションの展開状態をトグルする
  void toggleArchiveSectionExpanded() {
    _isArchiveSectionExpanded = !_isArchiveSectionExpanded;
    notifyListeners();
  }
}
