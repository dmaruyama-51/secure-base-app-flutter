import 'package:flutter/foundation.dart';
import '../../repositories/kindness_record_repository.dart';
import '../../models/kindness_record.dart';

/// やさしさ記録一覧のViewModel
class KindnessRecordListViewModel extends ChangeNotifier {
  final KindnessRecordRepository _repository;

  // 状態プロパティ
  List<KindnessRecord> _kindnessRecords = const [];
  bool _isLoading = false;
  String? _errorMessage;

  KindnessRecordListViewModel() : _repository = KindnessRecordRepository();

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
      _kindnessRecords = await _repository.fetchKindnessRecords();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'やさしさ記録の取得に失敗しました';
      notifyListeners();
    }
  }

  /// エラーメッセージをクリア
  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }
}
