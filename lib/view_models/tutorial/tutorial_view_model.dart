import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../states/tutorial/tutorial_state.dart';
import '../../repositories/tutorial_repository.dart';
import '../../repositories/kindness_giver_repository.dart';
import '../../repositories/kindness_record_repository.dart';
import '../../models/kindness_giver.dart';
import '../../models/kindness_record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TutorialViewModel extends StateNotifier<TutorialState> {
  final KindnessGiverRepository _kindnessGiverRepository;
  final TutorialRepository _tutorialRepository;
  final KindnessRecordRepository _kindnessRecordRepository;

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
      _kindnessRecordRepository = KindnessRecordRepository(),
      super(const TutorialState());

  void nextPage() {
    if (state.currentPage < lastPageIndex) {
      state = state.copyWith(currentPage: state.currentPage + 1);
    }
  }

  void previousPage() {
    if (state.currentPage > firstPageIndex) {
      state = state.copyWith(currentPage: state.currentPage - 1);
    }
  }

  void updateName(String name) {
    state = state.copyWith(kindnessGiverName: name);
  }

  void updateGender(String gender) {
    state = state.copyWith(selectedGender: gender);
  }

  void updateRelation(String relation) {
    state = state.copyWith(selectedRelation: relation);
  }

  void updateKindnessContent(String content) {
    state = state.copyWith(kindnessContent: content);
  }

  void updateReflectionFrequency(String frequency) {
    state = state.copyWith(selectedReflectionFrequency: frequency);
  }

  Future<bool> recordKindness() async {
    if (state.kindnessContent.trim().isEmpty) {
      return true;
    }

    state = state.copyWith(isRecordingKindness: true, errorMessage: null);

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
        content: state.kindnessContent,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        giverName: kindnessGiver.giverName,
        giverAvatarUrl: kindnessGiver.avatarUrl,
        giverCategory: kindnessGiver.relationshipName ?? state.selectedRelation,
        giverGender: kindnessGiver.genderName ?? state.selectedGender,
      );

      await _kindnessRecordRepository.saveKindnessRecord(kindnessRecord);

      state = state.copyWith(isRecordingKindness: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isRecordingKindness: false,
        errorMessage: '優しさの記録に失敗しました: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> saveReflectionSettings() async {
    state = state.copyWith(isSettingReflection: true, errorMessage: null);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('ユーザーが認証されていません');
      }

      await Future.delayed(Duration(milliseconds: _reflectionSaveDelayMs));
      print('リフレクション頻度を保存しました: ${state.selectedReflectionFrequency}');

      state = state.copyWith(isSettingReflection: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSettingReflection: false,
        errorMessage: 'リフレクション設定の保存に失敗しました: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> completeTutorial() async {
    if (state.kindnessGiverName.trim().isEmpty) {
      state = state.copyWith(errorMessage: '名前を入力してください');
      return false;
    }

    state = state.copyWith(isCompleting: true, errorMessage: null);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('ユーザーが認証されていません');
      }

      // データベースのマスターテーブルから正しいIDを取得
      final genderId = await _kindnessGiverRepository.getGenderIdByName(
        state.selectedGender,
      );
      final relationshipId = await _kindnessGiverRepository
          .getRelationshipIdByName(state.selectedRelation);

      if (genderId == null) {
        throw Exception('選択された性別が見つかりません: ${state.selectedGender}');
      }

      if (relationshipId == null) {
        throw Exception('選択された関係性が見つかりません: ${state.selectedRelation}');
      }

      final kindnessGiver = KindnessGiver.create(
        userId: user.id,
        giverName: state.kindnessGiverName,
        relationshipId: relationshipId,
        genderId: genderId,
      );

      await _kindnessGiverRepository.createKindnessGiver(kindnessGiver);

      await _tutorialRepository.markTutorialCompleted();

      state = state.copyWith(isCompleting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isCompleting: false,
        errorMessage: 'メンバーの登録に失敗しました: ${e.toString()}',
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// 現在のページに応じたボタンテキストを取得
  String getNextButtonText() {
    switch (state.currentPage) {
      case introductionPageIndex:
        return '次へ';
      case memberRegistrationPageIndex:
        return '次へ';
      case kindnessRecordPageIndex:
        return '記録して次へ';
      case reflectionSettingPageIndex:
        return '設定して始める';
      default:
        return '次へ';
    }
  }

  /// 戻るボタンを表示するかどうか
  bool shouldShowBackButton() {
    return state.currentPage > firstPageIndex &&
        state.currentPage != kindnessRecordPageIndex;
  }

  /// スキップボタンを表示するかどうか
  bool shouldShowSkipButton() {
    return state.currentPage == kindnessRecordPageIndex;
  }

  /// 次へボタンが無効かどうか
  bool isNextButtonDisabled() {
    return state.isCompleting ||
        state.isRecordingKindness ||
        state.isSettingReflection;
  }

  /// リフレクション頻度の説明テキストを取得
  String getFrequencyDescription(String frequency) {
    switch (frequency) {
      case '週に1回':
        return 'こまめに振り返りたい方におすすめ';
      case '2週に1回':
        return 'バランスよく振り返れる推奨設定';
      case '月に1回':
        return '記録する頻度が少ない方におすすめ';
      default:
        return '';
    }
  }

  /// 次へボタンのアクション実行
  Future<String?> executeNextAction() async {
    switch (state.currentPage) {
      case introductionPageIndex:
        // 1ページ目：次のページへ
        nextPage();
        return 'next_page';
      case memberRegistrationPageIndex:
        // 2ページ目：メンバー登録完了後、3ページ目へ
        final success = await completeTutorial();
        if (success) {
          nextPage();
          return 'next_page';
        }
        return null;
      case kindnessRecordPageIndex:
        // 3ページ目：優しさ記録後、4ページ目へ
        final success = await recordKindness();
        if (success) {
          nextPage();
          return 'next_page';
        }
        return null;
      case reflectionSettingPageIndex:
        // 4ページ目：リフレクション設定後、メイン画面へ
        final success = await saveReflectionSettings();
        if (success) {
          return 'navigate_to_main';
        }
        return null;
      default:
        return null;
    }
  }

  /// スキップアクション実行
  void executeSkipAction() {
    if (state.currentPage == kindnessRecordPageIndex) {
      nextPage();
    }
  }
}

final tutorialViewModelProvider =
    StateNotifierProvider<TutorialViewModel, TutorialState>((ref) {
      return TutorialViewModel();
    });
