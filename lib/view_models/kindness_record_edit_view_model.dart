import 'package:flutter/material.dart';
import '../models/member.dart';
import '../models/kindness_record.dart';
import '../repositories/member_repository.dart';
import '../repositories/kindness_record_repository.dart';
import 'package:collection/collection.dart';

// やさしさ記録編集ページ用のViewModel
class KindnessRecordEditViewModel extends ChangeNotifier {
  // メンバー取得用リポジトリ
  final MemberRepository _memberRepository;
  // やさしさ記録保存用リポジトリ
  final KindnessRecordRepository _kindnessRecordRepository;

  // 編集対象のレコードID
  final int recordId;
  // 編集対象のレコード
  KindnessRecord? kindnessRecord;

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
  // データ読み込み中フラグ
  bool isLoading = true;
  // 保存成功時に画面を戻すかどうか
  bool shouldNavigateBack = false;

  // コンストラクタ。リポジトリのDI対応
  KindnessRecordEditViewModel({
    required this.recordId,
    MemberRepository? memberRepository,
    KindnessRecordRepository? kindnessRecordRepository,
  })  : _memberRepository = memberRepository ?? MemberRepository(),
        _kindnessRecordRepository = kindnessRecordRepository ?? KindnessRecordRepository();

  // 初期データを読み込む
  Future<void> loadInitialData() async {
    try {
      isLoading = true;
      notifyListeners();

      // メンバー一覧とレコードデータを並行して取得
      final results = await Future.wait([
        _memberRepository.fetchMembers(),
        _kindnessRecordRepository.fetchKindnessRecordById(recordId),
      ]);

      members = results[0] as List<Member>;
      kindnessRecord = results[1] as KindnessRecord?;

      if (kindnessRecord == null) {
        errorMessage = 'レコードが見つかりませんでした';
      } else {
        // フォームに既存データを設定
        contentController.text = kindnessRecord!.content;
        selectedMemberName = kindnessRecord!.giverName;
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = 'データの読み込みに失敗しました';
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

  // やさしさ記録を更新する
  Future<void> updateKindnessRecord() async {
    if (!_validateInput() || kindnessRecord == null) return;
    
    try {
      isSaving = true;
      notifyListeners();

      final updatedRecord = KindnessRecord(
        id: kindnessRecord!.id,
        userId: kindnessRecord!.userId,
        giverId: kindnessRecord!.giverId,
        content: contentController.text.trim(),
        createdAt: kindnessRecord!.createdAt,
        updatedAt: DateTime.now(),
        giverName: selectedMember!.name,
        giverAvatarUrl: selectedMember!.avatarUrl,
      );

      final result = await _kindnessRecordRepository.updateKindnessRecord(updatedRecord);
      
      if (result) {
        successMessage = '記録を更新しました';
        shouldNavigateBack = true;
      } else {
        errorMessage = '更新に失敗しました';
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