// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Project imports:
import '../../utils/app_colors.dart';
import '../../view_models/kindness_record/kindness_record_list_view_model.dart';
import '../../widgets/common/bottom_navigation.dart';
import '../../widgets/kindness_record_list_item.dart';

/// やさしさ記録一覧ページ
class KindnessRecordListPage extends StatefulWidget {
  const KindnessRecordListPage({super.key});

  @override
  State<KindnessRecordListPage> createState() => _KindnessRecordListPageState();
}

class _KindnessRecordListPageState extends State<KindnessRecordListPage> {
  KindnessRecordListViewModel? _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = KindnessRecordListViewModel();
    _viewModel!.loadKindnessRecords(forceRefresh: true);
  }

  @override
  void dispose() {
    _viewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ViewModelが初期化されていない場合はローディング画面を表示
    if (_viewModel == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return ChangeNotifierProvider.value(
      value: _viewModel!,
      child: Consumer<KindnessRecordListViewModel>(
        builder: (context, viewModel, child) {
          // メッセージ表示処理
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (viewModel.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(viewModel.errorMessage!),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
              viewModel.clearErrorMessage();
            }
            if (viewModel.successMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(viewModel.successMessage!),
                  backgroundColor: Colors.green,
                ),
              );
              viewModel.clearSuccessMessage();
            }
          });

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: _buildAppBar(context),
            body: _buildBody(viewModel),
            floatingActionButton: _buildFloatingActionButton(context),
            bottomNavigationBar: const BottomNavigation(currentIndex: 0),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: false,
      toolbarHeight: 32.0,
    );
  }

  Widget _buildBody(KindnessRecordListViewModel viewModel) {
    if (viewModel.isLoading && viewModel.kindnessRecords.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => _viewModel?.refreshKindnessRecords() ?? Future.value(),
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
            // ヘッダー
            _buildHeader(),
            const SizedBox(height: 24),

            // リスト
            _buildRecordsList(viewModel),

            // ローディングインジケーター（追加データ読み込み中）
            if (viewModel.isLoading && viewModel.kindnessRecords.isNotEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
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
              Icon(Icons.lightbulb, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'やさしさ記録',
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
            '送ったやさしさも、もらったやさしさも、どちらも大切に記録しましょう',
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

  Widget _buildRecordsList(KindnessRecordListViewModel viewModel) {
    if (viewModel.errorMessage != null) {
      return _buildErrorState(viewModel);
    }

    if (viewModel.kindnessRecords.isEmpty) {
      return _buildEmptyState();
    }

    final groupedRecords = viewModel.getGroupedRecords();
    final dateKeys = groupedRecords.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...dateKeys.map((dateKey) {
          final records = groupedRecords[dateKey]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 日付ヘッダー
              _buildDateHeader(dateKey),

              // 記録リスト
              ...records.map(
                (record) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: KindnessRecordListItem(
                    record: record,
                    onTap: () {
                      // 編集ページに遷移
                      GoRouter.of(context)
                          .push(
                            '/kindness-records/edit/${record.id}',
                            extra: record,
                          )
                          .then((_) {
                            // 編集ページから戻ってきた際にリストを強制的に再読み込み
                            _viewModel?.refreshKindnessRecords();
                          });
                    },
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildDateHeader(String dateKey) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            color: theme.colorScheme.primary,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            dateKey,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
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
              Icons.lightbulb_outline,
              size: 32,
              color: theme.colorScheme.primary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'まだやさしさ記録がありません',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '右下のボタンから\n最初の記録をつけましょう',
            style: TextStyle(color: AppColors.textLight, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(KindnessRecordListViewModel viewModel) {
    final theme = Theme.of(context);
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
            onPressed: () => _viewModel?.loadKindnessRecords(),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('再試行'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              textStyle: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    final theme = Theme.of(context);

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
          '記録する',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _navigateToAdd() {
    // 追加ページへのナビゲーション
    GoRouter.of(context).push('/kindness-records/add').then((_) {
      // 追加ページから戻ってきた際にリストを強制的に再読み込み
      _viewModel?.refreshKindnessRecords();
    });
  }
}
