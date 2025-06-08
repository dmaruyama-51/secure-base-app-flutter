import 'package:flutter/material.dart';
import '../../models/kindness_giver.dart';

/// KindnessGiverの情報表示チップ（関係性のみ）
class KindnessGiverInfoChip extends StatelessWidget {
  final KindnessGiver kindnessGiver;

  const KindnessGiverInfoChip({Key? key, required this.kindnessGiver})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          _getRelationIcon(kindnessGiver.relationshipName ?? ''),
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
        const SizedBox(width: 6),
        Text(
          kindnessGiver.relationshipName ?? '',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  IconData _getRelationIcon(String relation) {
    switch (relation) {
      case '家族':
        return Icons.home_outlined;
      case '友達':
        return Icons.people_outline;
      case 'パートナー':
        return Icons.favorite_outline;
      case 'ペット':
        return Icons.pets_outlined;
      default:
        return Icons.group_outlined;
    }
  }
}
