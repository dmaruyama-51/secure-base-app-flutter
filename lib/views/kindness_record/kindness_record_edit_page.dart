// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Project imports:
import '../../models/kindness_record.dart';
import '../../view_models/kindness_record/kindness_record_edit_view_model.dart';
import '../../widgets/common/bottom_navigation.dart';
import '../../widgets/kindness_giver/kindness_giver_avatar.dart';
import '../../utils/app_colors.dart';

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

          // TextEditingControllerの内容を状態と同期
          // if (_contentController.text != viewModel.content) {
          //   _contentController.text = viewModel.content;
          // }

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
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.arrow_back,
            color: theme.colorScheme.onSurface,
            size: 20,
          ),
        ),
        onPressed: () => GoRouter.of(context).pop(),
      ),
      title: Text(
        'やさしさ記録を編集',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildBody(KindnessRecordEditViewModel viewModel, ThemeData theme) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormCard(viewModel, theme),
          const SizedBox(height: 24),
          _buildActionButtons(viewModel, theme),
        ],
      ),
    );
  }

  Widget _buildFormCard(
    KindnessRecordEditViewModel viewModel,
    ThemeData theme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('やさしさの内容', Icons.edit, theme),
          const SizedBox(height: 16),
          _buildContentField(viewModel, theme),
          const SizedBox(height: 24),
          if (viewModel.kindnessGivers.isNotEmpty) ...[
            _buildSectionTitle('誰からのやさしさですか？', Icons.person, theme),
            const SizedBox(height: 16),
            _buildKindnessGiverSelector(viewModel, theme),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildContentField(
    KindnessRecordEditViewModel viewModel,
    ThemeData theme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _contentController,
        minLines: 4,
        maxLines: 6,
        decoration: InputDecoration(
          hintText: '受け取ったやさしさを記録してください',
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textLight.withOpacity(0.8),
            fontSize: 13,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
        onChanged: viewModel.updateContent,
      ),
    );
  }

  Widget _buildKindnessGiverSelector(
    KindnessRecordEditViewModel viewModel,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.5),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.1),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          isExpanded: true,
          value: viewModel.selectedKindnessGiver,
          hint: Text('メンバーを選択', style: TextStyle(color: AppColors.textLight)),
          items:
              viewModel.kindnessGivers.map((kindnessGiver) {
                return DropdownMenuItem(
                  value: kindnessGiver,
                  child: Row(
                    children: [
                      KindnessGiverAvatar(
                        kindnessGiver: kindnessGiver,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        kindnessGiver.giverName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          onChanged: (value) {
            if (value != null) {
              viewModel.selectKindnessGiver(value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    KindnessRecordEditViewModel viewModel,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Expanded(child: _buildUpdateButton(viewModel, theme)),
        const SizedBox(width: 12),
        Expanded(child: _buildDeleteButton(viewModel, theme)),
      ],
    );
  }

  Widget _buildUpdateButton(
    KindnessRecordEditViewModel viewModel,
    ThemeData theme,
  ) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow:
            viewModel.isSaving
                ? []
                : [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: viewModel.isSaving ? null : viewModel.updateKindnessRecord,
        child:
            viewModel.isSaving
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.update, size: 18, color: Colors.white),
                    const SizedBox(width: 6),
                    const Text(
                      '更新',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildDeleteButton(
    KindnessRecordEditViewModel viewModel,
    ThemeData theme,
  ) {
    return Container(
      height: 48,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.grey[600],
          side: BorderSide(color: Colors.grey[300]!, width: 1.5),
          backgroundColor: Colors.grey[50],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed:
            viewModel.isDeleting || viewModel.isSaving
                ? null
                : () => _showDeleteConfirmDialog(viewModel, theme),
        child:
            viewModel.isDeleting
                ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.grey[600],
                    strokeWidth: 2,
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '削除',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Future<void> _showDeleteConfirmDialog(
    KindnessRecordEditViewModel viewModel,
    ThemeData theme,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('削除確認'),
            content: const Text('このやさしさ記録を削除しますか？\n削除すると元に戻すことはできません。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  '削除',
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      viewModel.deleteKindnessRecord();
    }
  }
}
