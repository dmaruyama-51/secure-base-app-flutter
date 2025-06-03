import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/kindness_giver.dart';
import '../../models/kindness_record.dart';
import '../../repositories/kindness_giver_repository.dart';
import '../../repositories/kindness_record_repository.dart';
import '../../states/kindness_record/kindness_record_edit_state.dart';
import '../../providers/kindness_record/kindness_record_providers.dart';
import '../../providers/kindness_giver/kindness_giver_providers.dart';

// StateNotifierベースのKindnessRecordEditViewModel
class KindnessRecordEditViewModel extends StateNotifier<KindnessRecordEditState> {
  final KindnessGiverRepository _kindnessGiverRepository;
  final KindnessRecordRepository _kindnessRecordRepository;

  // DIパターン：コンストラクタでRepositoryを受け取る
  KindnessRecordEditViewModel({
    required KindnessGiverRepository kindnessGiverRepository,
    required KindnessRecordRepository kindnessRecordRepository,
  })  : _kindnessGiverRepository = kindnessGiverRepository,
        _kindnessRecordRepository = kindnessRecordRepository,
        super(const KindnessRecordEditState());

  // 編集対象の記録を初期化する
  Future<void> initializeRecord(KindnessRecord record) async {
    state = state.copyWith(
      originalRecord: record,
      content: record.content,
      selectedKindnessGiver: KindnessGiver(
        id: record.giverId,
        name: record.giverName,
        category: record.giverCategory,
        gender: record.giverGender,
        avatarUrl: record.giverAvatarUrl,
      ),
    );
    await loadMembers();
  }

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

  // やさしさ記録を更新する
  Future<void> updateKindnessRecord() async {
    if (!_validateInput() || state.originalRecord == null) return;

    state = state.copyWith(
      isSaving: true,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final now = DateTime.now();
      final updatedRecord = KindnessRecord(
        id: state.originalRecord!.id,
        userId: state.originalRecord!.userId,
        giverId: state.selectedKindnessGiver!.id,
        content: state.content.trim(),
        createdAt: state.originalRecord!.createdAt,
        updatedAt: now,
        giverName: state.selectedKindnessGiver!.name,
        giverAvatarUrl: state.selectedKindnessGiver!.avatarUrl,
        giverCategory: state.selectedKindnessGiver!.category,
        giverGender: state.selectedKindnessGiver!.gender,
      );

      final result = await _kindnessRecordRepository.updateKindnessRecord(updatedRecord);
      
      if (result) {
        state = state.copyWith(
          isSaving: false,
          successMessage: '記録を更新しました',
          shouldNavigateBack: true,
        );
      } else {
        state = state.copyWith(
          isSaving: false,
          errorMessage: '更新に失敗しました',
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
final kindnessRecordEditViewModelProvider = 
    StateNotifierProvider<KindnessRecordEditViewModel, KindnessRecordEditState>(
  (ref) {
    // Repository Providerから依存関係を取得
    final kindnessGiverRepository = ref.read(kindnessGiverRepositoryProvider);
    final kindnessRecordRepository = ref.read(kindnessRecordRepositoryProvider);
    
    return KindnessRecordEditViewModel(
      kindnessGiverRepository: kindnessGiverRepository,
      kindnessRecordRepository: kindnessRecordRepository,
    );
  },
); 