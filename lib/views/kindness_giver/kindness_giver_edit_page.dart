// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Project imports:
import '../../models/kindness_giver.dart';
import '../../utils/app_colors.dart';
import '../../view_models/kindness_giver/kindness_giver_edit_view_model.dart';
import '../../widgets/common/bottom_navigation.dart';

class KindnessGiverEditPage extends StatefulWidget {
  final KindnessGiver kindnessGiver;

  const KindnessGiverEditPage({super.key, required this.kindnessGiver});

  @override
  State<KindnessGiverEditPage> createState() => _KindnessGiverEditPageState();
}

class _KindnessGiverEditPageState extends State<KindnessGiverEditPage> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.kindnessGiver.giverName,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (_) => KindnessGiverEditViewModel(
            originalKindnessGiver: widget.kindnessGiver,
          ),
      child: Consumer<KindnessGiverEditViewModel>(
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
            bottomNavigationBar: const BottomNavigation(currentIndex: 1),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      centerTitle: false,
      toolbarHeight: 48.0,
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
        'メンバーを編集',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildNameSection(viewModel, ThemeData theme) {
    return _buildCard(
      theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('名前', Icons.edit_outlined, theme),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.secondary, width: 1),
            ),
            child: TextField(
              controller: _nameController,
              onChanged: viewModel.updateName,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                hintText: '名前またはニックネームを入力',
                hintStyle: TextStyle(color: AppColors.textLight, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(ThemeData theme, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.lightShadow,
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.secondary.withOpacity(0.8),
          width: 1,
        ),
      ),
      child: child,
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

  Widget _buildActionButtons(
    KindnessGiverEditViewModel viewModel,
    ThemeData theme,
  ) {
    final bool isArchived =
        viewModel.originalKindnessGiver?.isArchived ?? false;

    if (isArchived) {
      // アーカイブされたメンバーの場合は復元ボタンのみ表示
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: _buildUnarchiveButton(viewModel, theme),
      );
    }

    // アクティブなメンバーの場合は従来通りのボタン配置
    return Column(
      children: [
        // 上段：更新ボタン
        SizedBox(
          width: double.infinity,
          height: 48,
          child: _buildUpdateButton(viewModel, theme),
        ),
        const SizedBox(height: 12),
        // 下段：アーカイブ・削除ボタン
        Row(
          children: [
            Expanded(child: _buildArchiveButton(viewModel, theme)),
            const SizedBox(width: 12),
            Expanded(child: _buildDeleteButton(viewModel, theme)),
          ],
        ),
      ],
    );
  }

  Widget _buildUpdateButton(
    KindnessGiverEditViewModel viewModel,
    ThemeData theme,
  ) {
    return Container(
      height: 48,
      child: ElevatedButton(
        onPressed:
            viewModel.isSaving || viewModel.isDeleting
                ? null
                : viewModel.updateKindnessGiver,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child:
            viewModel.isSaving
                ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.onPrimary,
                    strokeWidth: 2,
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.update_outlined,
                      size: 16,
                      color: theme.colorScheme.onPrimary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '更新',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildArchiveButton(
    KindnessGiverEditViewModel viewModel,
    ThemeData theme,
  ) {
    return Container(
      height: 48,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.orange[700],
          side: BorderSide(color: Colors.orange[300]!, width: 1.5),
          backgroundColor: Colors.orange[50],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed:
            viewModel.isArchiving || viewModel.isSaving || viewModel.isDeleting
                ? null
                : () => _showArchiveConfirmDialog(viewModel, theme),
        child:
            viewModel.isArchiving
                ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.orange[700],
                    strokeWidth: 2,
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.archive_outlined,
                      size: 16,
                      color: Colors.orange[700],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'アーカイブ',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildUnarchiveButton(
    KindnessGiverEditViewModel viewModel,
    ThemeData theme,
  ) {
    return Container(
      height: 48,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(
            color: AppColors.primary.withOpacity(0.5),
            width: 1.5,
          ),
          backgroundColor: AppColors.primary.withOpacity(0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed:
            viewModel.isArchiving || viewModel.isSaving || viewModel.isDeleting
                ? null
                : () => _showUnarchiveConfirmDialog(viewModel, theme),
        child:
            viewModel.isArchiving
                ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.unarchive_outlined,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '復元',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildDeleteButton(
    KindnessGiverEditViewModel viewModel,
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
    KindnessGiverEditViewModel viewModel,
    ThemeData theme,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('削除確認'),
            content: Text(
              '${widget.kindnessGiver.giverName}さんを削除しますか？\n削除すると元に戻すことはできません。',
            ),
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
      viewModel.deleteKindnessGiver();
    }
  }

  Future<void> _showArchiveConfirmDialog(
    KindnessGiverEditViewModel viewModel,
    ThemeData theme,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('アーカイブ確認'),
            content: Text(
              '${widget.kindnessGiver.giverName}さんをアーカイブしますか？\nアーカイブすると一覧に表示されなくなりますが、いつでも復元できます。',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'アーカイブ',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      viewModel.archiveKindnessGiver();
    }
  }

  Future<void> _showUnarchiveConfirmDialog(
    KindnessGiverEditViewModel viewModel,
    ThemeData theme,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('復元確認'),
            content: Text(
              '${widget.kindnessGiver.giverName}さんを復元しますか？\n復元すると再び一覧に表示されるようになります。',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  '復元',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      viewModel.unarchiveKindnessGiver();
    }
  }

  Widget _buildBody(viewModel, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        top: 8.0,
        bottom: 20.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNameSection(viewModel, theme),
          const SizedBox(height: 28),
          _buildActionButtons(viewModel, theme),
        ],
      ),
    );
  }
}
