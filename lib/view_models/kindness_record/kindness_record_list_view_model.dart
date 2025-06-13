// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../models/kindness_record.dart';

/// やさしさ記録一覧のViewModel
class KindnessRecordListViewModel extends ChangeNotifier {
  // 状態プロパティ
  List<KindnessRecord> _kindnessRecords = const [];
  bool _isLoading = false;
  String? _errorMessage;

  // ゲッター
  List<KindnessRecord> get kindnessRecords => _kindnessRecords;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// やさしさ記録一覧を読み込む
  Future<void> loadKindnessRecords() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _kindnessRecords = await KindnessRecord.fetchKindnessRecords();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// エラーメッセージをクリア
  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }
}
