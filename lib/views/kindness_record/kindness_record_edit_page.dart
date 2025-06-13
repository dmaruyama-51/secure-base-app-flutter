// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Project imports:
import '../../models/kindness_record.dart';
import '../../view_models/kindness_record/kindness_record_edit_view_model.dart';
import '../../widgets/common/bottom_navigation.dart';

/// やさしさ記録編集ページ
class KindnessRecordEditPage extends StatefulWidget {
  final KindnessRecord kindnessRecord;

  const KindnessRecordEditPage({super.key, required this.kindnessRecord});

  @override
  State<KindnessRecordEditPage> createState() => _KindnessRecordEditPageState();
}

// やさしさ記録編集ページの状態管理クラス
class _KindnessRecordEditPageState extends State<KindnessRecordEditPage> {
  late TextEditingController _contentController;

  // 初期化処理。ViewModelの生成とメンバー一覧の取得を行う。
  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(
      text: widget.kindnessRecord.content,
    );
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
      create:
          (_) =>
              KindnessRecordEditViewModel(originalRecord: widget.kindnessRecord)
                ..initialize(),
      child: Consumer<KindnessRecordEditViewModel>(
        builder: (context, viewModel, child) {
          final theme = Theme.of(context);

          // エラーメッセージがあればSnackBarで表示
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (viewModel.errorMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(viewModel.errorMessage!)));
              viewModel.clearMessages();
            }
          });

          // 成功メッセージがあればSnackBarで表示し、画面を戻す
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (viewModel.successMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(viewModel.successMessage!)),
              );
              if (viewModel.shouldNavigateBack) {
                GoRouter.of(context).pop();
              }
              viewModel.clearMessages();
            }
          });

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: _buildAppBar(theme),
            body: _buildBody(viewModel, theme),
            bottomNavigationBar: const BottomNavigation(currentIndex: 0),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
        onPressed: () => GoRouter.of(context).pop(),
      ),
      title: Text(
        'やさしさ記録を編集',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBody(KindnessRecordEditViewModel viewModel, ThemeData theme) {
    // TextEditingControllerの内容を状態と同期
    if (_contentController.text != viewModel.content) {
      _contentController.text = viewModel.content;
    }

    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'やさしさの内容を編集してください',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
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
              hintText: '受け取ったやさしさを記録してください',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            onChanged: viewModel.updateContent,
          ),
          const SizedBox(height: 16),
          // メンバー選択
          if (viewModel.kindnessGivers.isNotEmpty) ...[
            Text(
              '誰からのやさしさですか？',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton(
                  isExpanded: true,
                  value: viewModel.selectedKindnessGiver,
                  hint: const Text('メンバーを選択'),
                  items:
                      viewModel.kindnessGivers.map((kindnessGiver) {
                        return DropdownMenuItem(
                          value: kindnessGiver,
                          child: Text(kindnessGiver.giverName),
                        );
                      }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      viewModel.selectKindnessGiver(value);
                    }
                  },
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
          // 更新ボタン
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
                  viewModel.isSaving ? null : viewModel.updateKindnessRecord,
              child:
                  viewModel.isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('記録を更新'),
            ),
          ),
        ],
      ),
    );
  }
}
