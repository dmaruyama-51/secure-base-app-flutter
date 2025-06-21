// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../models/kindness_giver.dart';
import '../../models/kindness_record.dart';

/// バリデーションエラー用の例外クラス（KindnessRecord用）
class KindnessRecordValidationException implements Exception {
  final String message;

  KindnessRecordValidationException(this.message);

  @override
  String toString() => message;
}

/// やさしさ記録編集のViewModel
class KindnessRecordEditViewModel extends ChangeNotifier {
  // 状態プロパティ
  KindnessRecord? _originalRecord;
  List<KindnessGiver> _kindnessGivers = const [];
  KindnessGiver? _selectedKindnessGiver;
  String _content = '';
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isDeleting = false;
  String? _errorMessage;
  String? _successMessage;
  bool _shouldNavigateBack = false;

  KindnessRecordEditViewModel({required KindnessRecord originalRecord})
    : _originalRecord = originalRecord,
      _content = originalRecord.content;

  // ゲッター
  KindnessRecord? get originalRecord => _originalRecord;
  List<KindnessGiver> get kindnessGivers => _kindnessGivers;
  KindnessGiver? get selectedKindnessGiver => _selectedKindnessGiver;
  String get content => _content;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isDeleting => _isDeleting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get shouldNavigateBack => _shouldNavigateBack;

  /// 初期化
  Future<void> initialize() async {
    if (_originalRecord == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await KindnessRecord.fetchKindnessGiversForRecordEdit(
        originalRecord: _originalRecord!,
      );

      _kindnessGivers = result.kindnessGivers;
      _selectedKindnessGiver = result.selectedGiver;
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

  /// やさしさ記録の入力バリデーション
  void _validateKindnessRecordInput() {
    if (_content.trim().isEmpty) {
      throw KindnessRecordValidationException('やさしさの内容を入力してください');
    }
    if (_selectedKindnessGiver == null) {
      throw KindnessRecordValidationException('メンバーを選択してください');
    }
  }

  /// やさしさ記録を更新
  Future<void> updateKindnessRecord() async {
    if (_originalRecord == null) {
      _errorMessage = '編集対象のレコードが見つかりません';
      notifyListeners();
      return;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // バリデーション
      _validateKindnessRecordInput();

      await KindnessRecord.updateKindnessRecord(
        originalRecord: _originalRecord!,
        content: _content,
        selectedKindnessGiver: _selectedKindnessGiver!,
      );

      _isSaving = false;
      _successMessage = 'やさしさ記録を更新しました';
      _shouldNavigateBack = true;
      notifyListeners();
    } catch (e) {
      _isSaving = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// やさしさ記録を削除
  Future<void> deleteKindnessRecord() async {
    if (_originalRecord == null) {
      _errorMessage = '削除対象のレコードが見つかりません';
      notifyListeners();
      return;
    }

    if (_originalRecord!.id == null) {
      _errorMessage = '無効なレコードIDです';
      notifyListeners();
      return;
    }

    _isDeleting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await KindnessRecord.deleteKindnessRecord(recordId: _originalRecord!.id!);

      _isDeleting = false;
      _successMessage = 'やさしさ記録を削除しました';
      _shouldNavigateBack = true;
      notifyListeners();
    } catch (e) {
      _isDeleting = false;
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
