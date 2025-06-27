// Flutter imports:
import 'package:flutter/material.dart';

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

/// やさしさ記録追加のViewModel
class KindnessRecordAddViewModel extends ChangeNotifier {
  // 状態プロパティ
  List<KindnessGiver> _kindnessGivers = const [];
  KindnessGiver? _selectedKindnessGiver;
  String _content = '';
  KindnessRecordType _selectedRecordType = KindnessRecordType.received;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;
  bool _shouldNavigateBack = false;
  bool _shouldNavigateToAddGiver = false;

  // ゲッター
  List<KindnessGiver> get kindnessGivers => _kindnessGivers;
  KindnessGiver? get selectedKindnessGiver => _selectedKindnessGiver;
  String get content => _content;
  KindnessRecordType get selectedRecordType => _selectedRecordType;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get shouldNavigateBack => _shouldNavigateBack;
  bool get shouldNavigateToAddGiver => _shouldNavigateToAddGiver;

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

  /// 新規メンバー登録画面への遷移をトリガー
  void navigateToAddGiver() {
    _shouldNavigateToAddGiver = true;
    notifyListeners();
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

  /// 記録タイプを選択
  void selectRecordType(KindnessRecordType recordType) {
    _selectedRecordType = recordType;
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

  /// やさしさ記録を保存
  Future<void> saveKindnessRecord() async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // バリデーション
      _validateKindnessRecordInput();

      await KindnessRecord.createKindnessRecord(
        content: _content,
        selectedKindnessGiver: _selectedKindnessGiver!,
        recordType: _selectedRecordType,
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
    _shouldNavigateToAddGiver = false;
    notifyListeners();
  }

  /// メンバーリストを再読み込み（新規追加後など）
  Future<void> reloadKindnessGivers([KindnessGiver? newlyCreatedGiver]) async {
    try {
      final previousSelectedId = _selectedKindnessGiver?.id;
      _kindnessGivers = await KindnessRecord.fetchKindnessGiversForRecordAdd();

      // 新しく作成されたメンバーがある場合は、それを選択
      if (newlyCreatedGiver != null) {
        final createdGiver =
            _kindnessGivers
                .where((giver) => giver.id == newlyCreatedGiver.id)
                .firstOrNull;
        if (createdGiver != null) {
          _selectedKindnessGiver = createdGiver;
        }
      }
      // 以前選択されていたメンバーを新しいリストから探して再設定
      else if (previousSelectedId != null) {
        final previousSelected =
            _kindnessGivers
                .where((giver) => giver.id == previousSelectedId)
                .firstOrNull;
        _selectedKindnessGiver = previousSelected;
      }

      // 選択されているメンバーがない場合は、リストの最初のメンバーを選択
      if (_selectedKindnessGiver == null && _kindnessGivers.isNotEmpty) {
        _selectedKindnessGiver = _kindnessGivers.first;
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // ===== プレゼンテーションロジック =====

  /// 記録タイプごとのアイコンを取得
  IconData getRecordTypeIcon(KindnessRecordType recordType) {
    switch (recordType) {
      case KindnessRecordType.received:
        return Icons.inbox; // 受け取った（受信箱）
      case KindnessRecordType.given:
        return Icons.send; // 送った（送信）
    }
  }

  /// 記録タイプのラベルテキストを取得
  String getRecordTypeLabel(KindnessRecordType recordType) {
    return recordType.label;
  }

  /// 記録タイプに応じた質問文を取得
  String getContentQuestionText(KindnessRecordType recordType) {
    switch (recordType) {
      case KindnessRecordType.received:
        return 'どんなやさしさを受け取りましたか？';
      case KindnessRecordType.given:
        return 'どんなやさしさを送りましたか？';
    }
  }

  /// 記録タイプに応じた対象者質問文を取得
  String getGiverQuestionText(KindnessRecordType recordType) {
    switch (recordType) {
      case KindnessRecordType.received:
        return '誰からのやさしさですか？';
      case KindnessRecordType.given:
        return '誰に送ったやさしさですか？';
    }
  }

  /// 記録タイプに応じたプレースホルダーテキストを取得
  String getContentPlaceholderText(KindnessRecordType recordType) {
    switch (recordType) {
      case KindnessRecordType.received:
        return '例：「お疲れさま」と声をかけてくれた\n　　◯◯◯について話を聞いてくれた';
      case KindnessRecordType.given:
        return '例：「おはよう」と笑顔で挨拶をした\n　　◯◯◯の悩みを聞いてあげた';
    }
  }

  /// 記録タイプに応じたヒントテキストを取得
  String getRecordHintText(KindnessRecordType recordType) {
    switch (recordType) {
      case KindnessRecordType.received:
        return '小さな出来事も、心の支えとなるかけがえのない記録になります：\n・笑顔であいさつをもらった瞬間\n・体調を気にかけてくれたひと言\n・話をじっくり聞いてくれたとき\n・ちょっとした手助けをもらったこと';
      case KindnessRecordType.given:
        return '小さな行動も、相手の心の支えになっています：\n・笑顔であいさつをした瞬間\n・体調を気にかけた声かけ\n・話をじっくり聞いてあげたとき\n・ちょっとした手助けをしたこと';
    }
  }

  // 現在選択されている記録タイプに基づいたヘルパーメソッド

  /// 利用可能な記録タイプの一覧を取得
  List<KindnessRecordType> get availableRecordTypes =>
      KindnessRecordType.values;

  /// 現在選択されている記録タイプのアイコンを取得
  IconData get currentRecordTypeIcon => getRecordTypeIcon(_selectedRecordType);

  /// 現在選択されている記録タイプの質問文を取得
  String get currentContentQuestionText =>
      getContentQuestionText(_selectedRecordType);

  /// 現在選択されている記録タイプの対象者質問文を取得
  String get currentGiverQuestionText =>
      getGiverQuestionText(_selectedRecordType);

  /// 現在選択されている記録タイプのプレースホルダーテキストを取得
  String get currentContentPlaceholderText =>
      getContentPlaceholderText(_selectedRecordType);

  /// 現在選択されている記録タイプのヒントテキストを取得
  String get currentRecordHintText => getRecordHintText(_selectedRecordType);
}
