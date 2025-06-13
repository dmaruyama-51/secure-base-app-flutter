import 'package:flutter/foundation.dart';
import '../../models/kindness_giver.dart';
import '../../models/kindness_record.dart';
import '../../repositories/kindness_giver_repository.dart';
import '../../repositories/kindness_record_repository.dart';
import '../../states/kindness_record/kindness_record_edit_state.dart';

/// やさしさ記録編集のViewModel（Provider対応版）
class KindnessRecordEditViewModel extends ChangeNotifier {
  final KindnessGiverRepository _kindnessGiverRepository;
  final KindnessRecordRepository _kindnessRecordRepository;
  KindnessRecordEditState _state = const KindnessRecordEditState();

  KindnessRecordEditViewModel()
    : _kindnessGiverRepository = KindnessGiverRepository(),
      _kindnessRecordRepository = KindnessRecordRepository();

  KindnessRecordEditState get state => _state;

  void _updateState(KindnessRecordEditState newState) {
    _state = newState;
    notifyListeners();
  }

  /// 編集対象の記録を初期化する
  Future<void> initializeRecord(KindnessRecord record) async {
    _updateState(
      _state.copyWith(
        originalRecord: record,
        content: record.content,
        selectedKindnessGiver: KindnessGiver(
          id: record.giverId,
          userId: record.userId,
          giverName: record.giverName,
          genderId: 1,
          relationshipId: 1,
          createdAt: DateTime.now(),
        ),
      ),
    );
    await loadMembers();
  }

  /// メンバー一覧を取得する
  Future<void> loadMembers() async {
    _updateState(_state.copyWith(isLoading: true, errorMessage: null));

    try {
      final kindnessGivers =
          await _kindnessGiverRepository.fetchKindnessGivers();
      _updateState(
        _state.copyWith(kindnessGivers: kindnessGivers, isLoading: false),
      );
    } catch (e) {
      _updateState(
        _state.copyWith(isLoading: false, errorMessage: 'メンバー取得に失敗しました'),
      );
    }
  }

  /// 内容を更新する
  void updateContent(String content) {
    _updateState(_state.copyWith(content: content));
  }

  /// メンバー選択時の処理
  void selectKindnessGiver(KindnessGiver? kindnessGiver) {
    _updateState(_state.copyWith(selectedKindnessGiver: kindnessGiver));
  }

  /// 入力バリデーション
  bool _validateInput() {
    if (_state.content.trim().isEmpty) {
      _updateState(_state.copyWith(errorMessage: '内容を入力してください'));
      return false;
    }
    if (_state.selectedKindnessGiver == null) {
      _updateState(_state.copyWith(errorMessage: '人物を選択してください'));
      return false;
    }
    if (_state.selectedKindnessGiver!.category.trim().isEmpty) {
      _updateState(_state.copyWith(errorMessage: '選択された人物のカテゴリが設定されていません'));
      return false;
    }
    if (_state.selectedKindnessGiver!.gender.trim().isEmpty) {
      _updateState(_state.copyWith(errorMessage: '選択された人物の性別が設定されていません'));
      return false;
    }
    return true;
  }

  /// やさしさ記録を更新する
  Future<void> updateKindnessRecord() async {
    if (!_validateInput() || _state.originalRecord == null) return;

    _updateState(
      _state.copyWith(isSaving: true, errorMessage: null, successMessage: null),
    );

    try {
      final now = DateTime.now();
      final updatedRecord = KindnessRecord(
        id: _state.originalRecord!.id,
        userId: _state.originalRecord!.userId,
        giverId: _state.selectedKindnessGiver!.id,
        content: _state.content.trim(),
        createdAt: _state.originalRecord!.createdAt,
        updatedAt: now,
        giverName: _state.selectedKindnessGiver!.name,
        giverAvatarUrl: _state.selectedKindnessGiver!.avatarUrl,
        giverCategory: _state.selectedKindnessGiver!.category,
        giverGender: _state.selectedKindnessGiver!.gender,
      );

      final result = await _kindnessRecordRepository.updateKindnessRecord(
        updatedRecord,
      );

      if (result) {
        _updateState(
          _state.copyWith(
            isSaving: false,
            successMessage: '記録を更新しました',
            shouldNavigateBack: true,
          ),
        );
      } else {
        _updateState(
          _state.copyWith(isSaving: false, errorMessage: '更新に失敗しました'),
        );
      }
    } catch (e) {
      _updateState(
        _state.copyWith(
          isSaving: false,
          errorMessage: 'エラーが発生しました: ${e.toString()}',
        ),
      );
    }
  }

  /// メッセージ類をクリアする
  void clearMessages() {
    _updateState(
      _state.copyWith(
        errorMessage: null,
        successMessage: null,
        shouldNavigateBack: false,
      ),
    );
  }
}
