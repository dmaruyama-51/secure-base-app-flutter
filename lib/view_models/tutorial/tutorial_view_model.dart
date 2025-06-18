// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../models/tutorial_model.dart';

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

  void updateReflectionFrequency(String frequency) {
    _selectedReflectionFrequency = frequency;
    notifyListeners();
  }

  Future<bool> recordKindness() async {
    _isRecordingKindness = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Tutorial.recordTutorialKindness(
        kindnessContent: _kindnessContent,
        selectedGender: _selectedGender,
        selectedRelation: _selectedRelation,
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
      await Tutorial.completeReflectionSettings(
        selectedReflectionFrequency: _selectedReflectionFrequency,
      );

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

      await Tutorial.completeTutorial(
        kindnessGiverName: _kindnessGiverName,
        selectedGender: _selectedGender,
        selectedRelation: _selectedRelation,
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
  String getFrequencyDescription(String frequency) {
    return Tutorial.getFrequencyDescription(frequency);
  }
}
