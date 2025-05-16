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
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey[300],
        backgroundImage:
            member.avatarUrl != null ? NetworkImage(member.avatarUrl!) : null,
        child:
            member.avatarUrl == null
                ? Icon(Icons.person, color: Colors.grey[700])
                : null,
      ),
      title: Text(
        member.name,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        member.category,
        style: TextStyle(
          fontSize: 14,
          color:
              member.category == 'Family'
                  ? Colors.brown[400]
                  : Colors.orange[400],
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.edit, color: Colors.black54),
        onPressed: onEditPressed,
      ),
    );
  }
}
