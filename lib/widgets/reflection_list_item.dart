import 'package:flutter/material.dart';
import '../views/reflection_page.dart';

// ReflectionリストアイテムのWidget
class ReflectionListItem extends StatelessWidget {
  final ReflectionItem item;
  final VoidCallback onTap;

  const ReflectionListItem({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // カレンダーアイコン
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.outline), // ボーダー色
                ),
                child: Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: colorScheme.outlineVariant,
                ),
              ),
              const SizedBox(width: 16),
              // テキスト部分
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface, // メインテキスト色
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.date,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.outlineVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
