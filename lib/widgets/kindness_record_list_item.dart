// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../models/kindness_record.dart';
import '../utils/app_colors.dart';
import 'kindness_giver/kindness_giver_avatar.dart';

// やさしさ記録リストの1件分を表示するウィジェット
class KindnessRecordListItem extends StatelessWidget {
  /// 表示するやさしさ記録
  final KindnessRecord record;

  /// タップ時のコールバック関数
  final VoidCallback? onTap;

  // コンストラクタ
  const KindnessRecordListItem({Key? key, required this.record, this.onTap})
    : super(key: key);

  // UI構築処理
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MM/dd HH:mm');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
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
              // ヘッダー部分（アバター、名前、日時）
              Row(
                children: [
                  // アバター
                  KindnessGiverAvatar(
                    gender: record.giverGender,
                    relationship: record.giverCategory,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  // 名前とカテゴリ
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          record.giverName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: AppColors.textLight,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(
                              record.giverCategory,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _getCategoryLabel(record.giverCategory),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _getCategoryColor(record.giverCategory),
                              fontWeight: FontWeight.w500,
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 日時
                  Text(
                    dateFormat.format(record.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textLight,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // やさしさの内容（メイン）
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.03),
                      theme.colorScheme.primary.withOpacity(0.01),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Text(
                  record.content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontSize: 15,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // カテゴリに応じた色を返す
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'family':
      case '家族':
        return Colors.green;
      case 'friend':
      case '友人':
      case '友達':
        return Colors.blue;
      case 'partner':
      case 'lover':
      case '恋人':
      case 'パートナー':
        return Colors.pink;
      case 'colleague':
      case '同僚':
        return Colors.orange;
      case 'pet':
      case 'ペット':
        return Colors.purple;
      case 'other':
      case 'その他':
        return Colors.grey;
      default:
        return AppColors.primary;
    }
  }

  // カテゴリに応じたラベルを返す
  String _getCategoryLabel(String category) {
    switch (category.toLowerCase()) {
      case 'family':
        return '家族';
      case 'friend':
        return '友人';
      case '友達':
        return '友人';
      case 'partner':
        return 'パートナー';
      case 'lover':
        return '恋人';
      case 'colleague':
        return '同僚';
      case 'pet':
        return 'ペット';
      case 'other':
        return 'その他';
      default:
        return category;
    }
  }
}
