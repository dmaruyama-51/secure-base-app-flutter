// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../models/kindness_record.dart';
import '../../models/kindness_reflection.dart';

/// リフレクション詳細画面の統計情報
class ReflectionStatistics {
  final int totalRecords;
  final int receivedRecords; // 受け取ったやさしさの件数
  final int givenRecords; // 送ったやさしさの件数
  final Map<String, int> categoryCount;
  final Map<String, int> genderCount;
  final Map<String, int> receivedCategoryCount; // 受け取ったやさしさのカテゴリ別
  final Map<String, int> givenCategoryCount; // 送ったやさしさのカテゴリ別
  final List<String> mostActiveWeekdays;
  final double averageRecordsPerDay;
  final double averageReceivedPerDay; // 受け取ったやさしさの1日平均
  final double averageGivenPerDay; // 送ったやさしさの1日平均

  ReflectionStatistics({
    required this.totalRecords,
    required this.receivedRecords,
    required this.givenRecords,
    required this.categoryCount,
    required this.genderCount,
    required this.receivedCategoryCount,
    required this.givenCategoryCount,
    required this.mostActiveWeekdays,
    required this.averageRecordsPerDay,
    required this.averageReceivedPerDay,
    required this.averageGivenPerDay,
  });

  /// やさしさのバランス（0.0-1.0、0.5が完全にバランス取れている状態）
  double get kindnessBalance {
    if (totalRecords == 0) return 0.5;
    return receivedRecords / totalRecords;
  }

  /// バランスの説明文を取得
  String get balanceDescription {
    if (totalRecords == 0) return '';

    final balance = kindnessBalance;
    if (balance > 0.7) {
      return '大切にされていると感じることの多い期間でしたね。';
    } else if (balance < 0.3) {
      return 'たくさん相手の支えになることのできた期間でしたね。';
    } else {
      return '支え合うことのできた期間でしたね。';
    }
  }
}

/// リフレクション詳細のViewModel
class ReflectionDetailViewModel extends ChangeNotifier {
  final KindnessReflection? reflection;
  final String? reflectionId;

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

  /// リフレクションのタイトルを取得
  String get reflectionTitle => currentReflection?.reflectionTitle ?? 'リフレクション';

  /// リフレクションの開始日を取得
  DateTime? get reflectionStartDate => currentReflection?.reflectionStartDate;

  /// リフレクションの終了日を取得
  DateTime? get reflectionEndDate => currentReflection?.reflectionEndDate;

  /// ViewModel作成用のファクトリーメソッド（reflectionIdから）
  static Future<ReflectionDetailViewModel> createFromId(
    String reflectionId,
  ) async {
    final viewModel = ReflectionDetailViewModel(reflectionId: reflectionId);
    await viewModel.initialize();
    return viewModel;
  }

  /// ViewModel作成用のファクトリーメソッド（reflectionオブジェクトから）
  static ReflectionDetailViewModel createFromReflection(
    KindnessReflection reflection,
  ) {
    return ReflectionDetailViewModel(reflection: reflection);
  }

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

    // 受け取ったやさしさと送ったやさしさを分ける
    final receivedRecords =
        records
            .where((r) => r.recordType == KindnessRecordType.received)
            .toList();
    final givenRecords =
        records.where((r) => r.recordType == KindnessRecordType.given).toList();

    // カテゴリ別集計（全体・受け取った・送った）
    final categoryCount = <String, int>{};
    final receivedCategoryCount = <String, int>{};
    final givenCategoryCount = <String, int>{};
    final genderCount = <String, int>{};
    final weekdayCount = <int, int>{};

    for (final record in records) {
      // カテゴリ集計
      final category =
          record.giverCategory.isNotEmpty ? record.giverCategory : 'その他';
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;

      // 受け取った/送ったカテゴリ別集計
      if (record.recordType == KindnessRecordType.received) {
        receivedCategoryCount[category] =
            (receivedCategoryCount[category] ?? 0) + 1;
      } else {
        givenCategoryCount[category] = (givenCategoryCount[category] ?? 0) + 1;
      }

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
    final averageReceivedPerDay = receivedRecords.length / totalDays;
    final averageGivenPerDay = givenRecords.length / totalDays;

    return ReflectionStatistics(
      totalRecords: records.length,
      receivedRecords: receivedRecords.length,
      givenRecords: givenRecords.length,
      categoryCount: categoryCount,
      genderCount: genderCount,
      receivedCategoryCount: receivedCategoryCount,
      givenCategoryCount: givenCategoryCount,
      mostActiveWeekdays: mostActiveWeekdays,
      averageRecordsPerDay: averageRecordsPerDay,
      averageReceivedPerDay: averageReceivedPerDay,
      averageGivenPerDay: averageGivenPerDay,
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
      receivedRecords: 0,
      givenRecords: 0,
      categoryCount: {},
      genderCount: {},
      receivedCategoryCount: {},
      givenCategoryCount: {},
      mostActiveWeekdays: [],
      averageRecordsPerDay: 0,
      averageReceivedPerDay: 0,
      averageGivenPerDay: 0,
    );
  }

  /// 日付でグループ化されたレコードを取得
  Map<String, List<KindnessRecord>> getGroupedRecords() {
    final grouped = <String, List<KindnessRecord>>{};

    for (final record in _records) {
      final key = _formatDateKey(record.createdAt);
      grouped[key] = (grouped[key] ?? [])..add(record);
    }

    // 日付でソート（新しい順）
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    final sortedGrouped = <String, List<KindnessRecord>>{};
    for (final key in sortedKeys) {
      // 各日付内のレコードを時間順でソート（新しい順）
      grouped[key]!.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      sortedGrouped[key] = grouped[key]!;
    }

    return sortedGrouped;
  }

  /// タイプ別にグループ化されたレコードを取得
  Map<KindnessRecordType, List<KindnessRecord>> getRecordsByType() {
    final receivedRecords =
        _records
            .where((r) => r.recordType == KindnessRecordType.received)
            .toList();
    final givenRecords =
        _records
            .where((r) => r.recordType == KindnessRecordType.given)
            .toList();

    // 時間順でソート（新しい順）
    receivedRecords.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    givenRecords.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return {
      KindnessRecordType.received: receivedRecords,
      KindnessRecordType.given: givenRecords,
    };
  }

  /// タイプ別かつ日付別にグループ化されたレコードを取得
  Map<KindnessRecordType, Map<String, List<KindnessRecord>>>
  getGroupedRecordsByType() {
    final recordsByType = getRecordsByType();
    final result = <KindnessRecordType, Map<String, List<KindnessRecord>>>{};

    for (final entry in recordsByType.entries) {
      final grouped = <String, List<KindnessRecord>>{};

      for (final record in entry.value) {
        final key = _formatDateKey(record.createdAt);
        grouped[key] = (grouped[key] ?? [])..add(record);
      }

      // 日付でソート（新しい順）
      final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

      final sortedGrouped = <String, List<KindnessRecord>>{};
      for (final key in sortedKeys) {
        // 各日付内のレコードを時間順でソート（新しい順）
        grouped[key]!.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        sortedGrouped[key] = grouped[key]!;
      }

      result[entry.key] = sortedGrouped;
    }

    return result;
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
