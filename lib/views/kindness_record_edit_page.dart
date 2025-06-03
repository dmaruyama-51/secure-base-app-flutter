import 'package:flutter/material.dart';
import '../view_models/kindness_record_edit_view_model.dart';

// やさしさ記録編集ページの画面Widget
class KindnessRecordEditPage extends StatefulWidget {
  final int recordId;

  const KindnessRecordEditPage({
    Key? key,
    required this.recordId,
  }) : super(key: key);

  @override
  State<KindnessRecordEditPage> createState() => _KindnessRecordEditPageState();
}

// やさしさ記録編集ページの状態管理クラス
class _KindnessRecordEditPageState extends State<KindnessRecordEditPage> {
  late KindnessRecordEditViewModel _viewModel;

  // 初期化処理。ViewModelの生成と初期データの取得を行う。
  @override
  void initState() {
    super.initState();
    _viewModel = KindnessRecordEditViewModel(recordId: widget.recordId);
    _viewModel.loadInitialData();
  }

  // リソース解放処理。ViewModelのdisposeを呼ぶ。
  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  // 画面のUI構築処理
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, child) {
          // エラーメッセージがあればSnackBarで表示
          if (_viewModel.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_viewModel.errorMessage!)),
              );
              _viewModel.clearMessages();
            });
          }
          // 成功メッセージがあればSnackBarで表示し、必要なら画面を戻す
          if (_viewModel.successMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_viewModel.successMessage!)),
              );
              if (_viewModel.shouldNavigateBack) {
                Navigator.of(context).pop();
              }
              _viewModel.clearMessages();
            });
          }

          // データ読み込み中の表示
          if (_viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // メインUI部分
          return SingleChildScrollView(
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
                  controller: _viewModel.contentController,
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
                      value: _viewModel.selectedKindnessGiverName,
                      hint: Text('人物を選択', style: theme.textTheme.bodyMedium),
                      items: _viewModel.kindnessGivers.map((kindnessGiver) {
                        return DropdownMenuItem<String>(
                          value: kindnessGiver.name,
                          child: Text(kindnessGiver.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        _viewModel.selectKindnessGiver(value);
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
                    onPressed: _viewModel.isSaving ? null : _viewModel.updateKindnessRecord,
                    child: _viewModel.isSaving
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
          );
        },
      ),
    );
  }
} 