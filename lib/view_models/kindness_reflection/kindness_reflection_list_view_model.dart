// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../models/kindness_reflection.dart';
import '../../models/balance_score.dart';
import '../../models/repositories/balance_score_repository.dart';

class ReflectionListViewModel extends ChangeNotifier {
  List<KindnessReflection> _reflections = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasMore = true;
  int _currentOffset = 0;
  static const int _pageSize = 20;

  // 次回配信日計算用の新しいプロパティ
  DateTime? _nextDeliveryDate;
  String? _nextDeliveryDateError;
  bool _isCalculatingNextDelivery = false;

  // バランススコア関連のプロパティ
  List<BalanceScore> _balanceScores = [];
  bool _isLoadingBalanceScores = false;
  String? _balanceScoreError;
  final BalanceScoreRepository _balanceScoreRepository =
      BalanceScoreRepository();

  // バランススコアチャートの状態管理
  int? _selectedBalanceScoreIndex;

  // ゲッター
  List<KindnessReflection> get reflections => _reflections;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  bool get isEmpty => _reflections.isEmpty && !_isLoading;
  DateTime? get nextDeliveryDate => _nextDeliveryDate;
  String? get nextDeliveryDateError => _nextDeliveryDateError;
  bool get isCalculatingNextDelivery => _isCalculatingNextDelivery;
  List<BalanceScore> get balanceScores => _balanceScores;
  bool get isLoadingBalanceScores => _isLoadingBalanceScores;
  String? get balanceScoreError => _balanceScoreError;
  int? get selectedBalanceScoreIndex => _selectedBalanceScoreIndex;

  /// バランススコアチャートの選択状態を更新
  void selectBalanceScoreIndex(int? index) {
    if (_selectedBalanceScoreIndex != index) {
      _selectedBalanceScoreIndex = index;
      notifyListeners();
    }
  }

  /// 選択されたバランススコアデータを取得
  BalanceScore? get selectedBalanceScore {
    if (_selectedBalanceScoreIndex == null ||
        _selectedBalanceScoreIndex! < 0 ||
        _selectedBalanceScoreIndex! >= _balanceScores.length) {
      return null;
    }
    return _balanceScores[_selectedBalanceScoreIndex!];
  }

  /// リフレクションを「最新」と「過去」にグループ分け
  /// createdAtの順序で最新のレコードを「最新」として扱う
  Map<String, List<KindnessReflection>> getGroupedReflections() {
    final latestReflections = <KindnessReflection>[];
    final pastReflections = <KindnessReflection>[];

    // リフレクションが空の場合は空のMapを返す
    if (_reflections.isEmpty) {
      return {'latest': latestReflections, 'past': pastReflections};
    }

    // 最初のレコード（最新）を「最新」として扱い、残りを「過去」とする
    latestReflections.add(_reflections.first);

    if (_reflections.length > 1) {
      pastReflections.addAll(_reflections.skip(1));
    }

    return {'latest': latestReflections, 'past': pastReflections};
  }

  /// 次回リフレクション配信日を計算する
  Future<void> calculateNextDeliveryDate() async {
    _isCalculatingNextDelivery = true;
    _nextDeliveryDateError = null;
    notifyListeners();

    try {
      // モデルのビジネスロジックを使用
      _nextDeliveryDate = await KindnessReflection.calculateNextDeliveryDate(
        existingReflections: _reflections,
      );
    } catch (e) {
      _nextDeliveryDateError = 'お届け日の計算に失敗しました: $e';
      _nextDeliveryDate = null;
    } finally {
      _isCalculatingNextDelivery = false;
      notifyListeners();
    }
  }

  /// 初回データ読み込み
  Future<void> loadReflections() async {
    if (_isLoading) return;

    _setLoading(true);
    _clearError();
    _currentOffset = 0;
    _hasMore = true;

    try {
      final newReflections = await KindnessReflection.fetchReflections(
        limit: _pageSize,
        offset: 0,
      );

      _reflections = newReflections;
      _hasMore = newReflections.length == _pageSize;
      _currentOffset = newReflections.length;

      // リフレクション読み込み後に次回配信日を計算
      await calculateNextDeliveryDate();

      // バランススコアも並行して読み込み
      await loadBalanceScores();
    } catch (e) {
      _setError('リフレクションの取得に失敗しました: $e');
    } finally {
      _setLoading(false);
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

  /// リフレッシュ（Pull to Refresh用）
  Future<void> refreshReflections() async {
    _currentOffset = 0;
    _hasMore = true;
    _clearError();

    try {
      final newReflections = await KindnessReflection.fetchReflections(
        limit: _pageSize,
        offset: 0,
      );

      _reflections = newReflections;
      _hasMore = newReflections.length == _pageSize;
      _currentOffset = newReflections.length;

      // リフレッシュ後に次回配信日を再計算
      await calculateNextDeliveryDate();

      // バランススコアも更新
      await loadBalanceScores();

      notifyListeners();
    } catch (e) {
      _setError('リフレクションの更新に失敗しました: $e');
    }
  }

  /// エラーメッセージをクリア
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// バランススコアデータを読み込み
  Future<void> loadBalanceScores() async {
    _isLoadingBalanceScores = true;
    _balanceScoreError = null;
    _selectedBalanceScoreIndex = null; // 選択状態をリセット
    notifyListeners();

    try {
      _balanceScores = await _balanceScoreRepository.fetchWeeklyBalanceScores();
    } catch (e) {
      _balanceScoreError = 'バランススコアの取得に失敗しました: $e';
      _balanceScores = []; // エラー時は空リストに
    } finally {
      _isLoadingBalanceScores = false;
      notifyListeners();
    }
  }
}
