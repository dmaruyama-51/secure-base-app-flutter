// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../../models/kindness_reflection.dart';
import '../../utils/app_colors.dart';

class ReflectionListItem extends StatelessWidget {
  final KindnessReflection reflection;
  final VoidCallback? onTap;

  const ReflectionListItem({Key? key, required this.reflection, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('yyyy/MM/dd');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.withOpacity(0.15), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー部分
              Row(
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      reflection.reflectionTitle ?? 'リフレクション',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.textLight,
                    size: 16,
                  ),
                ],
              ),

              // 期間表示
              if (reflection.reflectionStartDate != null &&
                  reflection.reflectionEndDate != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 12, color: AppColors.textLight),
                    const SizedBox(width: 4),
                    Text(
                      '${dateFormat.format(reflection.reflectionStartDate!)} - ${dateFormat.format(reflection.reflectionEndDate!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textLight,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
