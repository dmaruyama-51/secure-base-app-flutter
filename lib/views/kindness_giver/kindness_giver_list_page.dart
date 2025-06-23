// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Project imports:
import '../../models/kindness_giver.dart';
import '../../utils/app_colors.dart';
import '../../view_models/kindness_giver/kindness_giver_list_view_model.dart';
import '../../widgets/common/bottom_navigation.dart';
import '../../widgets/kindness_giver/kindness_giver_card.dart';

class KindnessGiverListPage extends StatefulWidget {
  const KindnessGiverListPage({super.key});

  @override
  State<KindnessGiverListPage> createState() => _KindnessGiverListPageState();
}

class _KindnessGiverListPageState extends State<KindnessGiverListPage> {
  KindnessGiverListViewModel? _viewModel;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => KindnessGiverListViewModel()..loadKindnessGivers(),
      child: Consumer<KindnessGiverListViewModel>(
        builder: (context, viewModel, child) {
          _viewModel = viewModel; // ViewModelインスタンスを保存
          final theme = Theme.of(context);

          // メッセージ表示処理
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (viewModel.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(viewModel.errorMessage!),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
            if (viewModel.successMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(viewModel.successMessage!),
                  backgroundColor: Colors.green,
                ),
              );
            }
          });

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: _buildAppBar(theme),
            body: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 8.0,
                bottom: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(theme),
                  const SizedBox(height: 24),
                  _buildStatusToggle(viewModel, theme),
                  const SizedBox(height: 16),
                  _buildMembersSection(viewModel, theme),
                ],
              ),
            ),
            floatingActionButton: _buildFloatingActionButton(viewModel, theme),
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
      automaticallyImplyLeading: false,
      centerTitle: false,
      toolbarHeight: 32.0,
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.05),
            theme.colorScheme.primary.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.15),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                '安全基地メンバー',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'あなたが安心できる場所をつくる人たちです',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textLight,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusToggle(
    KindnessGiverListViewModel viewModel,
    ThemeData theme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => viewModel.showActiveOnly(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color:
                      !viewModel.showArchivedOnly
                          ? Colors.white.withOpacity(0.9)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow:
                      !viewModel.showArchivedOnly
                          ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ]
                          : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 14,
                      color:
                          !viewModel.showArchivedOnly
                              ? theme.colorScheme.primary.withOpacity(0.8)
                              : theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'アクティブ',
                      style: TextStyle(
                        color:
                            !viewModel.showArchivedOnly
                                ? theme.colorScheme.primary.withOpacity(0.8)
                                : theme.colorScheme.onSurface.withOpacity(0.5),
                        fontWeight:
                            !viewModel.showArchivedOnly
                                ? FontWeight.w500
                                : FontWeight.w400,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => viewModel.setShowArchivedOnly(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color:
                      viewModel.showArchivedOnly
                          ? Colors.white.withOpacity(0.9)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow:
                      viewModel.showArchivedOnly
                          ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ]
                          : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.archive_outlined,
                      size: 14,
                      color:
                          viewModel.showArchivedOnly
                              ? theme.colorScheme.primary.withOpacity(0.8)
                              : theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'アーカイブ',
                      style: TextStyle(
                        color:
                            viewModel.showArchivedOnly
                                ? theme.colorScheme.primary.withOpacity(0.8)
                                : theme.colorScheme.onSurface.withOpacity(0.5),
                        fontWeight:
                            viewModel.showArchivedOnly
                                ? FontWeight.w500
                                : FontWeight.w400,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersSection(
    KindnessGiverListViewModel viewModel,
    ThemeData theme,
  ) {
    if (viewModel.isLoading) {
      return _buildLoadingCard(theme);
    }

    if (viewModel.errorMessage != null) {
      return _buildErrorCard(viewModel, theme);
    }

    if (viewModel.kindnessGivers.isEmpty) {
      return _buildEmptyCard(viewModel, theme);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              viewModel.showArchivedOnly ? Icons.archive : Icons.people_outline,
              color: theme.colorScheme.primary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              viewModel.showArchivedOnly ? 'アーカイブされたメンバー' : 'アクティブなメンバー',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${viewModel.kindnessGivers.length}人',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...viewModel.kindnessGivers.map(
          (kindnessGiver) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildKindnessGiverCard(kindnessGiver, viewModel, theme),
          ),
        ),
      ],
    );
  }

  Widget _buildKindnessGiverCard(
    KindnessGiver kindnessGiver,
    KindnessGiverListViewModel viewModel,
    ThemeData theme,
  ) {
    final bool isArchived = kindnessGiver.isArchived;

    return Opacity(
      opacity: isArchived ? 0.6 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border:
              isArchived
                  ? Border.all(color: Colors.orange.withOpacity(0.3), width: 1)
                  : null,
        ),
        child: Stack(
          children: [
            KindnessGiverCard(
              kindnessGiver: kindnessGiver,
              onTap: () => _navigateToEdit(kindnessGiver),
            ),
            if (isArchived)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'アーカイブ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.secondary.withOpacity(0.8),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            'メンバーを読み込み中...',
            style: TextStyle(color: AppColors.textLight, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(
    KindnessGiverListViewModel viewModel,
    ThemeData theme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 40, color: theme.colorScheme.error),
          const SizedBox(height: 12),
          Text(
            'エラーが発生しました',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            viewModel.errorMessage!,
            style: TextStyle(color: AppColors.textLight, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => viewModel.loadKindnessGivers(),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('再試行'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              textStyle: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(
    KindnessGiverListViewModel viewModel,
    ThemeData theme,
  ) {
    final bool showingArchived = viewModel.showArchivedOnly;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.secondary.withOpacity(0.8),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // イラスト的なアバターコンテナ
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(
              showingArchived ? Icons.archive_outlined : Icons.people_outline,
              size: 32,
              color: theme.colorScheme.primary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            showingArchived ? 'アーカイブされたメンバーはいません' : 'まだメンバーがいません',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            showingArchived
                ? 'アーカイブされたメンバーがここに表示されます'
                : '右下のボタンから\n最初のメンバーを追加しましょう',
            style: TextStyle(color: AppColors.textLight, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(
    KindnessGiverListViewModel viewModel,
    ThemeData theme,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: _navigateToAdd,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'メンバーを追加',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _navigateToAdd() {
    context.push('/kindness-givers/add').then((_) {
      // 追加ページから戻ってきた際にリストを再読み込み
      if (_viewModel != null) {
        _viewModel!.refreshKindnessGivers();
      }
    });
  }

  void _navigateToEdit(KindnessGiver kindnessGiver) {
    context
        .push('/kindness-givers/edit/${kindnessGiver.id}', extra: kindnessGiver)
        .then((_) {
          // 編集ページから戻ってきた際にリストを再読み込み
          if (_viewModel != null) {
            _viewModel!.refreshKindnessGivers();
          }
        });
  }
}
