// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../models/tutorial_model.dart';

/// チュートリアルのViewModel
class TutorialViewModel extends ChangeNotifier {
  // 状態プロパティ
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

  // チュートリアルページ関連の定数
  static const int totalPages = 4;
  static const int firstPageIndex = 0;
  static const int lastPageIndex = 3;
  static const int introductionPageIndex = 0;
  static const int memberRegistrationPageIndex = 1;
  static const int kindnessRecordPageIndex = 2;
  static const int reflectionSettingPageIndex = 3;

  // アニメーション関連の定数
  static const int pageAnimationDurationMs = 300;

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

  Future<bool> saveReflectionSettings() async {
    _isSettingReflection = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Tutorial.saveReflectionSettings(
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

  /// 現在のページに応じたボタンテキストを取得
  String getNextButtonText() {
    switch (_currentPage) {
      case introductionPageIndex:
        return '次へ';
      case memberRegistrationPageIndex:
        return '次へ';
      case kindnessRecordPageIndex:
        return '記録して次へ';
      case reflectionSettingPageIndex:
        return 'チュートリアル完了';
      default:
        return '次へ';
    }
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
    switch (_currentPage) {
      case memberRegistrationPageIndex:
        return _isCompleting;
      case kindnessRecordPageIndex:
        return _isRecordingKindness;
      case reflectionSettingPageIndex:
        return _isSettingReflection || _isCompleting;
      default:
        return false;
    }
  }

  /// 次へボタンが無効かどうか
  bool isNextButtonDisabled() {
    switch (_currentPage) {
      case memberRegistrationPageIndex:
        return _kindnessGiverName.trim().isEmpty || _isCompleting;
      case kindnessRecordPageIndex:
        return _isRecordingKindness;
      case reflectionSettingPageIndex:
        return _isSettingReflection || _isCompleting;
      default:
        return false;
    }
  }

  /// スキップアクションを実行
  void executeSkipAction() {
    if (_currentPage == kindnessRecordPageIndex) {
      // 優しさ記録をスキップして次のページへ
      nextPage();
    }
  }

  /// 次へアクションを実行
  Future<String> executeNextAction() async {
    switch (_currentPage) {
      case introductionPageIndex:
        nextPage();
        return 'next_page';
      case memberRegistrationPageIndex:
        final success = await completeTutorial();
        if (success) {
          nextPage();
          return 'next_page';
        }
        return 'error';
      case kindnessRecordPageIndex:
        final success = await recordKindness();
        if (success) {
          nextPage();
          return 'next_page';
        }
        return 'error';
      case reflectionSettingPageIndex:
        final success = await saveReflectionSettings();
        if (success) {
          return 'navigate_to_main';
        }
        return 'error';
      default:
        return 'error';
    }
  }

  /// 頻度の説明文を取得
  String getFrequencyDescription(String frequency) {
    return Tutorial.getFrequencyDescription(frequency);
  }
}
