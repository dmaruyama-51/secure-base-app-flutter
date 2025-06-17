// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../models/kindness_record.dart';
import '../../models/kindness_reflection.dart';
import '../../models/repositories/kindness_record_repository.dart';

/// リフレクション詳細画面の統計情報
class ReflectionStatistics {
  final int totalRecords;
  final Map<String, int> categoryCount;
  final Map<String, int> genderCount;
  final List<String> mostActiveWeekdays;
  final double averageRecordsPerDay;

  ReflectionStatistics({
    required this.totalRecords,
    required this.categoryCount,
    required this.genderCount,
    required this.mostActiveWeekdays,
    required this.averageRecordsPerDay,
  });
}

/// リフレクション詳細のViewModel
class ReflectionDetailViewModel extends ChangeNotifier {
  final KindnessReflection? reflection;
  final String? reflectionId;
  final KindnessRecordRepository _repository = KindnessRecordRepository();

  // 状態プロパティ
  List<KindnessRecord> _records = [];
  ReflectionStatistics? _statistics;
  bool _isLoading = true;
  String? _errorMessage;
  KindnessReflection? _loadedReflection; // IDから読み込んだリフレクション

  ReflectionDetailViewModel({this.reflection, this.reflectionId});

  // ゲッター
  List<KindnessRecord> get records => _records;
  ReflectionStatistics? get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasData => _records.isNotEmpty;

  // 実際に使用するリフレクションを取得
  KindnessReflection? get currentReflection => reflection ?? _loadedReflection;

  /// 初期化処理
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // リフレクションデータの妥当性チェック
      if (reflection == null && reflectionId == null) {
        throw Exception('リフレクションデータまたはIDが必要です');
      }

      // IDが指定されている場合はリフレクションを取得
      if (reflection == null && reflectionId != null) {
        // IDからリフレクションを取得
        final reflectionFromId = await KindnessReflection.getReflectionById(
          int.parse(reflectionId!),
        );

        if (reflectionFromId == null) {
          throw Exception('指定されたIDのリフレクションが見つかりません');
        }

        _loadedReflection = reflectionFromId;
      }

      await _loadReflectionData();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'データの読み込みに失敗しました: ${e.toString()}';
      print('ReflectionDetailViewModel initialization error: $e'); // デバッグ用
      notifyListeners();
      rethrow; // エラーを再スローして上位でキャッチできるようにする
    }
  }

  /// リフレクション期間のデータを読み込み
  Future<void> _loadReflectionData() async {
    try {
      final currentRef = currentReflection;
      if (currentRef == null ||
          currentRef.reflectionStartDate == null ||
          currentRef.reflectionEndDate == null) {
        _records = [];
        _statistics = _createEmptyStatistics();
        return;
      }

      // 該当期間のkindness_recordを取得
      _records = await _fetchRecordsInPeriod(
        currentRef.reflectionStartDate!,
        currentRef.reflectionEndDate!,
      );

      // 統計情報を生成
      _statistics = _calculateStatistics(_records);
    } catch (e) {
      print('Error loading reflection data: $e'); // デバッグ用
      _records = [];
      _statistics = _createEmptyStatistics();
      throw Exception('データの取得に失敗しました');
    }
  }

  /// 指定期間のレコードを取得
  Future<List<KindnessRecord>> _fetchRecordsInPeriod(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // 全レコードを取得して期間でフィルタ
      final allRecords = await KindnessRecord.fetchKindnessRecords(
        limit: 1000, // 十分な数を取得
      );

      return allRecords.where((record) {
        final recordDate = DateTime(
          record.createdAt.year,
          record.createdAt.month,
          record.createdAt.day,
        );
        return recordDate.isAfter(
              startDate.subtract(const Duration(days: 1)),
            ) &&
            recordDate.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    } catch (e) {
      print('Error fetching records: $e'); // デバッグ用
      throw Exception('レコードの取得に失敗しました');
    }
  }

  /// 統計情報を計算
  ReflectionStatistics _calculateStatistics(List<KindnessRecord> records) {
    if (records.isEmpty) {
      return _createEmptyStatistics();
    }

    final currentRef = currentReflection;
    if (currentRef == null ||
        currentRef.reflectionStartDate == null ||
        currentRef.reflectionEndDate == null) {
      return _createEmptyStatistics();
    }

    // カテゴリ別集計
    final categoryCount = <String, int>{};
    final genderCount = <String, int>{};
    final weekdayCount = <int, int>{};

    for (final record in records) {
      // カテゴリ集計
      final category =
          record.giverCategory.isNotEmpty ? record.giverCategory : 'その他';
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;

      // 性別集計
      final gender = record.giverGender.isNotEmpty ? record.giverGender : 'その他';
      genderCount[gender] = (genderCount[gender] ?? 0) + 1;

      // 曜日集計
      final weekday = record.createdAt.weekday;
      weekdayCount[weekday] = (weekdayCount[weekday] ?? 0) + 1;
    }

    // 最も多い曜日を取得
    final mostActiveWeekdays = _getMostActiveWeekdays(weekdayCount);

    // 1日平均を計算
    final totalDays =
        currentRef.reflectionEndDate!
            .difference(currentRef.reflectionStartDate!)
            .inDays +
        1;
    final averageRecordsPerDay = records.length / totalDays;

    return ReflectionStatistics(
      totalRecords: records.length,
      categoryCount: categoryCount,
      genderCount: genderCount,
      mostActiveWeekdays: mostActiveWeekdays,
      averageRecordsPerDay: averageRecordsPerDay,
    );
  }

  /// 最も多い曜日を取得
  List<String> _getMostActiveWeekdays(Map<int, int> weekdayCount) {
    if (weekdayCount.isEmpty) return [];

    final weekdayNames = ['月', '火', '水', '木', '金', '土', '日'];
    final maxCount = weekdayCount.values.reduce((a, b) => a > b ? a : b);

    final mostActive = <String>[];
    weekdayCount.forEach((weekday, count) {
      if (count == maxCount) {
        mostActive.add(weekdayNames[weekday - 1]);
      }
    });

    return mostActive;
  }

  /// 空の統計情報を作成
  ReflectionStatistics _createEmptyStatistics() {
    return ReflectionStatistics(
      totalRecords: 0,
      categoryCount: {},
      genderCount: {},
      mostActiveWeekdays: [],
      averageRecordsPerDay: 0,
    );
  }

  /// 日付別にグループ化されたレコードを取得
  Map<String, List<KindnessRecord>> getGroupedRecords() {
    final Map<String, List<KindnessRecord>> grouped = {};

    for (final record in _records) {
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
    return '${date.month}/${date.day}(${['月', '火', '水', '木', '金', '土', '日'][date.weekday - 1]})';
  }

  /// エラーメッセージをクリア
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// データを再読み込み
  Future<void> refresh() async {
    await initialize();
  }
}
