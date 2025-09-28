// Flutter imports:
import 'package:flutter/material.dart';

/// 性別選択ウィジェット
class GenderSelection extends StatelessWidget {
  final String selectedGender;
  final Function(String) onGenderSelected;
  final ThemeData theme;

  const GenderSelection({
    Key? key,
    required this.selectedGender,
    required this.onGenderSelected,
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
              Icons.person_outline,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              '性別',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...genderOptions.map(
          (gender) => _GenderOptionTile(
            label: gender['label'] as String,
            icon: gender['icon'] as IconData,
            isSelected: selectedGender == gender['value'],
            onTap: () => onGenderSelected(gender['value'] as String),
            theme: theme,
          ),
        ),
      ],
    );
  }

  static List<Map<String, dynamic>> get genderOptions => [
    {'label': '女性', 'icon': Icons.female, 'value': '女性'},
    {'label': '男性', 'icon': Icons.male, 'value': '男性'},
  ];
}

class _GenderOptionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _GenderOptionTile({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                  size: 18,
                  color:
                      isSelected
                          ? theme.colorScheme.primary
                          : Colors.grey.shade600,
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    color:
                        isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    size: 18,
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
