// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import '../../models/kindness_giver.dart';
import '../../models/kindness_record.dart';
import '../../repositories/kindness_giver_repository.dart';
import '../../repositories/kindness_record_repository.dart';

/// やさしさ記録編集のViewModel
class KindnessRecordEditViewModel extends ChangeNotifier {
  final KindnessRecordRepository _repository;
  final KindnessGiverRepository _kindnessGiverRepository;

  // 状態プロパティ
  KindnessRecord? _originalRecord;
  List<KindnessGiver> _kindnessGivers = const [];
  KindnessGiver? _selectedKindnessGiver;
  String _content = '';
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;
  bool _shouldNavigateBack = false;

  KindnessRecordEditViewModel({required KindnessRecord originalRecord})
    : _repository = KindnessRecordRepository(),
      _kindnessGiverRepository = KindnessGiverRepository(),
      _originalRecord = originalRecord,
      _content = originalRecord.content;

  // ゲッター
  KindnessRecord? get originalRecord => _originalRecord;
  List<KindnessGiver> get kindnessGivers => _kindnessGivers;
  KindnessGiver? get selectedKindnessGiver => _selectedKindnessGiver;
  String get content => _content;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get shouldNavigateBack => _shouldNavigateBack;

  /// 初期化
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _kindnessGivers = await _kindnessGiverRepository.fetchKindnessGivers();

      // 元のレコードに対応するKindnessGiverを選択
      if (_originalRecord != null) {
        _selectedKindnessGiver = _kindnessGivers.firstWhere(
          (giver) => giver.id == _originalRecord!.giverId,
          orElse:
              () =>
                  _kindnessGivers.isNotEmpty
                      ? _kindnessGivers.first
                      : _kindnessGivers.first,
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'メンバー一覧の取得に失敗しました';
      notifyListeners();
    }
  }

  /// メンバーを選択
  void selectKindnessGiver(KindnessGiver kindnessGiver) {
    _selectedKindnessGiver = kindnessGiver;
    notifyListeners();
  }

  /// やさしさの内容を更新
  void updateContent(String content) {
    _content = content;
    notifyListeners();
  }

  /// やさしさ記録を更新
  Future<void> updateKindnessRecord() async {
    if (_content.trim().isEmpty) {
      _errorMessage = 'やさしさの内容を入力してください';
      notifyListeners();
      return;
    }

    if (_selectedKindnessGiver == null) {
      _errorMessage = 'メンバーを選択してください';
      notifyListeners();
      return;
    }

    if (_originalRecord == null) {
      _errorMessage = '編集対象のレコードが見つかりません';
      notifyListeners();
      return;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('ユーザーが認証されていません');
      }

      final updatedRecord = KindnessRecord(
        id: _originalRecord!.id,
        userId: user.id,
        giverId: _selectedKindnessGiver!.id,
        content: _content.trim(),
        createdAt: _originalRecord!.createdAt,
        updatedAt: DateTime.now(),
        giverName: _selectedKindnessGiver!.giverName,
        giverAvatarUrl: _selectedKindnessGiver!.avatarUrl,
        giverCategory: _selectedKindnessGiver!.relationshipName ?? '',
        giverGender: _selectedKindnessGiver!.genderName ?? '',
      );

      await _repository.updateKindnessRecord(updatedRecord);

      _isSaving = false;
      _successMessage = 'やさしさ記録を更新しました';
      _shouldNavigateBack = true;
      notifyListeners();
    } catch (e) {
      _isSaving = false;
      _errorMessage = 'やさしさ記録の更新に失敗しました: ${e.toString()}';
      notifyListeners();
    }
  }

  /// メッセージをクリア
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    _shouldNavigateBack = false;
    notifyListeners();
  }
}
