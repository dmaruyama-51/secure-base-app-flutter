import 'package:flutter/foundation.dart';
import '../../models/kindness_giver.dart';
import '../../models/kindness_record.dart';
import '../../repositories/kindness_giver_repository.dart';
import '../../repositories/kindness_record_repository.dart';
import '../../states/kindness_record/kindness_record_add_state.dart';

/// やさしさ記録追加のViewModel
class KindnessRecordAddViewModel extends ChangeNotifier {
  final KindnessGiverRepository _kindnessGiverRepository;
  final KindnessRecordRepository _kindnessRecordRepository;
  KindnessRecordAddState _state = const KindnessRecordAddState();

  KindnessRecordAddViewModel()
    : _kindnessGiverRepository = KindnessGiverRepository(),
      _kindnessRecordRepository = KindnessRecordRepository();

  KindnessRecordAddState get state => _state;

  void _updateState(KindnessRecordAddState newState) {
    _state = newState;
    notifyListeners();
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

  /// やさしさ記録を保存する
  Future<void> saveKindnessRecord() async {
    if (!_validateInput()) return;

    _updateState(
      _state.copyWith(isSaving: true, errorMessage: null, successMessage: null),
    );

    try {
      final now = DateTime.now();
      final record = KindnessRecord(
        userId: 'temp_user_id',
        giverId: _state.selectedKindnessGiver!.id,
        content: _state.content.trim(),
        createdAt: now,
        updatedAt: now,
        giverName: _state.selectedKindnessGiver!.name,
        giverAvatarUrl: _state.selectedKindnessGiver!.avatarUrl,
        giverCategory: _state.selectedKindnessGiver!.category,
        giverGender: _state.selectedKindnessGiver!.gender,
      );

      final result = await _kindnessRecordRepository.saveKindnessRecord(record);

      if (result) {
        _updateState(
          _state.copyWith(
            isSaving: false,
            successMessage: '記録を保存しました',
            shouldNavigateBack: true,
          ),
        );
      } else {
        _updateState(
          _state.copyWith(isSaving: false, errorMessage: '保存に失敗しました'),
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
