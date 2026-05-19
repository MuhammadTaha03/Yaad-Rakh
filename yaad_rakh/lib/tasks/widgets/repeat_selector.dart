// lib/tasks/widgets/repeat_selector.dart

import 'package:flutter/material.dart';
import '../models/task.dart';

class RepeatSelector extends StatelessWidget {
  final RepeatOption currentOption;
  final ValueChanged<RepeatOption> onOptionSelected;

  const RepeatSelector({
    super.key,
    required this.currentOption,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Repeat Options",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: RepeatOption.values.length,
            itemBuilder: (context, index) {
              final option = RepeatOption.values[index];
              final isSelected = option == currentOption;

              return ListTile(
                leading: Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.4),
                ),
                title: Text(
                  option.name.toUpperCase(),
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                onTap: () {
                  onOptionSelected(option);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
