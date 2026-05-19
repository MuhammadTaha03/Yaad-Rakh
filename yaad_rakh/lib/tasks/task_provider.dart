// lib/tasks/task_provider.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'models/task.dart';
import 'models/custom_category.dart';
import 'services/firestore_sync_service.dart';
import '../notifications/notification_service.dart';
import '../notifications/notification_exception.dart';

class TaskProvider extends ChangeNotifier {
  final Box<Task> _box = Hive.box<Task>('tasks');
  final FirestoreSyncService _sync = FirestoreSyncService();
  final NotificationService _notifications = NotificationService();
  final _uuid = const Uuid();

  TaskProvider() {
    _seedDefaultCategories();
  }

  List<CustomCategory> get customCategories =>
      Hive.box<CustomCategory>('custom_categories').values.toList();

  Future<void> addCustomCategory(CustomCategory category) async {
    final box = Hive.box<CustomCategory>('custom_categories');
    await box.put(category.id, category);
    notifyListeners();
  }

  Future<void> deleteCustomCategory(String id) async {
    final box = Hive.box<CustomCategory>('custom_categories');
    await box.delete(id);
    notifyListeners();
  }

  void _seedDefaultCategories() {
    final box = Hive.box<CustomCategory>('custom_categories');
    if (box.isEmpty) {
      final defaults = [
        CustomCategory(id: 'home', nameEnglish: 'Home', nameUrdu: 'گھر', nameRomanUrdu: 'Ghar', colorHex: 0xFF3B82F6),
        CustomCategory(id: 'work', nameEnglish: 'Work', nameUrdu: 'کام', nameRomanUrdu: 'Kaam', colorHex: 0xFFEF4444),
        CustomCategory(id: 'study', nameEnglish: 'Study', nameUrdu: 'پڑھائی', nameRomanUrdu: 'Padhai', colorHex: 0xFF10B981),
        CustomCategory(id: 'shopping', nameEnglish: 'Shopping', nameUrdu: 'خریداری', nameRomanUrdu: 'Kharidari', colorHex: 0xFFF59E0B),
        CustomCategory(id: 'other', nameEnglish: 'Other', nameUrdu: 'دیگر', nameRomanUrdu: 'Deegar', colorHex: 0xFF8B5CF6),
      ];
      for (final cat in defaults) {
        box.put(cat.id, cat);
      }
    }
  }

  List<Task> get tasks => _box.values.toList()
    ..sort((a, b) => (a.dueDate ?? DateTime(2100))
        .compareTo(b.dueDate ?? DateTime(2100)));

  List<Task> get pendingTasks =>
      tasks.where((t) => !t.isCompleted).toList();

  List<Task> get completedTasks =>
      tasks.where((t) => t.isCompleted).toList();

  List<Task> get overdueTasks {
    final now = DateTime.now();
    return pendingTasks.where((task) {
      if (task.dueDate == null) return false;
      
      int hour = 0;
      int minute = 0;
      if (task.dueTime != null) {
        final parts = task.dueTime!.split(':');
        hour = int.parse(parts[0]);
        minute = int.parse(parts[1]);
      }
      
      final dueDateTime = DateTime(
        task.dueDate!.year,
        task.dueDate!.month,
        task.dueDate!.day,
        hour,
        minute,
      );
      
      return dueDateTime.isBefore(now);
    }).toList();
  }

  List<Task> get todayTasks {
    final now = DateTime.now();
    final overdue = overdueTasks;
    return pendingTasks.where((task) {
      if (task.dueDate == null) return false;
      
      final isSameDay = task.dueDate!.year == now.year &&
                        task.dueDate!.month == now.month &&
                        task.dueDate!.day == now.day;
      
      return isSameDay && !overdue.any((o) => o.id == task.id);
    }).toList();
  }

  List<Task> get upcomingTasks {
    final overdue = overdueTasks;
    final today = todayTasks;
    return pendingTasks.where((task) {
      return !overdue.any((o) => o.id == task.id) && 
             !today.any((t) => t.id == task.id);
    }).toList();
  }

  // Helper to fetch current language ID from settings dynamically
  String get _currentLanguageId =>
      Hive.box('settings').get('languageId', defaultValue: 'en') as String;

  Future<void> addTask(Task task) async {
    await _box.put(task.id, task);
    notifyListeners();
    _sync.pushTask(task); // Silent background sync

    try {
      await _notifications.scheduleTaskReminder(task, _currentLanguageId);
      await updateMorningSummaries();
    } on NotificationSchedulerException catch (e) {
      debugPrint("Failed to register alarms for added task: $e");
    }
  }

  Future<void> updateTask(Task task) async {
    await _box.put(task.id, task);
    notifyListeners();
    _sync.pushTask(task);

    try {
      await _notifications.scheduleTaskReminder(task, _currentLanguageId);
      await updateMorningSummaries();
    } on NotificationSchedulerException catch (e) {
      debugPrint("Failed to register alarms for updated task: $e");
    }
  }

  Future<void> toggleComplete(String id) async {
    final task = _box.get(id);
    if (task == null) return;
    task.isCompleted = !task.isCompleted;
    await task.save();
    notifyListeners();
    _sync.pushTask(task);

    try {
      if (task.isCompleted) {
        await _notifications.cancelTaskReminder(task.id);
      } else {
        await _notifications.scheduleTaskReminder(task, _currentLanguageId);
      }
      await updateMorningSummaries();
    } on NotificationSchedulerException catch (e) {
      debugPrint("Failed to alter alarms on completion: $e");
    }

    if (task.isCompleted) {
      _generateNextRecurring(task);
    }
  }

  Future<Task?> deleteTask(String id) async {
    final task = _box.get(id);
    if (task == null) return null;
    await _box.delete(id);
    notifyListeners();
    _sync.deleteTask(id);

    try {
      await _notifications.cancelTaskReminder(id);
      await updateMorningSummaries();
    } on NotificationSchedulerException catch (e) {
      debugPrint("Failed to cancel alarms on deletion: $e");
    }
    return task;
  }

  Future<void> undoDelete(Task task) async {
    await _box.put(task.id, task);
    notifyListeners();
    _sync.pushTask(task);

    try {
      await _notifications.scheduleTaskReminder(task, _currentLanguageId);
      await updateMorningSummaries();
    } on NotificationSchedulerException catch (e) {
      debugPrint("Failed to restore task alarms on undo: $e");
    }
  }

  Future<void> updateMorningSummaries() async {
    final settingsBox = Hive.box('settings');
    final summariesEnabled = settingsBox.get('enableMorningSummary', defaultValue: true) as bool;
    final summaryTime = settingsBox.get('morningSummaryTime', defaultValue: "08:00") as String;

    if (summariesEnabled) {
      try {
        await _notifications.scheduleMorningSummaries(pendingTasks, _currentLanguageId, summaryTime);
      } on NotificationSchedulerException catch (e) {
        debugPrint("Failed morning summaries rolling scheduling: $e");
      }
    }
  }

  Future<void> syncFromFirestore(String uid) async {
    final remoteTasks = await _sync.fetchAll(uid);
    for (final t in remoteTasks) {
      if (!_box.containsKey(t.id)) {
        await _box.put(t.id, t);
        try {
          await _notifications.scheduleTaskReminder(t, _currentLanguageId);
        } on NotificationSchedulerException catch (e) {
          debugPrint("Failed scheduling task reminder during sync: $e");
        }
      }
    }
    await updateMorningSummaries();
    notifyListeners();
  }

  // Generates next occurrence for recurring tasks (Single Active-Instance Strategy)
  void _generateNextRecurring(Task completed) {
    if (completed.repeatOption == RepeatOption.none || completed.dueDate == null) return;

    DateTime nextDate;
    switch (completed.repeatOption) {
      case RepeatOption.daily:
        nextDate = completed.dueDate!.add(const Duration(days: 1));
        break;
      case RepeatOption.weekly:
        nextDate = completed.dueDate!.add(const Duration(days: 7));
        break;
      case RepeatOption.monthly:
        nextDate = DateTime(completed.dueDate!.year, completed.dueDate!.month + 1, completed.dueDate!.day);
        break;
      default:
        return;
    }

    final nextTask = Task(
      id: _uuid.v4(),
      title: completed.title,
      dueDate: nextDate,
      dueTime: completed.dueTime,
      repeatOption: completed.repeatOption,
      category: completed.category,
      createdAt: DateTime.now(),
      languageId: completed.languageId,
      reminderOffsetMinutes: completed.reminderOffsetMinutes,
    );

    addTask(nextTask);
  }
}
