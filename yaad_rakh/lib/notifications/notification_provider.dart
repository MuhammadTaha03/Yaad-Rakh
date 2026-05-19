// lib/notifications/notification_provider.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'notification_service.dart';
import '../tasks/models/task.dart';
import 'notification_exception.dart';

class NotificationProvider extends ChangeNotifier {
  final _service = NotificationService();
  final Box _settingsBox = Hive.box('settings');

  bool get isNotificationEnabled =>
      _settingsBox.get('enableReminders', defaultValue: true) as bool;

  bool get isMorningSummaryEnabled =>
      _settingsBox.get('enableMorningSummary', defaultValue: true) as bool;

  String get morningSummaryTime =>
      _settingsBox.get('morningSummaryTime', defaultValue: "08:00") as String;

  int get defaultOffsetMinutes =>
      _settingsBox.get('defaultOffsetMinutes', defaultValue: 15) as int;

  Future<void> setNotificationEnabled(bool enabled, List<Task> pendingTasks, String lang) async {
    await _settingsBox.put('enableReminders', enabled);
    notifyListeners();

    try {
      if (!enabled) {
        // Cancel everything
        for (final t in pendingTasks) {
          await _service.cancelTaskReminder(t.id);
        }
      } else {
        // Re-schedule everything
        for (final t in pendingTasks) {
          await _service.scheduleTaskReminder(t, lang);
        }
      }
    } on NotificationSchedulerException catch (e) {
      // Surface native configuration error details to telemetry/analytics
      debugPrint("Notification operation failed in provider settings hook: $e");
    }
  }

  Future<void> setMorningSummaryEnabled(bool enabled, List<Task> pendingTasks, String lang) async {
    await _settingsBox.put('enableMorningSummary', enabled);
    notifyListeners();

    try {
      if (!enabled) {
        await _service.cancelAllMorningSummaries();
      } else {
        await _service.scheduleMorningSummaries(pendingTasks, lang, morningSummaryTime);
      }
    } on NotificationSchedulerException catch (e) {
      debugPrint("Morning summary operation failed in settings hook: $e");
    }
  }

  Future<void> setMorningSummaryTime(String time, List<Task> pendingTasks, String lang) async {
    await _settingsBox.put('morningSummaryTime', time);
    notifyListeners();
    try {
      if (isMorningSummaryEnabled) {
        await _service.scheduleMorningSummaries(pendingTasks, lang, time);
      }
    } on NotificationSchedulerException catch (e) {
      debugPrint("Rescheduling morning summaries failed: $e");
    }
  }

  Future<void> setDefaultOffset(int minutes) async {
    await _settingsBox.put('defaultOffsetMinutes', minutes);
    notifyListeners();
  }

  /// Global rescheduling routine to process settings-level language shifts
  Future<void> rescheduleAllReminders(List<Task> pendingTasks, String newLanguageId) async {
    try {
      for (final task in pendingTasks) {
        await _service.cancelTaskReminder(task.id);
        await _service.scheduleTaskReminder(task, newLanguageId);
      }
      if (isMorningSummaryEnabled) {
        await _service.scheduleMorningSummaries(pendingTasks, newLanguageId, morningSummaryTime);
      }
    } on NotificationSchedulerException catch (e) {
      debugPrint("Language-shift notification refresh failed: $e");
    }
  }
}
