import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../repositories/kindness_record_repository.dart';
import '../../repositories/kindness_giver_repository.dart';
import '../../models/kindness_giver.dart';
import '../../models/kindness_record.dart';

/// やさしさ記録追加のViewModel
class KindnessRecordAddViewModel extends ChangeNotifier {
  final KindnessRecordRepository _repository;
  final KindnessGiverRepository _kindnessGiverRepository;

  // 状態プロパティ
  List<KindnessGiver> _kindnessGivers = const [];
  KindnessGiver? _selectedKindnessGiver;
  String _content = '';
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;
  bool _shouldNavigateBack = false;

  KindnessRecordAddViewModel()
    : _repository = KindnessRecordRepository(),
      _kindnessGiverRepository = KindnessGiverRepository();

  // ゲッター
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
      if (_kindnessGivers.isNotEmpty) {
        _selectedKindnessGiver = _kindnessGivers.first;
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

  /// やさしさ記録を保存
  Future<void> saveKindnessRecord() async {
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

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('ユーザーが認証されていません');
      }

      final kindnessRecord = KindnessRecord(
        userId: user.id,
        giverId: _selectedKindnessGiver!.id,
        content: _content.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        giverName: _selectedKindnessGiver!.giverName,
        giverAvatarUrl: _selectedKindnessGiver!.avatarUrl,
        giverCategory: _selectedKindnessGiver!.relationshipName ?? '',
        giverGender: _selectedKindnessGiver!.genderName ?? '',
      );

      await _repository.saveKindnessRecord(kindnessRecord);

      _isSaving = false;
      _successMessage = 'やさしさ記録を保存しました';
      _shouldNavigateBack = true;
      notifyListeners();
    } catch (e) {
      _isSaving = false;
      _errorMessage = 'やさしさ記録の保存に失敗しました: ${e.toString()}';
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
