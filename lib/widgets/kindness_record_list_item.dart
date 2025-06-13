// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../models/kindness_record.dart';

// やさしさ記録リストの1件分を表示するウィジェット
class KindnessRecordListItem extends StatelessWidget {
  /// 表示するやさしさ記録
  final KindnessRecord record;
  /// タップ時のコールバック関数
  final VoidCallback? onTap;

  // コンストラクタ
  const KindnessRecordListItem({
    Key? key,
    required this.record,
    this.onTap,
  }) : super(key: key);

  // UI構築処理
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('yyyy/MM/dd');

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.surface,
        backgroundImage:
            record.giverAvatarUrl != null ? NetworkImage(record.giverAvatarUrl!) : null,
        child:
            record.giverAvatarUrl == null
                ? Icon(
                  Icons.person,
                  color: theme.colorScheme.onSurface.withAlpha(153),
                )
                : null,
      ),
      title: Text(
        record.content,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        dateFormat.format(record.createdAt),
        style: TextStyle(
          fontSize: 14,
          color: theme.colorScheme.primary.withAlpha(200),
        ),
      ),
    );
  }
} 
