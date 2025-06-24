// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../../models/kindness_giver.dart';
import '../../utils/app_colors.dart';

/// KindnessGiverの統計情報表示チップ
class KindnessGiverStatisticsChip extends StatefulWidget {
  final KindnessGiver kindnessGiver;

  const KindnessGiverStatisticsChip({Key? key, required this.kindnessGiver})
    : super(key: key);

  @override
  State<KindnessGiverStatisticsChip> createState() =>
      _KindnessGiverStatisticsChipState();
}

class _KindnessGiverStatisticsChipState
    extends State<KindnessGiverStatisticsChip> {
  Map<String, dynamic>? _statistics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    if (widget.kindnessGiver.id == null) {
      setState(() {
        _isLoading = false;
        _statistics = null;
      });
      return;
    }

    try {
      final stats = await KindnessGiver.fetchKindnessGiverStatistics(
        widget.kindnessGiver.id!,
      );
      setState(() {
        _statistics = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statistics = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: theme.colorScheme.primary.withOpacity(0.6),
        ),
      );
    }

    // 統計データの有無に関わらず、登録日は表示する
    final hasStatistics = _statistics != null && _statistics!['totalCount'] > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 統計チップを横並びで表示（統計データがある場合のみ）
        if (hasStatistics) ...[
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 6,
            runSpacing: 4,
            children: [
              // 受け取ったやさしさ
              if (_statistics!['receivedCount'] > 0)
                _buildStatChip(
                  icon: Icons.inbox,
                  count: _statistics!['receivedCount'] as int,
                  label: '受け取った',
                  color: Colors.pink.shade400,
                  theme: theme,
                ),

              // 送ったやさしさ
              if (_statistics!['givenCount'] > 0)
                _buildStatChip(
                  icon: Icons.send,
                  count: _statistics!['givenCount'] as int,
                  label: '送った',
                  color: Colors.blue.shade400,
                  theme: theme,
                ),
            ],
          ),
          const SizedBox(height: 4),
        ] else ...[
          // 統計チップがない場合は同じ高さを確保
          const SizedBox(height: 26), // 統計チップの高さ分のスペーサー
        ],

        // メンバー登録日（常に表示）
        if (widget.kindnessGiver.createdAt != null)
          _buildMemberSinceInfo(widget.kindnessGiver.createdAt!, theme),
      ],
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required int count,
    required String label,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            '$count',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberSinceInfo(DateTime createdAt, ThemeData theme) {
    final dateFormat = DateFormat('yyyy/MM/dd');
    final formattedDate = dateFormat.format(createdAt);

    return Text(
      formattedDate,
      style: theme.textTheme.bodySmall?.copyWith(
        color: AppColors.textLight,
        fontSize: 10,
      ),
    );
  }
}
