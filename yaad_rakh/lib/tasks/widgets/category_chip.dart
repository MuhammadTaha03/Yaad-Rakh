// lib/tasks/widgets/category_chip.dart

import 'package:flutter/material.dart';
import '../models/task.dart';

class CategoryChip extends StatelessWidget {
  final TaskCategory category;
  final bool isSelected;
  final ValueChanged<TaskCategory> onSelected;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Resolve dynamic colors for categories
    Color activeColor;
    String name;

    switch (category) {
      case TaskCategory.home:
        activeColor = const Color(0xFF3B82F6); // Blue
        name = "Home";
        break;
      case TaskCategory.work:
        activeColor = const Color(0xFFEF4444); // Red
        name = "Work";
        break;
      case TaskCategory.study:
        activeColor = const Color(0xFF10B981); // Green
        name = "Study";
        break;
      case TaskCategory.shopping:
        activeColor = const Color(0xFFF59E0B); // Amber
        name = "Shopping";
        break;
      case TaskCategory.other:
        activeColor = const Color(0xFF8B5CF6); // Purple
        name = "Other";
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 8),
      child: FilterChip(
        label: Text(
          name,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedColor: activeColor,
        checkmarkColor: Colors.white,
        backgroundColor: theme.colorScheme.surface,
        side: BorderSide(
          color: isSelected ? activeColor : theme.colorScheme.onSurface.withOpacity(0.12),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onSelected: (_) => onSelected(category),
      ),
    );
  }
}
