// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import '../../utils/app_colors.dart';
import '../../view_models/kindness_reflection/kindness_reflection_detail_view_model.dart';
import '../../widgets/kindness_record/kindness_record_list_item.dart';
import '../../widgets/kindness_reflection/reflection_statistics_card.dart';

class ReflectionDetailPage extends StatefulWidget {
  final String? reflectionId; // IDからデータを取得するため

  const ReflectionDetailPage({Key? key, this.reflectionId}) : super(key: key);

  @override
  ReflectionDetailPageState createState() => ReflectionDetailPageState();
}

class ReflectionDetailPageState extends State<ReflectionDetailPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // reflectionがnullの場合のエラーハンドリング
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _buildSafeBody(),
    );
  }

  Widget _buildSafeBody() {
    // reflectionIdがない場合
    if (widget.reflectionId == null) {
      return _buildErrorState('リフレクションデータが見つかりません');
    }

    return ChangeNotifierProvider(
      create: (_) {
        // ViewModelを作成し、reflectionIdを渡す
        final viewModel = ReflectionDetailViewModel(
          reflectionId: widget.reflectionId,
        );
        // 初期データ読み込み（エラーハンドリング付き）
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          try {
            await viewModel.initialize();
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('データの読み込みに失敗しました'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        });
        return viewModel;
      },
      child: Consumer<ReflectionDetailViewModel>(
        builder: (context, viewModel, child) {
          // エラーメッセージの表示
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (viewModel.errorMessage != null && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(viewModel.errorMessage!),
                  backgroundColor: Colors.red,
                ),
              );
              viewModel.clearError();
            }
          });

          return _buildBody(viewModel);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.text),
        onPressed: () => context.pop(),
      ),
    );
  }

  Widget _buildBody(ReflectionDetailViewModel viewModel) {
    if (viewModel.isLoading) {
      return _buildLoadingState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: viewModel.refresh,
        color: AppColors.primary,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 8.0,
            bottom: 20.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー（常に表示）
              _buildHeader(viewModel),
              const SizedBox(height: 24),

              // 統計情報
              if (viewModel.hasData && viewModel.statistics != null) ...[
                ReflectionStatisticsCard(statistics: viewModel.statistics!),
                const SizedBox(height: 24),
              ],

              // レコード一覧
              if (viewModel.hasData) ...[
                _buildRecordsSection(viewModel),
              ] else ...[
                _buildEmptyState(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ReflectionDetailViewModel viewModel) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('yyyy/MM/dd');

    // ViewModelのゲッターメソッドを使用
    final title = viewModel.reflectionTitle;
    final startDate = viewModel.reflectionStartDate;
    final endDate = viewModel.reflectionEndDate;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.08),
            AppColors.secondary.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.2),
                      AppColors.primary.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '以下の期間のレポートをお届けします',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textLight,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (startDate != null && endDate != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.date_range, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecordsSection(ReflectionDetailViewModel viewModel) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // セクションヘッダー
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.favorite_border, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'やさしさの記録',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${viewModel.records.length}件',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // レコード一覧
        if (viewModel.records.isNotEmpty) ...[
          ...viewModel.records.map((record) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: KindnessRecordListItem(record: record),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            '記録を読み込んでいます...',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 画像を円形コンテナでラップし、境界をにじませる効果を追加
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryLight.withOpacity(0.4),
                    AppColors.secondary.withOpacity(0.2),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Image.asset(
                  'assets/images/img_restart.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ポジティブなメインメッセージ
            Text(
              '日々の小さなやさしさを\n探しにいきませんか？',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),

            const SizedBox(height: 12),

            // 共感的なサブメッセージ
            Text(
              '今回はまだ記録がありませんが、\n小さな出来事ほど大切な思い出になります。\n少しずつでいいので、ぜひ書き残してみてください。',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textLight,
                height: 1.6,
              ),
            ),

            const SizedBox(height: 32),

            // やさしさ記録ボタン
            Container(
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                ),
                onPressed: () {
                  context.push('/kindness-records/add');
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      '記録する',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryLight.withOpacity(0.3),
                    AppColors.secondary.withOpacity(0.1),
                  ],
                ),
              ),
              child: Icon(
                Icons.sentiment_dissatisfied,
                size: 48,
                color: AppColors.primary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
