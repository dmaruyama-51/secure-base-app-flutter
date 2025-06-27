// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Project imports:
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../view_models/kindness_reflection/kindness_reflection_list_view_model.dart';
import '../../widgets/common/bottom_navigation.dart';
import '../../widgets/kindness_reflection/kindness_reflection_list_item.dart';
import '../../widgets/kindness_reflection/balance_score_trend_card.dart';

class ReflectionListPage extends StatefulWidget {
  const ReflectionListPage({super.key});

  @override
  ReflectionListPageState createState() => ReflectionListPageState();
}

class ReflectionListPageState extends State<ReflectionListPage> {
  late ScrollController _scrollController;
  bool _showPastReflections = false; // 過去のリフレクション表示状態

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
            // バランススコア推移カード（空の状態でも表示）
            _buildBalanceScoreSection(viewModel),
            const SizedBox(height: 24),
            // 安全基地ノートカード（空の状態）
            _buildReflectionsCard(viewModel),
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

            // バランススコア推移カード
            _buildBalanceScoreSection(viewModel),
            const SizedBox(height: 24),

            // 安全基地ノートカード
            _buildReflectionsCard(viewModel),

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

  Widget _buildReflectionsCard(ReflectionListViewModel viewModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorderRadius.largeRadius,
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReflectionsCardHeader(viewModel),
          const SizedBox(height: 16),
          _buildReflectionsList(viewModel),
        ],
      ),
    );
  }

  Widget _buildReflectionsCardHeader(ReflectionListViewModel viewModel) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: AppBorderRadius.mediumRadius,
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 20,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '安全基地ノート',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '設定した頻度で振り返りレポートをお届けします',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textLight,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // 次回配信日の表示
        if (viewModel.nextDeliveryDate != null ||
            viewModel.isCalculatingNextDelivery ||
            viewModel.nextDeliveryDateError != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: AppBorderRadius.smallRadius,
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
    );
  }

  Widget _buildReflectionsList(ReflectionListViewModel viewModel) {
    final groupedReflections = viewModel.getGroupedReflections();
    final latestReflections = groupedReflections['latest'] ?? [];
    final pastReflections = groupedReflections['past'] ?? [];

    // 空の状態の場合
    if (latestReflections.isEmpty && pastReflections.isEmpty) {
      return _buildEmptyReflectionsContent();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 最新のリフレクション
        if (latestReflections.isNotEmpty) ...[
          _buildSectionHeader('最新', Icons.star),
          ...latestReflections.map(
            (reflection) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
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

        // 過去のリフレクション（トグル制御）
        if (pastReflections.isNotEmpty) ...[
          if (latestReflections.isNotEmpty) const SizedBox(height: 12),
          // 過去のリフレクション用のトグルヘッダー
          _buildPastReflectionsToggleHeader(pastReflections.length),
          if (_showPastReflections) ...[
            const SizedBox(height: 8),
            ...pastReflections.map(
              (reflection) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
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
        ],

        // ページネーション用のローディング
        if (viewModel.hasMore && _showPastReflections) _buildLoadingItem(),
      ],
    );
  }

  /// 過去のリフレクション用のトグルヘッダー
  Widget _buildPastReflectionsToggleHeader(int count) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        setState(() {
          _showPastReflections = !_showPastReflections;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Icon(Icons.history, color: AppColors.textLight, size: 16),
            const SizedBox(width: 6),
            Text(
              '過去 ($count)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: AppColors.textLight,
              ),
            ),
            const Spacer(),
            AnimatedRotation(
              turns: _showPastReflections ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.textLight,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyReflectionsContent() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 24,
                color: AppColors.primary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'まだノートがありません',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '安全基地ノートは設定した頻度で自動でお届けします。\nもうしばらくお待ち下さい。',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textLight, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textLight, size: 16),
          const SizedBox(width: 6),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: AppColors.textLight,
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
                '安全基地メンバーとの関わりを振り返りましょう',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
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
      return '$difference日後 ($date.month/$date.day)';
    } else {
      return '$date.month/$date.day';
    }
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
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

  Widget _buildBalanceScoreSection(ReflectionListViewModel viewModel) {
    return BalanceScoreTrendCardAdvanced(
      weeklyData: viewModel.balanceScores,
      errorMessage: viewModel.balanceScoreError,
      isLoading: viewModel.isLoadingBalanceScores,
    );
  }
}
