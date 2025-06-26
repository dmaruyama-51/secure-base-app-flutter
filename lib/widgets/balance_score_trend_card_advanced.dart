// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../models/balance_score.dart';
import '../utils/app_colors.dart';

/// バランススコア推移表示カード
class BalanceScoreTrendCardAdvanced extends StatefulWidget {
  final List<BalanceScore> weeklyData;
  final String? errorMessage;
  final bool isLoading;

  const BalanceScoreTrendCardAdvanced({
    Key? key,
    required this.weeklyData,
    this.errorMessage,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<BalanceScoreTrendCardAdvanced> createState() =>
      _BalanceScoreTrendCardAdvancedState();
}

class _BalanceScoreTrendCardAdvancedState
    extends State<BalanceScoreTrendCardAdvanced> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return _buildLoadingState(context);
    }

    if (widget.errorMessage != null) {
      return _buildErrorState(context);
    }

    if (widget.weeklyData.isEmpty) {
      return _buildEmptyState(context);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          _buildHeader(context),
          const SizedBox(height: 20),
          _buildChart(context),
          const SizedBox(height: 16),
          _buildLegend(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.timeline, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '支え合いバランス',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => _showBalanceInfoDialog(context),
                    child: Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.primary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              Text(
                '安全基地メンバーとの支え合いのバランスの推移を表示します',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textLight,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showBalanceInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                '支え合いバランスについて',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          content: Text(
            '支え合いバランスは、「送ったやさしさの数・人数」「受け取ったやさしさの数・人数」を考慮して計算されています。',
            style: TextStyle(color: AppColors.text, fontSize: 14, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                '閉じる',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChart(BuildContext context) {
    return Container(
      height: 180,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (value) {
              if (value == 50) {
                // 50点の均等ライン（強調）
                return FlLine(
                  color: AppColors.primary.withOpacity(0.8),
                  strokeWidth: 2,
                  dashArray: [8, 4],
                );
              }
              return FlLine(
                color: AppColors.textLight.withOpacity(0.2),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < widget.weeklyData.length) {
                    final data = widget.weeklyData[index];
                    if (data.weekStartDate != null) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          DateFormat('M/d').format(data.weekStartDate!),
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 10,
                          ),
                        ),
                      );
                    }
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false, // スコア値を非表示
                reservedSize: 0,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: AppColors.textLight.withOpacity(0.2),
              width: 1,
            ),
          ),
          minX: 0,
          maxX: (widget.weeklyData.length - 1).toDouble(),
          minY: 0,
          maxY: 100,
          lineBarsData: [
            LineChartBarData(
              spots: _generateSpots(),
              isCurved: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.8),
                  AppColors.secondary.withOpacity(0.8),
                ],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  final isSelected = touchedIndex == index;
                  return FlDotCirclePainter(
                    radius: isSelected ? 6 : 4,
                    color: isSelected ? AppColors.primary : Colors.white,
                    strokeWidth: 2,
                    strokeColor: AppColors.primary,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.secondary.withOpacity(0.05),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
              setState(() {
                if (response != null && response.lineBarSpots != null) {
                  touchedIndex = response.lineBarSpots!.first.spotIndex;
                } else {
                  touchedIndex = null;
                }
              });
            },
            getTouchedSpotIndicator: (
              LineChartBarData barData,
              List<int> spotIndexes,
            ) {
              return spotIndexes.map((index) {
                return TouchedSpotIndicatorData(
                  FlLine(
                    color: AppColors.primary.withOpacity(0.5),
                    strokeWidth: 2,
                  ),
                  FlDotData(
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 6,
                        color: AppColors.primary,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                );
              }).toList();
            },
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => Colors.white.withOpacity(0.95),
              tooltipRoundedRadius: 8,
              tooltipPadding: const EdgeInsets.all(8),
              tooltipMargin: 8,
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final index = barSpot.spotIndex;
                  if (index >= 0 && index < widget.weeklyData.length) {
                    final data = widget.weeklyData[index];
                    final dateStr =
                        data.weekStartDate != null
                            ? DateFormat('M/d').format(data.weekStartDate!)
                            : '不明';

                    // スコア値を隠し、中央線からの位置のみ表示
                    final String positionText;
                    if (data.balanceScore == 50) {
                      positionText = 'バランスが取れています';
                    } else if (data.balanceScore > 50) {
                      positionText = '支えることが多め';
                    } else {
                      positionText = '支えられることが多め';
                    }

                    return LineTooltipItem(
                      '$dateStr週\n$positionText',
                      TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    );
                  }
                  return null;
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  List<FlSpot> _generateSpots() {
    return widget.weeklyData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.balanceScore.toDouble());
    }).toList();
  }

  Widget _buildLegend(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 2,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'バランス均等ライン',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.arrow_upward, size: 12, color: AppColors.textLight),
              const SizedBox(width: 4),
              Text(
                'ライン以上: メンバーからの支えを受け取ることが多め',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textLight,
                  fontSize: 9,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(Icons.arrow_downward, size: 12, color: AppColors.textLight),
              const SizedBox(width: 4),
              Text(
                'ライン以下: メンバーを支えることが多め',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textLight,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'バランススコアを読み込み中...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 32),
          const SizedBox(height: 12),
          Text(
            'エラーが発生しました',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.errorMessage ?? '不明なエラー',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.red.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          _buildHeader(context),
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Icon(Icons.analytics, color: AppColors.textLight, size: 48),
                const SizedBox(height: 16),
                Text(
                  'まだバランススコアデータがありません',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'やさしさ記録を行うと翌週から\nバランススコアが表示されます',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textLight,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
