import 'package:flutter/material.dart';
import '../view_models/kindness_record_add_view_model.dart';
import '../repositories/kindness_giver_repository.dart';
import '../repositories/kindness_record_repository.dart';

// やさしさ記録追加ページの画面Widget
class KindnessRecordAddPage extends StatefulWidget {
  const KindnessRecordAddPage({Key? key}) : super(key: key);

  @override
  State<KindnessRecordAddPage> createState() => _KindnessRecordAddPageState();
}

// やさしさ記録追加ページの状態管理クラス
class _KindnessRecordAddPageState extends State<KindnessRecordAddPage> {
  late KindnessRecordAddViewModel _viewModel;

  // 初期化処理。ViewModelの生成とメンバー一覧の取得を行う。
  @override
  void initState() {
    super.initState();
    _viewModel = KindnessRecordAddViewModel();
    _viewModel.loadMembers();
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
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(_viewModel.errorMessage!)));
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
          // メインUI部分
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // タイトル
                Text(
                  'どんなやさしさを受け取りましたか？',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                // 例文表示ボックス
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '例：「仕事でミスしたときに励ましてくれた」\n「電車で席を譲ってくれた」',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _viewModel.selectedKindnessGiverName,
                      hint: Text('人物を選択', style: theme.textTheme.bodyMedium),
                      items:
                          _viewModel.kindnessGivers.map((kindnessGiver) {
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
                    onPressed:
                        _viewModel.isSaving
                            ? null
                            : _viewModel.saveKindnessRecord,
                    child:
                        _viewModel.isSaving
                            ? CircularProgressIndicator(
                              color: theme.colorScheme.onPrimary,
                            )
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
