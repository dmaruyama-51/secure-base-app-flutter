import 'package:flutter/material.dart';
import '../../models/kindness_reflection.dart';
import '../../models/kindness_record.dart';
import '../../repositories/kindness_reflection_repository.dart';

// Reflection Summary画面のViewModel
class KindnessReflectionSummaryViewModel extends ChangeNotifier {
  final ReflectionRepository _repository = ReflectionRepository();

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
      // Repository から reflection データを取得
      final reflectionItems = await _repository.getReflectionItems();

      // 指定されたIDのreflectionアイテムを探す
      final targetReflection = reflectionItems.firstWhere(
        (item) => item.id.toString() == summaryId,
        orElse: () => reflectionItems.first, // フォールバック
      );

      await Future.delayed(const Duration(milliseconds: 500));

      // ダミーのKindnessRecordリスト
      final dummyRecords = [
        KindnessRecord(
          id: 1,
          userId: 1,
          giverId: 1,
          content: '雨が降っていた中で傘を貸してくれた',
          createdAt: DateTime.now().subtract(const Duration(hours: 24)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 24)),
          giverName: 'お母さん',
          giverAvatarUrl: null,
        ),
        KindnessRecord(
          id: 2,
          userId: 1,
          giverId: 2,
          content: '残業がんばってと応援してくれた',
          createdAt: DateTime.now().subtract(const Duration(hours: 48)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 48)),
          giverName: 'お父さん',
          giverAvatarUrl: null,
        ),
        KindnessRecord(
          id: 3,
          userId: 1,
          giverId: 1,
          content: '合格をお祝いしてくれた',
          createdAt: DateTime.now().subtract(const Duration(hours: 72)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 72)),
          giverName: 'お母さん',
          giverAvatarUrl: null,
        ),
        KindnessRecord(
          id: 4,
          userId: 1,
          giverId: 3,
          content: '誕生日にプレゼントをくれた',
          createdAt: DateTime.now().subtract(const Duration(hours: 96)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 96)),
          giverName: 'たろー',
          giverAvatarUrl: null,
        ),
      ];

      _summaryData = ReflectionSummaryData(
        title: targetReflection.reflectionTitle,
        entriesCount: 4,
        daysCount: 2,
        peopleCount: 3,
        records: dummyRecords,
      );
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
