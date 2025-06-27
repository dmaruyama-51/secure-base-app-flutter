// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../view_models/kindness_reflection/kindness_reflection_detail_view_model.dart';
import '../../utils/app_colors.dart';

/// リフレクション統計情報を表示するカードウィジェット
class ReflectionStatisticsCard extends StatelessWidget {
  final ReflectionStatistics statistics;

  const ReflectionStatisticsCard({Key? key, required this.statistics})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー
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
                child: Icon(Icons.insights, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'やさしさの統計',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      statistics.balanceDescription.isNotEmpty
                          ? statistics.balanceDescription
                          : '気づいたやさしさの数だけ、毎日が少し豊かになります',
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
          const SizedBox(height: 16),

          // 統計グリッド
          _buildStatisticsGrid(context),
        ],
      ),
    );
  }

  Widget _buildStatisticsGrid(BuildContext context) {
    return Column(
      children: [
        // 基本統計
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.inbox,
                title: '受け取った\nやさしさ',
                value: '${statistics.receivedRecords}',
                unit: '件',
                color: AppColors.chartColors[4], // ピンク
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.send,
                title: '送った\nやさしさ',
                value: '${statistics.givenRecords}',
                unit: '件',
                color: AppColors.chartColors[0], // 青
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 1日平均統計
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.trending_up,
                title: '受け取り\n1日平均',
                value: statistics.averageReceivedPerDay.toStringAsFixed(1),
                unit: '件',
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.trending_up,
                title: '送り\n1日平均',
                value: statistics.averageGivenPerDay.toStringAsFixed(1),
                unit: '件',
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // カテゴリ別統計
        if (statistics.categoryCount.isNotEmpty) ...[
          _buildCategorySection(context, '関係性別', statistics.categoryCount),
          const SizedBox(height: 12),
        ],

        // 性別統計
        if (statistics.genderCount.isNotEmpty) ...[
          _buildCategorySection(context, '性別', statistics.genderCount),
          const SizedBox(height: 12),
        ],

        // 最も多い曜日
        if (statistics.mostActiveWeekdays.isNotEmpty)
          _buildWeekdayCard(context),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textLight,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                  fontSize: 20,
                ),
              ),
              const SizedBox(width: 2),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  unit,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    String title,
    Map<String, int> categoryData,
  ) {
    final theme = Theme.of(context);
    final sortedEntries =
        categoryData.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.text,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          ...sortedEntries.map(
            (entry) => _buildCategoryItem(
              context,
              entry.key,
              entry.value,
              statistics.totalRecords,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    String label,
    int count,
    int total,
  ) {
    final theme = Theme.of(context);
    final percentage = total > 0 ? (count / total * 100) : 0.0;
    final color = AppColors.getChartColor(label);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.text,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '$count件 (${percentage.toStringAsFixed(1)}%)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: AppColors.grey200,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                '最も記録の多かった曜日',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children:
                statistics.mostActiveWeekdays
                    .map(
                      (weekday) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '${weekday}曜日',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }
}
