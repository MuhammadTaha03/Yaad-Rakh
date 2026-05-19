// lib/tasks/widgets/task_tile.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../task_provider.dart';
import '../screens/edit_task_screen.dart';

class TaskTile extends StatelessWidget {
  final Task task;

  const TaskTile({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context, listen: false);
    final theme = Theme.of(context);
    
    // Resolve dynamic colors for categories
    Color activeColor;
    switch (task.category) {
      case TaskCategory.home:
        activeColor = const Color(0xFF3B82F6);
        break;
      case TaskCategory.work:
        activeColor = const Color(0xFFEF4444);
        break;
      case TaskCategory.study:
        activeColor = const Color(0xFF10B981);
        break;
      case TaskCategory.shopping:
        activeColor = const Color(0xFFF59E0B);
        break;
      case TaskCategory.other:
        activeColor = const Color(0xFF8B5CF6);
        break;
    }

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: theme.colorScheme.error,
        child: const Icon(Icons.delete_sweep, color: Colors.white, size: 28),
      ),
      onDismissed: (_) async {
        final deleted = await provider.deleteTask(task.id);
        if (deleted != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Deleted: '${deleted.title}'"),
              action: SnackBarAction(
                label: "UNDO",
                onPressed: () => provider.undoDelete(deleted),
              ),
            ),
          );
        }
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Checkbox(
          value: task.isCompleted,
          activeColor: theme.colorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          onChanged: (_) {
            provider.toggleComplete(task.id);
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? theme.colorScheme.onSurface.withOpacity(0.4) : theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Row(
          children: [
            // Colored Category Indicator
            Container(
              margin: const EdgeInsets.only(top: 6, right: 8),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: activeColor,
                shape: BoxShape.circle,
              ),
            ),
            if (task.dueDate != null) ...[
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  "${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}",
                  style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                ),
              ),
            ],
            if (task.dueTime != null) ...[
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 8),
                child: Text(
                  task.dueTime!,
                  style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                ),
              ),
            ],
            if (task.repeatOption != RepeatOption.none) ...[
              Container(
                margin: const EdgeInsets.only(top: 6, left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  task.repeatOption.name.toUpperCase(),
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: theme.colorScheme.onSecondaryContainer),
                ),
              ),
            ]
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.mode_edit_outline_outlined, size: 20),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditTaskScreen(task: task),
              ),
            );
          },
        ),
      ),
    );
  }
}
