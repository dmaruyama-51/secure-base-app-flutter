// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../view_models/kindness_reflection/kindness_reflection_list_view_model.dart';
import '../../widgets/common/bottom_navigation.dart';
import '../../widgets/kindness_reflection_list_item.dart';
import 'kindness_reflection_detail_page.dart';

class ReflectionListPage extends StatefulWidget {
  const ReflectionListPage({Key? key}) : super(key: key);

  @override
  ReflectionListPageState createState() => ReflectionListPageState();
}

class ReflectionListPageState extends State<ReflectionListPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<ReflectionListViewModel>().loadMoreReflections();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = ReflectionListViewModel();
        // 初期データ読み込み
        WidgetsBinding.instance.addPostFrameCallback((_) {
          viewModel.loadReflections();
        });
        return viewModel;
      },
      child: Consumer<ReflectionListViewModel>(
        builder: (context, viewModel, child) {
          // エラーメッセージの表示
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (viewModel.errorMessage != null) {
              context.showErrorSnackBar(message: viewModel.errorMessage!);
              viewModel.clearError();
            }
          });

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: _buildAppBar(),
            body: _buildBody(viewModel),
            bottomNavigationBar: const BottomNavigation(currentIndex: 2),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: false,
      toolbarHeight: 32.0,
    );
  }

  Widget _buildBody(ReflectionListViewModel viewModel) {
    if (viewModel.isLoading && viewModel.reflections.isEmpty) {
      return _buildLoadingState();
    }

    if (viewModel.isEmpty) {
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
            // ヘッダー
            _buildHeader(),
            const SizedBox(height: 24),
            // 空の状態
            _buildEmptyState(),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: viewModel.refreshReflections,
      color: AppColors.primary,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          top: 8.0,
          bottom: 20.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            _buildHeader(),
            const SizedBox(height: 24),

            // リスト
            _buildReflectionsList(viewModel),

            // ローディングインジケーター（追加データ読み込み中）
            if (viewModel.isLoading && viewModel.reflections.isNotEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReflectionsList(ReflectionListViewModel viewModel) {
    final groupedReflections = viewModel.getGroupedReflections();
    final latestReflections = groupedReflections['latest'] ?? [];
    final pastReflections = groupedReflections['past'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 最新のリフレクション
        if (latestReflections.isNotEmpty) ...[
          _buildSectionHeader('最新', Icons.star),
          ...latestReflections.map(
            (reflection) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ReflectionListItem(
                reflection: reflection,
                onTap: () {
                  // リフレクション詳細ページに遷移（URLパラメータ付き）
                  context.go(
                    '/reflections/detail/${reflection.id}',
                    extra: reflection,
                  );
                },
              ),
            ),
          ),
        ],

        // 過去のリフレクション
        if (pastReflections.isNotEmpty) ...[
          if (latestReflections.isNotEmpty) const SizedBox(height: 16),
          _buildSectionHeader('過去', Icons.history),
          ...pastReflections.map(
            (reflection) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ReflectionListItem(
                reflection: reflection,
                onTap: () {
                  // リフレクション詳細ページに遷移（URLパラメータ付き）
                  context.go(
                    '/reflections/detail/${reflection.id}',
                    extra: reflection,
                  );
                },
              ),
            ),
          ),
        ],

        // ページネーション用のローディング
        if (viewModel.hasMore) _buildLoadingItem(),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    return Consumer<ReflectionListViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.05),
                AppColors.primary.withOpacity(0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.15),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'リフレクション',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '安全基地メンバーからのやさしさのまとめをお届けします',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              // 次回配信日の表示
              if (viewModel.nextDeliveryDate != null ||
                  viewModel.isCalculatingNextDelivery ||
                  viewModel.nextDeliveryDateError != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      if (viewModel.isCalculatingNextDelivery)
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        )
                      else if (viewModel.nextDeliveryDateError != null)
                        Text(
                          '配信日計算エラー',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.orange,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      else if (viewModel.nextDeliveryDate != null)
                        Text(
                          '次回お届け: ${_formatDeliveryDate(viewModel.nextDeliveryDate!)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// 配信日をフォーマットする
  String _formatDeliveryDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    final difference = targetDate.difference(today).inDays;

    if (difference == 0) {
      return '今日';
    } else if (difference == 1) {
      return '明日';
    } else if (difference > 0) {
      return '${difference}日後 (${date.month}/${date.day})';
    } else {
      return '${date.month}/${date.day}';
    }
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

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
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(
              Icons.auto_awesome,
              size: 32,
              color: AppColors.primary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'まだリフレクションがありません',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'リフレクションは設定した頻度で自動でお届けします。\nもうしばらくお待ち下さい。',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textLight, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingItem() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }
}
