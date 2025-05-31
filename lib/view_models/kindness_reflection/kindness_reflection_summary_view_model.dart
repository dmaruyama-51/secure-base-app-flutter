import 'package:flutter/material.dart';
import '../../models/kindness_reflection.dart';
import '../../repositories/kindness_reflection_repository.dart';

// Reflection Summary画面のViewModel
class KindnessReflectionSummaryViewModel extends ChangeNotifier {
  final KindnessReflectionRepository _repository =
      KindnessReflectionRepository();

  ReflectionSummaryData? _summaryData;
  bool _isLoading = false;
  String? _error;

  // 表示制御用のプロパティ
  static const int _defaultDisplayCount = 5;
  int _displayCount = _defaultDisplayCount;

  // ゲッター
  ReflectionSummaryData? get summaryData => _summaryData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 表示用のレコードリスト（件数制限あり）
  List<dynamic> get displayedRecords {
    if (_summaryData?.records == null) return [];
    final records = _summaryData!.records;
    return records.take(_displayCount).toList();
  }

  // show moreボタンを表示するかどうか
  bool get shouldShowMoreButton {
    if (_summaryData?.records == null) return false;
    return _summaryData!.records.length > _displayCount;
  }

  // サマリーデータの読み込み
  Future<void> loadSummaryData(String summaryId) async {
    _isLoading = true;
    _error = null;
    // 表示件数をリセット
    _displayCount = _defaultDisplayCount;
    notifyListeners();

    try {
      // Repository から特定のリフレクションデータを取得
      final reflectionId = int.tryParse(summaryId);
      if (reflectionId == null) {
        _error = '無効なリフレクションIDです';
        return;
      }

      final reflection = await _repository.fetchKindnessReflectionById(
        reflectionId,
      );
      if (reflection == null) {
        _error = 'リフレクションが見つかりません';
        return;
      }

      // リフレクション期間内のKindnessRecordとサマリーデータを取得
      _summaryData = await _repository.getReflectionSummaryData(reflection);
    } catch (e) {
      _error = 'データの読み込みに失敗しました';
      debugPrint('Summary data loading error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Show moreボタンの処理
  void showMore() {
    if (_summaryData?.records != null) {
      // さらに5件追加で表示
      _displayCount = (_displayCount + 5).clamp(
        0,
        _summaryData!.records.length,
      );
      notifyListeners();
      debugPrint('Display count increased to: $_displayCount');
    }
  }
}
