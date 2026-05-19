// lib/tasks/screens/add_task_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import '../models/task.dart';
import '../models/custom_category.dart';
import '../task_provider.dart';
import '../services/natural_language_parser.dart';
import '../widgets/date_time_picker.dart';
import '../widgets/repeat_selector.dart';
import '../../onboarding/onboarding_provider.dart';

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
  
  // Custom Category selection
  String _selectedCategoryId = "other"; // Default to 'other' custom category

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

  void _showCreateCategorySheet(BuildContext context, TaskProvider provider, OnboardingProvider onboarding) {
    final theme = Theme.of(context);
    final isUrdu = onboarding.languageId == 'ur';
    
    final nameEnController = TextEditingController();
    final nameUrController = TextEditingController();
    final nameRomanController = TextEditingController();
    
    int selectedColorHex = 0xFF3B82F6; // Default to Blue

    final colorsList = [
      0xFF3B82F6, // Blue
      0xFFEF4444, // Red
      0xFF10B981, // Green
      0xFFF59E0B, // Amber
      0xFF8B5CF6, // Purple
      0xFFEC4899, // Pink
      0xFF14B8A6, // Teal
      0xFFF97316, // Orange
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isUrdu ? "نئی کیٹیگری بنائیں" : "Create Custom Category",
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    
                    TextField(
                      controller: nameEnController,
                      decoration: const InputDecoration(
                        labelText: "Category Name (English)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameUrController,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        labelText: "کیٹیگری کا نام (اردو)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameRomanController,
                      decoration: const InputDecoration(
                        labelText: "Category Name (Roman Urdu)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    Text(
                      isUrdu ? "رنگ منتخب کریں" : "Select Color",
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 48,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: colorsList.length,
                        itemBuilder: (context, idx) {
                          final colorHex = colorsList[idx];
                          final isSelected = selectedColorHex == colorHex;
                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                selectedColorHex = colorHex;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Color(colorHex),
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(color: theme.colorScheme.onSurface, width: 3)
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          final en = nameEnController.text.trim();
                          final ur = nameUrController.text.trim();
                          final ro = nameRomanController.text.trim();
                          
                          if (en.isEmpty) return;
                          
                          final newCat = CustomCategory(
                            id: const Uuid().v4(),
                            nameEnglish: en,
                            nameUrdu: ur.isNotEmpty ? ur : en,
                            nameRomanUrdu: ro.isNotEmpty ? ro : en,
                            colorHex: selectedColorHex,
                          );
                          
                          await provider.addCustomCategory(newCat);
                          
                          setState(() {
                            _selectedCategoryId = newCat.id;
                          });
                          
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(isUrdu ? "کیٹیگری محفوظ کریں" : "SAVE CATEGORY"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _saveTask() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final provider = Provider.of<TaskProvider>(context, listen: false);
    final settingsBox = Hive.box('settings');
    final activeLang = settingsBox.get('languageId', defaultValue: 'en') as String;
    final defaultOffset = settingsBox.get('defaultOffsetMinutes', defaultValue: 15) as int;

    TaskCategory staticCat = TaskCategory.other;
    if (_selectedCategoryId == 'home') {
      staticCat = TaskCategory.home;
    } else if (_selectedCategoryId == 'work') {
      staticCat = TaskCategory.work;
    } else if (_selectedCategoryId == 'study') {
      staticCat = TaskCategory.study;
    } else if (_selectedCategoryId == 'shopping') {
      staticCat = TaskCategory.shopping;
    } else if (_selectedCategoryId == 'other') {
      staticCat = TaskCategory.other;
    }

    final task = Task(
      id: const Uuid().v4(),
      title: title,
      dueDate: _selectedDate,
      dueTime: _selectedTime,
      repeatOption: _repeatOption,
      category: staticCat,
      createdAt: DateTime.now(),
      languageId: activeLang,
      reminderOffsetMinutes: defaultOffset,
      customCategoryId: _selectedCategoryId,
    );

    await provider.addTask(task);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    final onboarding = Provider.of<OnboardingProvider>(context);
    final theme = Theme.of(context);
    
    final isUrdu = onboarding.languageId == 'ur';
    final isRoman = onboarding.languageId == 'roman_ur';

    String screenTitle = "Add New Task";
    String titleHint = "What needs to be done?";
    String repeatLabel = "Repeat";
    String categoryLabel = "Category";
    String saveBtnLabel = "SAVE TASK";

    if (isUrdu) {
      screenTitle = "نیا کام شامل کریں";
      titleHint = "کیا کرنا ہے؟";
      repeatLabel = "دہرائیں";
      categoryLabel = "کیٹیگری";
      saveBtnLabel = "کام محفوظ کریں";
    } else if (isRoman) {
      screenTitle = "Naya Kaam Add Karein";
      titleHint = "Kya kaam karna hai?";
      repeatLabel = "Dohrayein";
      categoryLabel = "Category";
      saveBtnLabel = "KAAM SAVE KAREIN";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          screenTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
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
                hintText: titleHint,
                hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
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
              title: Text(repeatLabel),
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
            
            // Custom Category Wrap Selector Grid
            Text(
              categoryLabel,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...provider.customCategories.map((cat) {
                  final isSelected = _selectedCategoryId == cat.id;
                  final color = Color(cat.colorHex);
                  
                  String displayName = cat.nameEnglish;
                  if (isUrdu) {
                    displayName = cat.nameUrdu;
                  } else if (isRoman) {
                    displayName = cat.nameRomanUrdu;
                  }

                  return ChoiceChip(
                    label: Text(
                      displayName,
                      style: TextStyle(
                        color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: color,
                    checkmarkColor: Colors.white,
                    backgroundColor: theme.colorScheme.surface,
                    side: BorderSide(
                      color: isSelected ? color : theme.colorScheme.onSurface.withValues(alpha: 0.12),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _selectedCategoryId = cat.id;
                        });
                      }
                    },
                  );
                }),
                
                // "+" Button to add a custom category
                ChoiceChip(
                  label: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 16),
                      SizedBox(width: 4),
                      Text("New"),
                    ],
                  ),
                  selected: false,
                  backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                  side: BorderSide(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (_) {
                    _showCreateCategorySheet(context, provider, onboarding);
                  },
                ),
              ],
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
                child: Text(
                  saveBtnLabel,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
