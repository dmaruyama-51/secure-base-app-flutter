import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/kindness_giver.dart';
import '../../models/kindness_record.dart';
import '../../repositories/kindness_giver_repository.dart';
import '../../repositories/kindness_record_repository.dart';
import '../../states/kindness_record/kindness_record_add_state.dart';
import '../../providers/kindness_record/kindness_record_providers.dart';
import '../../providers/kindness_giver/kindness_giver_providers.dart';

// StateNotifierベースのKindnessRecordAddViewModel
class KindnessRecordAddViewModel extends StateNotifier<KindnessRecordAddState> {
  final KindnessGiverRepository _kindnessGiverRepository;
  final KindnessRecordRepository _kindnessRecordRepository;

  // DIパターン：コンストラクタでRepositoryを受け取る
  KindnessRecordAddViewModel({
    required KindnessGiverRepository kindnessGiverRepository,
    required KindnessRecordRepository kindnessRecordRepository,
  })  : _kindnessGiverRepository = kindnessGiverRepository,
        _kindnessRecordRepository = kindnessRecordRepository,
        super(const KindnessRecordAddState());

  // メンバー一覧を取得する
  Future<void> loadMembers() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final kindnessGivers = await _kindnessGiverRepository.fetchKindnessGivers();
      state = state.copyWith(
        kindnessGivers: kindnessGivers,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'メンバー取得に失敗しました',
      );
    }
  }

  // 内容を更新する
  void updateContent(String content) {
    state = state.copyWith(content: content);
  }

  // メンバー選択時の処理
  void selectKindnessGiver(KindnessGiver? kindnessGiver) {
    state = state.copyWith(selectedKindnessGiver: kindnessGiver);
  }

  // 入力バリデーション
  bool _validateInput() {
    if (state.content.trim().isEmpty) {
      state = state.copyWith(errorMessage: '内容を入力してください');
      return false;
    }
    if (state.selectedKindnessGiver == null) {
      state = state.copyWith(errorMessage: '人物を選択してください');
      return false;
    }
    if (state.selectedKindnessGiver!.category.trim().isEmpty) {
      state = state.copyWith(errorMessage: '選択された人物のカテゴリが設定されていません');
      return false;
    }
    if (state.selectedKindnessGiver!.gender.trim().isEmpty) {
      state = state.copyWith(errorMessage: '選択された人物の性別が設定されていません');
      return false;
    }
    return true;
  }

  // やさしさ記録を保存する
  Future<void> saveKindnessRecord() async {
    if (!_validateInput()) return;

    state = state.copyWith(
      isSaving: true,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final now = DateTime.now();
      final record = KindnessRecord(
        // TODO: 実際のユーザーIDを使用する
        userId: 'temp_user_id',
        giverId: state.selectedKindnessGiver!.id,
        content: state.content.trim(),
        createdAt: now,
        updatedAt: now,
        giverName: state.selectedKindnessGiver!.name,
        giverAvatarUrl: state.selectedKindnessGiver!.avatarUrl,
        giverCategory: state.selectedKindnessGiver!.category,
        giverGender: state.selectedKindnessGiver!.gender,
      );

      final result = await _kindnessRecordRepository.saveKindnessRecord(record);
      
      if (result) {
        state = state.copyWith(
          isSaving: false,
          successMessage: '記録を保存しました',
          shouldNavigateBack: true,
        );
      } else {
        state = state.copyWith(
          isSaving: false,
          errorMessage: '保存に失敗しました',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'エラーが発生しました: ${e.toString()}',
      );
    }
  }

  // メッセージ類をクリアする
  void clearMessages() {
    state = state.copyWith(
      errorMessage: null,
      successMessage: null,
      shouldNavigateBack: false,
    );
  }
}

// ViewModelのProvider（DIで依存関係を注入）
final kindnessRecordAddViewModelProvider = 
    StateNotifierProvider<KindnessRecordAddViewModel, KindnessRecordAddState>(
  (ref) {
    // Repository Providerから依存関係を取得
    final kindnessGiverRepository = ref.read(kindnessGiverRepositoryProvider);
    final kindnessRecordRepository = ref.read(kindnessRecordRepositoryProvider);
    
    return KindnessRecordAddViewModel(
      kindnessGiverRepository: kindnessGiverRepository,
      kindnessRecordRepository: kindnessRecordRepository,
    );
  },
);
