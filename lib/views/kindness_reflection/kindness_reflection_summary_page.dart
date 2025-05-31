import 'package:flutter/material.dart';
import '../../widgets/common/bottom_navigation.dart';
import '../../view_models/kindness_reflection/kindness_reflection_summary_view_model.dart';
import '../../models/kindness_record.dart';

// Kindness Reflection Summaryページの画面Widget
class ReflectionSummaryPage extends StatefulWidget {
  final String summaryId;

  const ReflectionSummaryPage({super.key, required this.summaryId});

  @override
  State<ReflectionSummaryPage> createState() => _ReflectionSummaryPageState();
}

// Kindness Reflection Summaryページの状態管理クラス
class _ReflectionSummaryPageState extends State<ReflectionSummaryPage> {
  late KindnessReflectionSummaryViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = KindnessReflectionSummaryViewModel();
    _loadSummaryData();
  }

  Future<void> _loadSummaryData() async {
    await _viewModel.loadSummaryData(widget.summaryId);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
              onPressed: () => Navigator.of(context).pop(),
            ),
            centerTitle: true,
            title: Text(
              _viewModel.summaryData?.title ?? 'Loading...',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          body: _buildBody(),
          bottomNavigationBar: const BottomNavigation(currentIndex: 2),
        );
      },
    );
  }

  Widget _buildBody() {
    final theme = Theme.of(context);

    if (_viewModel.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      );
    }

    if (_viewModel.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_viewModel.error!, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSummaryData,
              child: const Text('再試行'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 統計カード
          _buildStatsCards(),
          const SizedBox(height: 24),
          // リフレクション内容リスト
          _buildReflectionList(),
          const SizedBox(height: 16),
          // Show more ボタン
          _buildShowMoreButton(),
        ],
      ),
    );
  }

  // 統計カードを構築
  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            (_viewModel.summaryData?.entriesCount ?? 0).toString(),
            'Entries',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            (_viewModel.summaryData?.daysCount ?? 0).toString(),
            'Days',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            (_viewModel.summaryData?.peopleCount ?? 0).toString(),
            'People',
          ),
        ),
      ],
    );
  }

  // 個別の統計カードを構築
  Widget _buildStatCard(String displayValue, String label) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            displayValue,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outlineVariant,
            ),
          ),
        ],
      ),
    );
  }

  // リフレクション内容リストを構築
  Widget _buildReflectionList() {
    if (_viewModel.summaryData?.records.isEmpty ?? true) {
      return const SizedBox.shrink();
    }

    return Column(
      children:
          _viewModel.summaryData!.records
              .map((record) => _buildReflectionItemFromRecord(record))
              .toList(),
    );
  }

  // KindnessRecordから表示用アイテムを構築
  Widget _buildReflectionItemFromRecord(KindnessRecord record) {
    final theme = Theme.of(context);
    final formattedDate = _formatDate(record.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // アバター
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child:
                record.giverAvatarUrl != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        record.giverAvatarUrl!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            size: 20,
                            color: theme.colorScheme.outlineVariant,
                          );
                        },
                      ),
                    )
                    : Icon(
                      Icons.person,
                      size: 20,
                      color: theme.colorScheme.outlineVariant,
                    ),
          ),
          const SizedBox(width: 12),
          // テキスト部分
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.content ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outlineVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 日付を"yyyy/MM/dd"形式でフォーマット
  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')}';
  }

  // Show more ボタンを構築
  Widget _buildShowMoreButton() {
    final theme = Theme.of(context);

    return Center(
      child: TextButton(
        onPressed: () {
          _viewModel.showMore();
        },
        child: Text(
          'Show more ...',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outlineVariant,
          ),
        ),
      ),
    );
  }
}
