import 'package:flutter/material.dart';

/// 関係性選択ウィジェット
class RelationSelection extends StatelessWidget {
  final String selectedRelation;
  final Function(String) onRelationSelected;
  final ThemeData theme;

  const RelationSelection({
    Key? key,
    required this.selectedRelation,
    required this.onRelationSelected,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.group_outlined,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              '関係性',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...relationOptions.map(
          (relation) => _RelationOptionTile(
            label: relation['label'] as String,
            icon: relation['icon'] as IconData,
            isSelected: selectedRelation == relation['value'],
            onTap: () => onRelationSelected(relation['value'] as String),
            theme: theme,
          ),
        ),
      ],
    );
  }

  static List<Map<String, dynamic>> get relationOptions => [
    {'label': '家族', 'icon': Icons.home_outlined, 'value': '家族'},
    {'label': '友達', 'icon': Icons.people_outline, 'value': '友達'},
    {'label': 'パートナー', 'icon': Icons.favorite_outline, 'value': 'パートナー'},
    {'label': 'ペット', 'icon': Icons.pets_outlined, 'value': 'ペット'},
  ];
}

class _RelationOptionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _RelationOptionTile({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? theme.colorScheme.primary.withOpacity(0.1)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    isSelected
                        ? theme.colorScheme.primary.withOpacity(0.3)
                        : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color:
                      isSelected
                          ? theme.colorScheme.primary
                          : Colors.grey.shade600,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color:
                        isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
