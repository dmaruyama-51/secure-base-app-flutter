import 'package:flutter/foundation.dart';
import '../../states/tutorial/tutorial_state.dart';
import '../../repositories/tutorial_repository.dart';
import '../../repositories/kindness_giver_repository.dart';
import '../../repositories/kindness_record_repository.dart';
import '../../models/kindness_giver.dart';
import '../../models/kindness_record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// チュートリアルのViewModel
class TutorialViewModel extends ChangeNotifier {
  final KindnessGiverRepository _kindnessGiverRepository;
  final TutorialRepository _tutorialRepository;
  final KindnessRecordRepository _kindnessRecordRepository;
  TutorialState _state = const TutorialState();

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

  TutorialState get state => _state;

  void _updateState(TutorialState newState) {
    _state = newState;
    notifyListeners();
  }

  void nextPage() {
    if (_state.currentPage < lastPageIndex) {
      _updateState(_state.copyWith(currentPage: _state.currentPage + 1));
    }
  }

  void previousPage() {
    if (_state.currentPage > firstPageIndex) {
      _updateState(_state.copyWith(currentPage: _state.currentPage - 1));
    }
  }

  void updateName(String name) {
    _updateState(_state.copyWith(kindnessGiverName: name));
  }

  void updateGender(String gender) {
    _updateState(_state.copyWith(selectedGender: gender));
  }

  void updateRelation(String relation) {
    _updateState(_state.copyWith(selectedRelation: relation));
  }

  void updateKindnessContent(String content) {
    _updateState(_state.copyWith(kindnessContent: content));
  }

  void updateReflectionFrequency(String frequency) {
    _updateState(_state.copyWith(selectedReflectionFrequency: frequency));
  }

  Future<bool> recordKindness() async {
    if (_state.kindnessContent.trim().isEmpty) {
      return true;
    }

    _updateState(
      _state.copyWith(isRecordingKindness: true, errorMessage: null),
    );

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
        content: _state.kindnessContent,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        giverName: kindnessGiver.giverName,
        giverAvatarUrl: kindnessGiver.avatarUrl,
        giverCategory:
            kindnessGiver.relationshipName ?? _state.selectedRelation,
        giverGender: kindnessGiver.genderName ?? _state.selectedGender,
      );

      await _kindnessRecordRepository.saveKindnessRecord(kindnessRecord);
      _updateState(_state.copyWith(isRecordingKindness: false));
      return true;
    } catch (e) {
      _updateState(
        _state.copyWith(
          isRecordingKindness: false,
          errorMessage: '優しさの記録に失敗しました: ${e.toString()}',
        ),
      );
      return false;
    }
  }

  Future<bool> saveReflectionSettings() async {
    _updateState(
      _state.copyWith(isSettingReflection: true, errorMessage: null),
    );

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('ユーザーが認証されていません');
      }

      await Future.delayed(Duration(milliseconds: _reflectionSaveDelayMs));
      print('リフレクション頻度を保存しました: ${_state.selectedReflectionFrequency}');

      _updateState(_state.copyWith(isSettingReflection: false));
      return true;
    } catch (e) {
      _updateState(
        _state.copyWith(
          isSettingReflection: false,
          errorMessage: 'リフレクション設定の保存に失敗しました: ${e.toString()}',
        ),
      );
      return false;
    }
  }

  Future<bool> completeTutorial() async {
    if (_state.kindnessGiverName.trim().isEmpty) {
      _updateState(_state.copyWith(errorMessage: '名前を入力してください'));
      return false;
    }

    _updateState(_state.copyWith(isCompleting: true, errorMessage: null));

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('ユーザーが認証されていません');
      }

      final genderId = await _kindnessGiverRepository.getGenderIdByName(
        _state.selectedGender,
      );
      final relationshipId = await _kindnessGiverRepository
          .getRelationshipIdByName(_state.selectedRelation);

      if (genderId == null) {
        throw Exception('選択された性別が見つかりません: ${_state.selectedGender}');
      }

      if (relationshipId == null) {
        throw Exception('選択された関係性が見つかりません: ${_state.selectedRelation}');
      }

      final kindnessGiver = KindnessGiver.create(
        userId: user.id,
        giverName: _state.kindnessGiverName,
        relationshipId: relationshipId,
        genderId: genderId,
      );

      await _kindnessGiverRepository.createKindnessGiver(kindnessGiver);
      await _tutorialRepository.markTutorialCompleted();

      _updateState(_state.copyWith(isCompleting: false));
      return true;
    } catch (e) {
      _updateState(
        _state.copyWith(
          isCompleting: false,
          errorMessage: 'メンバーの登録に失敗しました: ${e.toString()}',
        ),
      );
      return false;
    }
  }

  void clearError() {
    _updateState(_state.copyWith(errorMessage: null));
  }

  /// 現在のページに応じたボタンテキストを取得
  String getNextButtonText() {
    switch (_state.currentPage) {
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
    return _state.currentPage > firstPageIndex;
  }

  /// 次へボタンを表示するかどうか
  bool shouldShowNextButton() {
    return _state.currentPage <= lastPageIndex;
  }

  /// スキップボタンを表示するかどうか
  bool shouldShowSkipButton() {
    return _state.currentPage == kindnessRecordPageIndex;
  }

  /// 次へボタンが無効かどうか
  bool isNextButtonDisabled() {
    switch (_state.currentPage) {
      case memberRegistrationPageIndex:
        return _state.kindnessGiverName.trim().isEmpty || _state.isCompleting;
      case kindnessRecordPageIndex:
        return _state.isRecordingKindness;
      case reflectionSettingPageIndex:
        return _state.isSettingReflection || _state.isCompleting;
      default:
        return false;
    }
  }

  /// スキップアクションを実行
  void executeSkipAction() {
    if (_state.currentPage == kindnessRecordPageIndex) {
      // 優しさ記録をスキップして次のページへ
      nextPage();
    }
  }

  /// 次へアクションを実行
  Future<String> executeNextAction() async {
    switch (_state.currentPage) {
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
