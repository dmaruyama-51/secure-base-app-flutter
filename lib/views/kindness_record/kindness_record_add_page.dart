import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/kindness_record/kindness_record_add_view_model.dart';
import '../../widgets/common/bottom_navigation.dart';

/// やさしさ記録追加ページ
class KindnessRecordAddPage extends StatefulWidget {
  const KindnessRecordAddPage({super.key});

  @override
  State<KindnessRecordAddPage> createState() => _KindnessRecordAddPageState();
}

// やさしさ記録追加ページの状態管理クラス
class _KindnessRecordAddPageState extends State<KindnessRecordAddPage> {
  late TextEditingController _contentController;

  // 初期化処理。ViewModelの生成とメンバー一覧の取得を行う。
  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController();
    // 画面表示後にメンバー一覧を取得
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<KindnessRecordAddViewModel>(
        context,
        listen: false,
      ).loadMembers();
    });
  }

  // リソース解放処理。TextEditingControllerのdisposeを呼ぶ。
  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  // 画面のUI構築処理
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => KindnessRecordAddViewModel()..loadMembers(),
      child: Consumer<KindnessRecordAddViewModel>(
        builder: (context, viewModel, child) {
          final state = viewModel.state;
          final theme = Theme.of(context);

          // TextEditingControllerの内容を状態と同期
          if (_contentController.text != state.content) {
            _contentController.text = state.content;
          }

          // エラーメッセージの監視
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
              viewModel.clearMessages();
            }
            // 成功メッセージの監視
            if (state.successMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.successMessage!)));
              if (state.shouldNavigateBack) {
                Navigator.of(context).pop();
              }
              viewModel.clearMessages();
            }
          });

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: theme.scaffoldBackgroundColor,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: theme.colorScheme.onSurface,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body:
                state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
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
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.1,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '例：「仕事でミスしたときに励ましてくれた」\n「電車で席を譲ってくれた」',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
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
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.1,
                                  ),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              border: Border.all(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.1,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: state.selectedKindnessGiver?.name,
                                hint: Text(
                                  '人物を選択',
                                  style: theme.textTheme.bodyMedium,
                                ),
                                items:
                                    state.kindnessGivers.map((kindnessGiver) {
                                      return DropdownMenuItem<String>(
                                        value: kindnessGiver.name,
                                        child: Text(kindnessGiver.name),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  final selectedGiver =
                                      state.kindnessGivers
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
                              onPressed:
                                  state.isSaving
                                      ? null
                                      : viewModel.saveKindnessRecord,
                              child:
                                  state.isSaving
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
                    ),
          );
        },
      ),
    );
  }
}
