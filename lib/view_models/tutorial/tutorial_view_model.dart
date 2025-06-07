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
    if (state.currentPage < 2) {
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
      case '友人':
        return 2;
      case '恋人':
        return 3;
      case '同僚':
        return 4;
      case 'その他':
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
