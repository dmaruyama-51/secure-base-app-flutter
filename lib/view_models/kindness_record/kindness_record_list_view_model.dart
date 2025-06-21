// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../models/kindness_record_model.dart';

/// やさしさ記録一覧のViewModel
class KindnessRecordListViewModel extends ChangeNotifier {
  // 状態プロパティ
  List<KindnessRecord> _kindnessRecords = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // キャッシュ機能
  DateTime? _lastLoadTime;
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  // ページネーション
  static const int _pageSize = 50;
  bool _hasMoreData = true;
  int _currentOffset = 0;

  // ゲッター
  List<KindnessRecord> get kindnessRecords => _kindnessRecords;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get hasMoreData => _hasMoreData;

  /// やさしさ記録一覧を読み込む（キャッシュ機能付き）
  Future<void> loadKindnessRecords({bool forceRefresh = false}) async {
    // 強制リフレッシュの場合はキャッシュを無効化
    if (forceRefresh) {
      _invalidateCache();
    }

    // キャッシュが有効な場合は再取得をスキップ
    if (!forceRefresh && _isCacheValid()) {
      return;
    }

    // 強制リフレッシュの場合はページネーションをリセット
    if (forceRefresh) {
      _currentOffset = 0;
      _hasMoreData = true;
      _kindnessRecords = [];
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newRecords = await KindnessRecord.fetchKindnessRecords(
        limit: _pageSize,
        offset: _currentOffset,
      );

      if (forceRefresh) {
        _kindnessRecords = newRecords;
      } else {
        _kindnessRecords.addAll(newRecords);
      }

      // 作成日時で降順ソート
      _kindnessRecords.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // データが少ない場合は追加データなしとみなす
      _hasMoreData = newRecords.length >= _pageSize;
      _currentOffset += newRecords.length;

      _lastLoadTime = DateTime.now();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// 追加データを読み込む（無限スクロール用）
  Future<void> loadMoreKindnessRecords() async {
    if (_isLoading || !_hasMoreData) return;

    _isLoading = true;
    notifyListeners();

    try {
      final newRecords = await KindnessRecord.fetchKindnessRecords(
        limit: _pageSize,
        offset: _currentOffset,
      );

      _kindnessRecords.addAll(newRecords);
      _hasMoreData = newRecords.length >= _pageSize;
      _currentOffset += newRecords.length;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// キャッシュが有効かどうかを確認
  bool _isCacheValid() {
    if (_lastLoadTime == null || _kindnessRecords.isEmpty) return false;
    return DateTime.now().difference(_lastLoadTime!) < _cacheValidDuration;
  }

  /// 日付別にグループ化された記録を取得
  Map<String, List<KindnessRecord>> getGroupedRecords() {
    final Map<String, List<KindnessRecord>> grouped = {};

    for (final record in _kindnessRecords) {
      final dateKey = _formatDateKey(record.createdAt);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(record);
    }

    return grouped;
  }

  /// 日付キーをフォーマット
  String _formatDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final recordDate = DateTime(date.year, date.month, date.day);

    if (recordDate == today) {
      return '今日';
    } else if (recordDate == yesterday) {
      return '昨日';
    } else if (recordDate.isAfter(today.subtract(const Duration(days: 7)))) {
      final weekdays = ['月', '火', '水', '木', '金', '土', '日'];
      return '${date.month}/${date.day}(${weekdays[date.weekday - 1]})';
    } else {
      return '${date.year}/${date.month}/${date.day}';
    }
  }

  /// キャッシュを無効化
  void _invalidateCache() {
    _lastLoadTime = null;
  }

  /// キャッシュを強制的にクリアして再読み込み
  Future<void> refreshKindnessRecords() async {
    await loadKindnessRecords(forceRefresh: true);
  }

  /// エラーメッセージをクリア
  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  /// 成功メッセージをクリア
  void clearSuccessMessage() {
    _successMessage = null;
    notifyListeners();
  }
}
