import 'package:flutter/material.dart';
import '../../models/kindness_giver.dart';
import 'kindness_giver_avatar.dart';
import 'kindness_giver_info_chip.dart';
import '../../widgets/common/delete_confirm_dialog.dart';

/// メンバーカード表示ウィジェット
class KindnessGiverCard extends StatelessWidget {
  final KindnessGiver kindnessGiver;
  final VoidCallback onEdit;
  final VoidCallback onDeleteRequest;

  const KindnessGiverCard({
    Key? key,
    required this.kindnessGiver,
    required this.onEdit,
    required this.onDeleteRequest,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
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
      child: Row(
        children: [
          // アバター
          KindnessGiverAvatar(kindnessGiver: kindnessGiver),
          const SizedBox(width: 16),

          // メンバー情報
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kindnessGiver.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                KindnessGiverInfoChip(kindnessGiver: kindnessGiver),
              ],
            ),
          ),

          // アクションボタン
          _KindnessGiverActionButtons(
            onEdit: onEdit,
            onDelete: onDeleteRequest,
          ),
        ],
      ),
    );
  }
}

/// アクションボタン群のウィジェット
class _KindnessGiverActionButtons extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _KindnessGiverActionButtons({
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 編集ボタン
        _ActionButton(
          icon: Icons.edit_outlined,
          backgroundColor: theme.colorScheme.secondary.withOpacity(0.5),
          iconColor: theme.colorScheme.primary,
          onTap: onEdit,
        ),
        const SizedBox(width: 8),
        // 削除ボタン
        _ActionButton(
          icon: Icons.delete_outline,
          backgroundColor: theme.colorScheme.error.withOpacity(0.1),
          iconColor: theme.colorScheme.error,
          onTap: onDelete,
        ),
      ],
    );
  }
}

/// 汎用アクションボタンウィジェット
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
      ),
    );
  }
}
