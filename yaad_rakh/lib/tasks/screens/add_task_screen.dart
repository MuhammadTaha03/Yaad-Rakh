// lib/tasks/screens/add_task_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import '../models/task.dart';
import '../task_provider.dart';
import '../services/natural_language_parser.dart';
import '../widgets/category_chip.dart';
import '../widgets/date_time_picker.dart';
import '../widgets/repeat_selector.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedTime;
  RepeatOption _repeatOption = RepeatOption.none;
  TaskCategory _category = TaskCategory.other;

  void _onTitleChanged(String text) {
    if (text.isEmpty) return;
    
    // Process input text through rule-based natural language parser
    final result = NaturalLanguageParser.parse(text);
    
    if (result.detectedDate != null || result.detectedTime != null) {
      setState(() {
        if (result.detectedDate != null) {
          _selectedDate = result.detectedDate;
        }
        if (result.detectedTime != null) {
          _selectedTime = result.detectedTime;
        }
      });
    }
  }

  void _saveTask() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final provider = Provider.of<TaskProvider>(context, listen: false);
    final settingsBox = Hive.box('settings');
    final activeLang = settingsBox.get('languageId', defaultValue: 'en') as String;
    final defaultOffset = settingsBox.get('defaultOffsetMinutes', defaultValue: 15) as int;

    final task = Task(
      id: const Uuid().v4(),
      title: title,
      dueDate: _selectedDate,
      dueTime: _selectedTime,
      repeatOption: _repeatOption,
      category: _category,
      createdAt: DateTime.now(),
      languageId: activeLang,
      reminderOffsetMinutes: defaultOffset,
    );

    await provider.addTask(task);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Task"),
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Title TextField
            TextField(
              controller: _titleController,
              autofocus: true,
              maxLines: 2,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: "What needs to be done?",
                hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
                border: InputBorder.none,
              ),
              onChanged: _onTitleChanged,
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            
            // Scheduling picker
            DateTimePicker(
              selectedDate: _selectedDate,
              selectedTime: _selectedTime,
              onDateSelected: (date) => setState(() => _selectedDate = date),
              onTimeSelected: (time) => setState(() => _selectedTime = time),
            ),
            const SizedBox(height: 24),
            
            // Repetition triggers
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.repeat, color: theme.colorScheme.primary),
              title: const Text("Repeat"),
              trailing: Text(
                _repeatOption.name.toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
              ),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  builder: (_) => RepeatSelector(
                    currentOption: _repeatOption,
                    onOptionSelected: (opt) => setState(() => _repeatOption = opt),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            
            // Category badges
            Text(
              "Category",
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              children: TaskCategory.values.map((cat) {
                return CategoryChip(
                  category: cat,
                  isSelected: _category == cat,
                  onSelected: (selectedCat) => setState(() => _category = selectedCat),
                );
              }).toList(),
            ),
            const SizedBox(height: 48),
            
            // Actions
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  "SAVE TASK",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
