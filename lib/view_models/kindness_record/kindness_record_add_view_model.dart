// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../models/kindness_giver.dart';
import '../../models/kindness_record.dart';

/// やさしさ記録追加のViewModel
class KindnessRecordAddViewModel extends ChangeNotifier {
  // 状態プロパティ
  List<KindnessGiver> _kindnessGivers = const [];
  KindnessGiver? _selectedKindnessGiver;
  String _content = '';
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;
  bool _shouldNavigateBack = false;

  // ゲッター
  List<KindnessGiver> get kindnessGivers => _kindnessGivers;
  KindnessGiver? get selectedKindnessGiver => _selectedKindnessGiver;
  String get content => _content;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get shouldNavigateBack => _shouldNavigateBack;

  /// 初期化
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _kindnessGivers = await KindnessRecord.fetchKindnessGiversForRecordAdd();
      if (_kindnessGivers.isNotEmpty) {
        _selectedKindnessGiver = _kindnessGivers.first;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// メンバーを選択
  void selectKindnessGiver(KindnessGiver kindnessGiver) {
    _selectedKindnessGiver = kindnessGiver;
    notifyListeners();
  }

  /// やさしさの内容を更新
  void updateContent(String content) {
    _content = content;
    notifyListeners();
  }

  /// やさしさ記録を保存
  Future<void> saveKindnessRecord() async {
    if (_selectedKindnessGiver == null) {
      _errorMessage = 'メンバーを選択してください';
      notifyListeners();
      return;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await KindnessRecord.createKindnessRecord(
        content: _content,
        selectedKindnessGiver: _selectedKindnessGiver!,
      );

      _isSaving = false;
      _successMessage = 'やさしさ記録を保存しました';
      _shouldNavigateBack = true;
      notifyListeners();
    } catch (e) {
      _isSaving = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// メッセージをクリア
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    _shouldNavigateBack = false;
    notifyListeners();
  }
}
