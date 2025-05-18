import 'package:flutter/material.dart';
import '../models/kindness_giver.dart';

class KindnessGiverListItem extends StatelessWidget {
  final KindnessGiver kindnessGiver;
  final VoidCallback onEditPressed;

  const KindnessGiverListItem({
    Key? key,
    required this.kindnessGiver,
    required this.onEditPressed,
  }) : super(key: key);

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
      trailing: IconButton(
        icon: Icon(
          Icons.edit,
          color: theme.colorScheme.onSurface.withAlpha(153),
        ),
        onPressed: onEditPressed,
      ),
    );
  }
}
