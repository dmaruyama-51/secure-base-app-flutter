// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../models/kindness_reflection.dart';
import '../utils/app_colors.dart';

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
              color: theme.colorScheme.secondary.withOpacity(0.8),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー部分
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
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
                          reflection.reflectionTitle ?? 'リフレクション',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '作成日: ${dateFormat.format(reflection.createdAt)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textLight,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.textLight,
                    size: 18,
                  ),
                ],
              ),

              // 期間表示
              if (reflection.reflectionStartDate != null &&
                  reflection.reflectionEndDate != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.05),
                        theme.colorScheme.primary.withOpacity(0.02),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.date_range,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '期間: ${dateFormat.format(reflection.reflectionStartDate!)} - ${dateFormat.format(reflection.reflectionEndDate!)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
