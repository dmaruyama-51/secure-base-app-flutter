// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../models/kindness_reflection.dart';

class ReflectionListViewModel extends ChangeNotifier {
  List<KindnessReflection> _reflections = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasMore = true;
  int _currentOffset = 0;
  static const int _pageSize = 20;

  // ゲッター
  List<KindnessReflection> get reflections => _reflections;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  bool get isEmpty => _reflections.isEmpty && !_isLoading;

  /// リフレクションを「最新」と「過去」にグループ分け（Modelに委譲）
  Map<String, List<KindnessReflection>> getGroupedReflections() {
    return KindnessReflection.groupReflections(_reflections);
  }

  /// 初回データ読み込み
  Future<void> loadReflections() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    _currentOffset = 0;
    notifyListeners();

    try {
      final newReflections = await KindnessReflection.fetchReflections(
        limit: _pageSize,
        offset: _currentOffset,
      );

      _reflections = newReflections;
      _currentOffset = newReflections.length.toInt();
      _hasMore = newReflections.length == _pageSize;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 追加データ読み込み（ページネーション）
  Future<void> loadMoreReflections() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      final newReflections = await KindnessReflection.fetchReflections(
        limit: _pageSize,
        offset: _currentOffset,
      );

      _reflections.addAll(newReflections);
      _currentOffset += newReflections.length.toInt();
      _hasMore = newReflections.length == _pageSize;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// データを再読み込み
  Future<void> refreshReflections() async {
    _reflections.clear();
    _currentOffset = 0;
    _hasMore = true;
    await loadReflections();
  }

  /// エラーメッセージをクリア
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
