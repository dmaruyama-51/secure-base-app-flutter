import 'package:flutter/material.dart';
import '../models/member.dart';
import '../models/kindness_record.dart';
import '../repositories/member_repository.dart';
import '../repositories/kindness_record_repository.dart';
import 'package:collection/collection.dart';

// やさしさ記録追加ページ用のViewModel
class KindnessRecordAddViewModel extends ChangeNotifier {
  // メンバー取得用リポジトリ
  final MemberRepository _memberRepository;
  // やさしさ記録保存用リポジトリ
  final KindnessRecordRepository _kindnessRecordRepository;

  // メンバー一覧
  List<Member> members = [];
  // 選択中のメンバー名
  String? selectedMemberName;
  // 選択中のメンバー（null許容）
  Member? get selectedMember =>
      members.firstWhereOrNull((m) => m.name == selectedMemberName);
  // やさしさ内容入力用コントローラ
  final TextEditingController contentController = TextEditingController();

  // エラーメッセージ
  String? errorMessage;
  // 成功メッセージ
  String? successMessage;
  // 保存中フラグ
  bool isSaving = false;
  // 保存成功時に画面を戻すかどうか
  bool shouldNavigateBack = false;

  // コンストラクタ。リポジトリのDI対応
  KindnessRecordAddViewModel({
    MemberRepository? memberRepository,
    KindnessRecordRepository? kindnessRecordRepository,
  })  : _memberRepository = memberRepository ?? MemberRepository(),
        _kindnessRecordRepository = kindnessRecordRepository ?? KindnessRecordRepository();

  // メンバー一覧を取得する
  Future<void> loadMembers() async {
    try {
      members = await _memberRepository.fetchMembers();
      notifyListeners();
    } catch (e) {
      errorMessage = 'メンバー取得に失敗しました';
      notifyListeners();
    }
  }

  // メンバー選択時の処理
  void selectMember(String? name) {
    selectedMemberName = name;
    notifyListeners();
  }

  // 入力バリデーション
  bool _validateInput() {
    if (contentController.text.trim().isEmpty) {
      errorMessage = '内容を入力してください';
      notifyListeners();
      return false;
    }
    if (selectedMember == null) {
      errorMessage = '人物を選択してください';
      notifyListeners();
      return false;
    }
    errorMessage = null;
    notifyListeners();
    return true;
  }

  // やさしさ記録を保存する
  Future<void> saveKindnessRecord() async {
    if (!_validateInput()) return;
    try {
      isSaving = true;
      notifyListeners();
      final now = DateTime.now();
      final record = KindnessRecord(
        // TODO: 入力値やリポジトリから取得したデータを使用する
        userId: 1,
        giverId: 1,
        content: contentController.text.trim(),
        createdAt: now,
        updatedAt: now,
        giverName: selectedMember?.name ?? '',
        giverAvatarUrl: selectedMember?.avatarUrl,
      );
      final result = await _kindnessRecordRepository.saveKindnessRecord(record);
      if (result) {
        successMessage = '記録を保存しました';
        shouldNavigateBack = true;
      } else {
        errorMessage = '保存に失敗しました';
      }
    } catch (e) {
      errorMessage = 'エラーが発生しました: ${e.toString()}';
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  // メッセージ類をクリアする
  void clearMessages() {
    errorMessage = null;
    successMessage = null;
    shouldNavigateBack = false;
    notifyListeners();
  }

  // リソース解放処理。TextEditingControllerのdisposeが必要なため必ず呼ぶこと。
  // TextEditingControllerなどのリソースはメモリリーク防止のため明示的にdisposeする必要がある。
  @override
  void dispose() {
    contentController.dispose();
    super.dispose();
  }
} 