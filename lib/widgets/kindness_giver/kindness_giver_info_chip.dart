import 'package:flutter/material.dart';
import '../../models/kindness_giver.dart';
import '../../utils/app_colors.dart';

/// KindnessGiverの情報表示チップ（関係性・性別）
class KindnessGiverInfoChip extends StatelessWidget {
  final KindnessGiver kindnessGiver;

  const KindnessGiverInfoChip({Key? key, required this.kindnessGiver})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          _getRelationIcon(kindnessGiver.category),
          size: 16,
          color: AppColors.textLight,
        ),
        const SizedBox(width: 4),
        Text(
          kindnessGiver.category,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        Icon(
          _getGenderIcon(kindnessGiver.gender),
          size: 16,
          color: AppColors.textLight,
        ),
        const SizedBox(width: 4),
        Text(
          kindnessGiver.gender,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textLight,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  IconData _getGenderIcon(String gender) {
    switch (gender) {
      case '女性':
        return Icons.female;
      case '男性':
        return Icons.male;
      case 'ペット':
        return Icons.pets;
      default:
        return Icons.person;
    }
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
