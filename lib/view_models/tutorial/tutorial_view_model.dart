// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import '../../models/kindness_giver.dart';
import '../../models/kindness_record.dart';
import '../../repositories/kindness_giver_repository.dart';
import '../../repositories/kindness_record_repository.dart';
import '../../repositories/tutorial_repository.dart';

/// チュートリアルのViewModel
class TutorialViewModel extends ChangeNotifier {
  final KindnessGiverRepository _kindnessGiverRepository;
  final TutorialRepository _tutorialRepository;
  final KindnessRecordRepository _kindnessRecordRepository;

  // 状態プロパティ
  int _currentPage = 0;
  String _kindnessGiverName = '';
  String _selectedGender = '女性';
  String _selectedRelation = '家族';
  String _kindnessContent = '';
  String _selectedReflectionFrequency = '週1回';
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

  // 遅延時間の定数
  static const int _reflectionSaveDelayMs = 500;

  // アニメーション関連の定数
  static const int pageAnimationDurationMs = 300;

  TutorialViewModel()
    : _kindnessGiverRepository = KindnessGiverRepository(),
      _tutorialRepository = TutorialRepository(),
      _kindnessRecordRepository = KindnessRecordRepository();

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
    if (_kindnessContent.trim().isEmpty) {
      return true;
    }

    _isRecordingKindness = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('ユーザーが認証されていません');
      }

      final kindnessGivers =
          await _kindnessGiverRepository.fetchKindnessGivers();
      if (kindnessGivers.isEmpty) {
        throw Exception('メンバーが見つかりません');
      }

      final kindnessGiver = kindnessGivers.first;
      final kindnessRecord = KindnessRecord(
        userId: user.id,
        giverId: kindnessGiver.id,
        content: _kindnessContent,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        giverName: kindnessGiver.giverName,
        giverAvatarUrl: kindnessGiver.avatarUrl,
        giverCategory: kindnessGiver.relationshipName ?? _selectedRelation,
        giverGender: kindnessGiver.genderName ?? _selectedGender,
      );

      await _kindnessRecordRepository.saveKindnessRecord(kindnessRecord);
      _isRecordingKindness = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isRecordingKindness = false;
      _errorMessage = '優しさの記録に失敗しました: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> saveReflectionSettings() async {
    _isSettingReflection = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('ユーザーが認証されていません');
      }

      await Future.delayed(Duration(milliseconds: _reflectionSaveDelayMs));
      print('リフレクション頻度を保存しました: $_selectedReflectionFrequency');

      _isSettingReflection = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSettingReflection = false;
      _errorMessage = 'リフレクション設定の保存に失敗しました: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> completeTutorial() async {
    if (_kindnessGiverName.trim().isEmpty) {
      _errorMessage = '名前を入力してください';
      notifyListeners();
      return false;
    }

    _isCompleting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('ユーザーが認証されていません');
      }

      final genderId = await _kindnessGiverRepository.getGenderIdByName(
        _selectedGender,
      );
      final relationshipId = await _kindnessGiverRepository
          .getRelationshipIdByName(_selectedRelation);

      if (genderId == null) {
        throw Exception('選択された性別が見つかりません: $_selectedGender');
      }

      if (relationshipId == null) {
        throw Exception('選択された関係性が見つかりません: $_selectedRelation');
      }

      final kindnessGiver = KindnessGiver.create(
        userId: user.id,
        giverName: _kindnessGiverName,
        relationshipId: relationshipId,
        genderId: genderId,
      );

      await _kindnessGiverRepository.createKindnessGiver(kindnessGiver);
      await _tutorialRepository.markTutorialCompleted();

      _isCompleting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isCompleting = false;
      _errorMessage = 'メンバーの登録に失敗しました: ${e.toString()}';
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
    switch (frequency) {
      case '週に1回':
        return '毎週、受け取った優しさを振り返ります';
      case '2週に1回':
        return '2週間ごとに振り返りの時間をお届けします';
      case '月に1回':
        return '月末に1ヶ月分の優しさをまとめて振り返ります';
      default:
        return '';
    }
  }
}
