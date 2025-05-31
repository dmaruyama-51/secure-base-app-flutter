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

  // ゲッター
  ReflectionSummaryData? get summaryData => _summaryData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // サマリーデータの読み込み
  Future<void> loadSummaryData(String summaryId) async {
    _isLoading = true;
    _error = null;
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
    debugPrint('Show more reflection items');
    // UI実装のため、現在は何もしない
  }
}
