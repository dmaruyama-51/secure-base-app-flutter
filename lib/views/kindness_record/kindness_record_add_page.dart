// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Project imports:
import '../../utils/app_colors.dart';
import '../../view_models/kindness_record/kindness_record_add_view_model.dart';
import '../../widgets/common/bottom_navigation.dart';
import '../../widgets/kindness_giver/kindness_giver_avatar.dart';

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
      create: (_) => KindnessRecordAddViewModel()..initialize(),
      child: Consumer<KindnessRecordAddViewModel>(
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
        'やさしさ記録',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildBody(KindnessRecordAddViewModel viewModel, ThemeData theme) {
    // TextEditingControllerの内容を状態と同期
    if (_contentController.text != viewModel.content) {
      _contentController.text = viewModel.content;
    }

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
          _buildSaveButton(viewModel, theme),
        ],
      ),
    );
  }

  Widget _buildFormCard(KindnessRecordAddViewModel viewModel, ThemeData theme) {
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
          _buildSectionTitle('どんなやさしさを受け取りましたか？', Icons.edit, theme),
          const SizedBox(height: 16),
          _buildContentField(viewModel, theme),
          const SizedBox(height: 24),
          if (viewModel.kindnessGivers.isNotEmpty) ...[
            _buildSectionTitle('誰からのやさしさですか？', Icons.person, theme),
            const SizedBox(height: 16),
            _buildKindnessGiverSelector(viewModel, theme),
            const SizedBox(height: 16),
            _buildExampleSection(theme),
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
    KindnessRecordAddViewModel viewModel,
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
          hintText: '例：「お疲れさま」と声をかけてくれた\n　　◯◯◯について話を聞いてくれた',
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
    KindnessRecordAddViewModel viewModel,
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

  Widget _buildExampleSection(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                '記録のヒント',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '小さなことでも大切な記録になります：\n・笑顔で挨拶してくれた  ・体調を気遣ってくれた\n・話を最後まで聞いてくれた  ・手伝ってくれた',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textLight,
              height: 1.4,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(
    KindnessRecordAddViewModel viewModel,
    ThemeData theme,
  ) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        onPressed: viewModel.isSaving ? null : viewModel.saveKindnessRecord,
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
                    const Icon(Icons.favorite, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'やさしさを記録する',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
