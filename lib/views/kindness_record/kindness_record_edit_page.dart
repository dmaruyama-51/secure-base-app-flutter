import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/kindness_record.dart';
import '../../view_models/kindness_record/kindness_record_edit_view_model.dart';

// やさしさ記録編集ページの画面Widget
class KindnessRecordEditPage extends ConsumerStatefulWidget {
  final KindnessRecord record;

  const KindnessRecordEditPage({
    super.key,
    required this.record,
  });

  @override
  ConsumerState<KindnessRecordEditPage> createState() => _KindnessRecordEditPageState();
}

// やさしさ記録編集ページの状態管理クラス
class _KindnessRecordEditPageState extends ConsumerState<KindnessRecordEditPage> {
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 初期化処理をpostFrameCallbackで実行
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(kindnessRecordEditViewModelProvider.notifier)
          .initializeRecord(widget.record);
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(kindnessRecordEditViewModelProvider);
    final viewModel = ref.read(kindnessRecordEditViewModelProvider.notifier);
    final theme = Theme.of(context);

    // content の同期
    if (_contentController.text != state.content) {
      _contentController.text = state.content;
    }

    // エラーメッセージがあればSnackBarで表示
    if (state.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.errorMessage!)),
        );
        viewModel.clearMessages();
      });
    }
    // 成功メッセージがあればSnackBarで表示し、必要なら画面を戻す
    if (state.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.successMessage!)),
        );
        if (state.shouldNavigateBack) {
          Navigator.of(context).pop();
        }
        viewModel.clearMessages();
      });
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // タイトル
                  Text(
                    'どんなやさしさを受け取りましたか？',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  // やさしさ内容入力欄
                  TextField(
                    controller: _contentController,
                    minLines: 4,
                    maxLines: 6,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      hintText: '',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    onChanged: viewModel.updateContent,
                  ),
                  const SizedBox(height: 16),
                  // メンバー選択用セレクトボックス
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: state.selectedKindnessGiver?.name,
                        hint: Text('人物を選択', style: theme.textTheme.bodyMedium),
                        items: state.kindnessGivers.map((kindnessGiver) {
                          return DropdownMenuItem<String>(
                            value: kindnessGiver.name,
                            child: Text(kindnessGiver.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          final selectedGiver = state.kindnessGivers
                              .where((giver) => giver.name == value)
                              .firstOrNull;
                          viewModel.selectKindnessGiver(selectedGiver);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // 保存ボタン
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: state.isSaving ? null : viewModel.updateKindnessRecord,
                      child: state.isSaving
                          ? CircularProgressIndicator(color: theme.colorScheme.onPrimary)
                          : Text(
                              'Save',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
} 