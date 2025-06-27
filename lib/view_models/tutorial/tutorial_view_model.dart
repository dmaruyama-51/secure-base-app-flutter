// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../models/user_model.dart';
import '../../models/kindness_giver.dart';
import '../../models/kindness_record.dart';
import '../../models/kindness_reflection.dart';

/// チュートリアル関連のバリデーションエラー用の例外クラス
class TutorialValidationException implements Exception {
  final String message;

  TutorialValidationException(this.message);

  @override
  String toString() => message;
}

/// チュートリアルのViewModel
class TutorialViewModel extends ChangeNotifier {
  // =============================================================================
  // 定数定義
  // =============================================================================

  // チュートリアルページ関連
  static const int totalPages = 4;
  static const int firstPageIndex = 0;
  static const int lastPageIndex = 3;
  static const int introductionPageIndex = 0;
  static const int memberRegistrationPageIndex = 1;
  static const int kindnessRecordPageIndex = 2;
  static const int reflectionSettingPageIndex = 3;

  // アニメーション関連
  static const int pageAnimationDurationMs = 300;

  // ボタンテキスト定義
  static const Map<int, String> _nextButtonTexts = {
    introductionPageIndex: '次へ',
    memberRegistrationPageIndex: '次へ',
    kindnessRecordPageIndex: '記録して次へ',
    reflectionSettingPageIndex: 'チュートリアル完了',
  };

  // =============================================================================
  // 状態プロパティ
  // =============================================================================

  int _currentPage = 0;
  String _kindnessGiverName = '';
  String _selectedGender = '女性';
  String _selectedRelation = '家族';
  String _kindnessContent = '';
  KindnessRecordType _selectedRecordType = KindnessRecordType.received;
  String _selectedReflectionFrequency = '2週に1回';
  bool _isCompleting = false;
  bool _isRecordingKindness = false;
  bool _isSettingReflection = false;
  String? _errorMessage;

  // ナビゲーション状態
  bool _shouldNavigateNext = false;
  bool _shouldNavigateToMain = false;

  TutorialViewModel() {
    // Initialize any necessary fields
  }

  // ゲッター
  int get currentPage => _currentPage;
  String get kindnessGiverName => _kindnessGiverName;
  String get selectedGender => _selectedGender;
  String get selectedRelation => _selectedRelation;
  String get kindnessContent => _kindnessContent;
  KindnessRecordType get selectedRecordType => _selectedRecordType;
  String get selectedReflectionFrequency => _selectedReflectionFrequency;
  bool get isCompleting => _isCompleting;
  bool get isRecordingKindness => _isRecordingKindness;
  bool get isSettingReflection => _isSettingReflection;
  String? get errorMessage => _errorMessage;
  bool get shouldNavigateNext => _shouldNavigateNext;
  bool get shouldNavigateToMain => _shouldNavigateToMain;

  /// チュートリアル完了時のバリデーション
  void _validateTutorialCompletion() {
    if (_kindnessGiverName.trim().isEmpty) {
      throw TutorialValidationException('名前を入力してください');
    }
  }

  void nextPage() {
    if (_currentPage < lastPageIndex) {
      _currentPage = _currentPage + 1;
      notifyListeners();
    }
  }

  void previousPage() {
    if (_currentPage > firstPageIndex) {
      _currentPage = _currentPage - 1;
      notifyListeners();
    }
  }

  void updateName(String name) {
    _kindnessGiverName = name;
    notifyListeners();
  }

  void updateGender(String gender) {
    _selectedGender = gender;
    notifyListeners();
  }

  void updateRelation(String relation) {
    _selectedRelation = relation;
    notifyListeners();
  }

  void updateKindnessContent(String content) {
    _kindnessContent = content;
    notifyListeners();
  }

  /// 記録タイプを選択
  void selectRecordType(KindnessRecordType recordType) {
    _selectedRecordType = recordType;
    notifyListeners();
  }

  void updateReflectionFrequency(String frequency) {
    _selectedReflectionFrequency = frequency;
    notifyListeners();
  }

  Future<bool> recordKindness() async {
    _isRecordingKindness = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_kindnessContent.trim().isEmpty) {
        _isRecordingKindness = false;
        notifyListeners();
        return true; // 空の場合はスキップ
      }

      // まず作成されたメンバーを取得
      final kindnessGivers = await KindnessGiver.fetchKindnessGivers();
      if (kindnessGivers.isEmpty) {
        throw Exception('メンバーが見つかりません');
      }

      final selectedGiver = kindnessGivers.first;

      // やさしさ記録を作成
      await KindnessRecord.createKindnessRecord(
        content: _kindnessContent,
        selectedKindnessGiver: selectedGiver,
        recordType: _selectedRecordType,
      );

      _isRecordingKindness = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isRecordingKindness = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> completeReflectionSettings() async {
    _isSettingReflection = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // リフレクション設定を保存
      await UserModel.updateReflectionFrequency(_selectedReflectionFrequency);

      // チュートリアル完了をマーク
      await UserModel.markTutorialCompleted();

      _isSettingReflection = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSettingReflection = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> completeTutorial() async {
    _isCompleting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // バリデーション
      _validateTutorialCompletion();

      // メンバー作成
      await KindnessGiver.createKindnessGiver(
        giverName: _kindnessGiverName,
        genderName: _selectedGender,
        relationshipName: _selectedRelation,
      );

      _isCompleting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isCompleting = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  /// ナビゲーション状態をクリア
  void clearNavigationState() {
    _shouldNavigateNext = false;
    _shouldNavigateToMain = false;
    notifyListeners();
  }

  // =============================================================================
  // UI制御メソッド
  // =============================================================================

  /// 現在のページに応じたボタンテキストを取得
  String getNextButtonText() {
    return _nextButtonTexts[_currentPage] ?? '次へ';
  }

  /// 戻るボタンを表示するかどうか
  bool shouldShowBackButton() {
    return _currentPage > firstPageIndex;
  }

  /// 次へボタンを表示するかどうか
  bool shouldShowNextButton() {
    return _currentPage <= lastPageIndex;
  }

  /// スキップボタンを表示するかどうか
  bool shouldShowSkipButton() {
    return _currentPage == kindnessRecordPageIndex;
  }

  /// 次へボタンがローディング状態かどうか
  bool isNextButtonLoading() {
    return switch (_currentPage) {
      memberRegistrationPageIndex => _isCompleting,
      kindnessRecordPageIndex => _isRecordingKindness,
      reflectionSettingPageIndex => _isSettingReflection || _isCompleting,
      _ => false,
    };
  }

  /// 次へボタンが無効かどうか
  bool isNextButtonDisabled() {
    return switch (_currentPage) {
      memberRegistrationPageIndex =>
        _kindnessGiverName.trim().isEmpty || _isCompleting,
      kindnessRecordPageIndex => _isRecordingKindness,
      reflectionSettingPageIndex => _isSettingReflection || _isCompleting,
      _ => false,
    };
  }

  // =============================================================================
  // アクション実行メソッド
  // =============================================================================

  /// スキップアクションを実行
  void executeSkipAction() {
    if (_currentPage == kindnessRecordPageIndex) {
      // 優しさ記録をスキップして次のページへ
      nextPage();
      _shouldNavigateNext = true;
      notifyListeners();
    }
  }

  /// 次へアクションを実行
  Future<void> executeNextAction() async {
    switch (_currentPage) {
      case introductionPageIndex:
        _executeIntroductionAction();
        break;
      case memberRegistrationPageIndex:
        await _executeMemberRegistrationAction();
        break;
      case kindnessRecordPageIndex:
        await _executeKindnessRecordAction();
        break;
      case reflectionSettingPageIndex:
        await _executeReflectionSettingAction();
        break;
    }
  }

  /// 各ページのアクション実行メソッド
  void _executeIntroductionAction() {
    nextPage();
    _shouldNavigateNext = true;
    notifyListeners();
  }

  Future<void> _executeMemberRegistrationAction() async {
    final success = await completeTutorial();
    if (success) {
      nextPage();
      _shouldNavigateNext = true;
      notifyListeners();
    }
  }

  Future<void> _executeKindnessRecordAction() async {
    final success = await recordKindness();
    if (success) {
      nextPage();
      _shouldNavigateNext = true;
      notifyListeners();
    }
  }

  Future<void> _executeReflectionSettingAction() async {
    // リフレクション設定を完了（設定保存 + チュートリアル完了マーク）
    final success = await completeReflectionSettings();
    if (success) {
      // プレゼンテーションロジック：メイン画面にナビゲーション
      _shouldNavigateToMain = true;
      notifyListeners();
    }
  }

  /// 頻度の説明文を取得
  Future<String> getFrequencyDescription(String frequency) async {
    return await KindnessReflection.getFrequencyDescription(frequency);
  }

  // =============================================================================
  // プレゼンテーション用メソッド
  // =============================================================================

  /// 利用可能な記録タイプの一覧を取得
  List<KindnessRecordType> get availableRecordTypes =>
      KindnessRecordType.values;

  /// 記録タイプに応じた質問文を取得
  String getContentQuestionText(KindnessRecordType recordType) {
    switch (recordType) {
      case KindnessRecordType.received:
        return 'どんなやさしさを受け取りましたか？';
      case KindnessRecordType.given:
        return 'どんなやさしさを送りましたか？';
    }
  }

  /// 記録タイプに応じたプレースホルダーテキストを取得
  String getContentPlaceholderText(KindnessRecordType recordType) {
    switch (recordType) {
      case KindnessRecordType.received:
        return '例：疲れているときに「お疲れ様」と声をかけてくれた';
      case KindnessRecordType.given:
        return '例：「おはよう」と笑顔で挨拶をした';
    }
  }

  /// 現在選択されている記録タイプの質問文を取得
  String get currentContentQuestionText =>
      getContentQuestionText(_selectedRecordType);

  /// 現在選択されている記録タイプのプレースホルダーテキストを取得
  String get currentContentPlaceholderText =>
      getContentPlaceholderText(_selectedRecordType);
}
