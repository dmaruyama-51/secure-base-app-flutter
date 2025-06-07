import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../states/tutorial/tutorial_state.dart';
import '../../repositories/tutorial_repository.dart';
import '../../repositories/kindness_giver_repository.dart';
import '../../repositories/kindness_record_repository.dart';
import '../../models/kindness_giver.dart';
import '../../models/kindness_record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/kindness_giver/kindness_giver_providers.dart';
import '../../providers/kindness_record/kindness_record_providers.dart';
import '../../providers/tutorial_providers.dart';

class TutorialViewModel extends StateNotifier<TutorialState> {
  final KindnessGiverRepository _kindnessGiverRepository;
  final TutorialRepository _tutorialRepository;
  final KindnessRecordRepository _kindnessRecordRepository;

  TutorialViewModel({
    required KindnessGiverRepository kindnessGiverRepository,
    required TutorialRepository tutorialRepository,
    required KindnessRecordRepository kindnessRecordRepository,
  }) : _kindnessGiverRepository = kindnessGiverRepository,
       _tutorialRepository = tutorialRepository,
       _kindnessRecordRepository = kindnessRecordRepository,
       super(const TutorialState());

  void nextPage() {
    if (state.currentPage < 3) {
      state = state.copyWith(currentPage: state.currentPage + 1);
    }
  }

  void previousPage() {
    if (state.currentPage > 0) {
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

      await Future.delayed(const Duration(milliseconds: 500));
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

      final kindnessGiver = KindnessGiver.create(
        userId: user.id,
        giverName: state.kindnessGiverName,
        relationshipId: _getRelationshipId(state.selectedRelation),
        genderId: _getGenderId(state.selectedGender),
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
      case 0:
        return '次へ';
      case 1:
        return '次へ';
      case 2:
        return '記録して次へ';
      case 3:
        return '設定して始める';
      default:
        return '次へ';
    }
  }

  /// 戻るボタンを表示するかどうか
  bool shouldShowBackButton() {
    return state.currentPage > 0 && state.currentPage != 2;
  }

  /// スキップボタンを表示するかどうか
  bool shouldShowSkipButton() {
    return state.currentPage == 2;
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
      case 0:
        // 1ページ目：次のページへ
        nextPage();
        return 'next_page';
      case 1:
        // 2ページ目：メンバー登録完了後、3ページ目へ
        final success = await completeTutorial();
        if (success) {
          nextPage();
          return 'next_page';
        }
        return null;
      case 2:
        // 3ページ目：優しさ記録後、4ページ目へ
        final success = await recordKindness();
        if (success) {
          nextPage();
          return 'next_page';
        }
        return null;
      case 3:
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
    if (state.currentPage == 2) {
      nextPage();
    }
  }

  int _getGenderId(String gender) {
    switch (gender) {
      case '男性':
        return 1;
      case '女性':
        return 2;
      case 'その他':
        return 3;
      default:
        return 2; // デフォルトは女性
    }
  }

  int _getRelationshipId(String relation) {
    switch (relation) {
      case '家族':
        return 1;
      case '友達':
        return 2;
      case 'パートナー':
        return 3;
      case 'ペット':
        return 4;
      case '会社の人':
        return 5;
      default:
        return 1; // デフォルトは家族
    }
  }
}

final tutorialViewModelProvider =
    StateNotifierProvider<TutorialViewModel, TutorialState>((ref) {
      final kindnessGiverRepository = ref.read(kindnessGiverRepositoryProvider);
      final tutorialRepository = ref.read(tutorialRepositoryProvider);
      final kindnessRecordRepository = ref.read(
        kindnessRecordRepositoryProvider,
      );
      return TutorialViewModel(
        kindnessGiverRepository: kindnessGiverRepository,
        tutorialRepository: tutorialRepository,
        kindnessRecordRepository: kindnessRecordRepository,
      );
    });
