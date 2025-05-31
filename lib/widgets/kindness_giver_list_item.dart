import 'package:flutter/material.dart';
import '../models/kindness_giver.dart';

class KindnessGiverListItem extends StatelessWidget {
  final KindnessGiver kindnessGiver;
  final VoidCallback onEditPressed;
  final VoidCallback onDeletePressed;

  const KindnessGiverListItem({
    super.key,
    required this.kindnessGiver,
    required this.onEditPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.surface,
        backgroundImage:
            kindnessGiver.avatarUrl != null
                ? NetworkImage(kindnessGiver.avatarUrl!)
                : null,
        child:
            kindnessGiver.avatarUrl == null
                ? Icon(
                  Icons.person,
                  color: theme.colorScheme.onSurface.withAlpha(153),
                )
                : null,
      ),
      title: Text(
        kindnessGiver.name,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        kindnessGiver.relationship,
        style: TextStyle(
          fontSize: 14,
          color: theme.colorScheme.primary.withAlpha(200),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              Icons.edit,
              color: theme.colorScheme.onSurface.withAlpha(153),
            ),
            onPressed: onEditPressed,
          ),
          IconButton(
            icon: Icon(
              Icons.delete,
              color: theme.colorScheme.error.withAlpha(153),
            ),
            onPressed: onDeletePressed,
          ),
        ],
      ),
    );
  }
}
