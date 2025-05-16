import 'package:flutter/material.dart';
import '../models/member.dart';

class MemberListItem extends StatelessWidget {
  final Member member;
  final VoidCallback onEditPressed;

  const MemberListItem({
    Key? key,
    required this.member,
    required this.onEditPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.surface,
        backgroundImage:
            member.avatarUrl != null ? NetworkImage(member.avatarUrl!) : null,
        child:
            member.avatarUrl == null
                ? Icon(
                  Icons.person,
                  color: theme.colorScheme.onSurface.withAlpha(153),
                )
                : null,
      ),
      title: Text(
        member.name,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        member.category,
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
