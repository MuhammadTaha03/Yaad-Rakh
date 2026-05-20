// lib/notifications/notification_service.dart

import 'dart:developer';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../tasks/models/task.dart';
import 'notification_localization.dart';
import 'notification_exception.dart';

/// Global static background handler for Firebase Messaging.
/// Must be placed outside classes to run in its own Dart isolate.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("Handling background cloud message: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localPlugin =
      FlutterLocalNotificationsPlugin();
  late final FirebaseMessaging _fcm;

  // Unique channel IDs
  static const String _reminderChannelId = 'task_reminders_channel';
  static const String _reminderChannelName = 'Task Reminders';
  static const String _summaryChannelId = 'morning_summaries_channel';
  static const String _summaryChannelName = 'Morning Summaries';
  static const String _cloudChannelId = 'cloud_announcements_channel';
  static const String _cloudChannelName = 'Cloud Announcements';

  Future<void> init() async {
    // 1. Initialize timezone databases
    tz.initializeTimeZones();
    try {
      final String timeZoneName = DateTime.now().timeZoneName;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      log("Timezone configured successfully to: $timeZoneName");
    } catch (e) {
      tz.setLocalLocation(
        tz.getLocation('Asia/Karachi'),
      ); // Safe fallback for Pakistan
      log("Timezone set to fallback: Asia/Karachi due to: $e");
    }

    // 2. Local notification settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // 3. Initialize Firebase Cloud Messaging (FCM)
    await _initFCM();
  }

  /// Initialize Firebase Messaging and listeners
  Future<void> _initFCM() async {
    try {
      _fcm = FirebaseMessaging.instance;
      // Configure background messaging
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Request permission (iOS specific, safe on Android)
      NotificationSettings fcmSettings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      log(
        'FCM Permission authorization status: ${fcmSettings.authorizationStatus}',
      );

      // Retrieve registration token
      String? token = await _fcm.getToken();
      log("FCM Registration Token: $token");
      if (token != null) {
        await Hive.box('settings').put('fcmToken', token);
      }

      // Configure foreground message listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        log(
          "Received foreground cloud message: ${message.notification?.title}",
        );
        _showForegroundPushNotification(message);
      });
    } catch (e) {
      log("Failed to initialize FCM client: $e");
    }
  }

  /// Displays a remote foreground FCM payload as a high-importance local notification
  void _showForegroundPushNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      _localPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _cloudChannelId,
            _cloudChannelName,
            channelDescription: 'Direct announcements from the Yaad Rakh team',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    }
  }

  /// Request runtime notification permissions
  Future<bool> requestPermissions() async {
    final androidImplementation = _localPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    bool? androidGranted = false;
    if (androidImplementation != null) {
      androidGranted = await androidImplementation
          .requestNotificationsPermission();
    }

    final iosImplementation = _localPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    bool? iosGranted = false;
    if (iosImplementation != null) {
      iosGranted = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    return (androidGranted ?? false) || (iosGranted ?? false);
  }

  /// Pure decision engine for fallback calculation. Excluded from native context.
  static DateTime? calculateScheduledTime(
    DateTime dueDateTime,
    int offsetMinutes,
    DateTime now,
  ) {
    if (offsetMinutes == -1) return null;

    final reminderTime = dueDateTime.subtract(Duration(minutes: offsetMinutes));

    if (reminderTime.isAfter(now)) {
      return reminderTime; // Branch 1: Normal offset scheduling in future
    }

    if (dueDateTime.isAfter(now)) {
      return dueDateTime; // Branch 2: Fallback to exact "On Time" alarm
    }

    return null; // Branch 3: Expired entirely, skip
  }

  /// Mathematical Isolation Hashing for Notification IDs:
  /// Primary reminders hash to: [0, 899,999]
  /// Overdue alerts hash to: [1,000,000, 1,899,999]
  /// Morning summaries use reserved: [2,000,000, 2,000,006]
  /// This mathematically guarantees zero overlap between alarm channels.
  @visibleForTesting
  int hashTaskId(String id) {
    return (id.hashCode & 0x7FFFFFFF) % 900000;
  }

  @visibleForTesting
  int hashOverdueId(String id) {
    return hashTaskId(id) + 1000000;
  }

  /// Schedule standard task reminder + secondary isolated overdue nudge
  Future<void> scheduleTaskReminder(Task task, String languageId) async {
    if (task.isCompleted ||
        task.dueDate == null ||
        task.reminderOffsetMinutes == -1) {
      await cancelTaskReminder(task.id);
      return;
    }

    // 1. Calculate scheduled target time
    DateTime dueDateTime = task.dueDate!;
    if (task.dueTime != null) {
      final parts = task.dueTime!.split(':');
      final hour = int.parse(parts[0]);
      final min = int.parse(parts[1]);
      dueDateTime = DateTime(
        dueDateTime.year,
        dueDateTime.month,
        dueDateTime.day,
        hour,
        min,
      );
    }

    final targetTime = calculateScheduledTime(
      dueDateTime,
      task.reminderOffsetMinutes,
      DateTime.now(),
    );

    if (targetTime == null) {
      log(
        "Skipping task reminder for '${task.title}': Target and fallbacks are entirely in the past.",
      );
      return;
    }

    try {
      final scheduledTZ = tz.TZDateTime.from(targetTime, tz.local);
      final reminderId = hashTaskId(task.id);

      // 2. Build details
      const androidDetails = AndroidNotificationDetails(
        _reminderChannelId,
        _reminderChannelName,
        channelDescription: 'Fires alerts for scheduled tasks',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // 3. Register native scheduled alarm
      await _localPlugin.zonedSchedule(
        reminderId,
        NotificationLocalization.getReminderTitle(languageId),
        NotificationLocalization.getReminderBody(
          languageId,
          task.title,
          task.dueTime,
        ),
        scheduledTZ,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      log(
        "Notification scheduled successfully for task: '${task.title}' at: $scheduledTZ (ID: $reminderId)",
      );

      // 4. Schedule standard overdue alert (30 minutes after due time)
      final overdueTime = dueDateTime.add(const Duration(minutes: 30));
      if (overdueTime.isAfter(DateTime.now())) {
        final overdueTZ = tz.TZDateTime.from(overdueTime, tz.local);
        final overdueId = hashOverdueId(task.id);

        await _localPlugin.zonedSchedule(
          overdueId,
          NotificationLocalization.getOverdueTitle(languageId),
          NotificationLocalization.getOverdueBody(languageId, task.title),
          overdueTZ,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        log(
          "Overdue alarm scheduled for task: '${task.title}' at: $overdueTZ (ID: $overdueId)",
        );
      }
    } catch (e, stack) {
      throw NotificationSchedulerException(
        "Failed scheduling task alert natively: $e",
        details: stack,
      );
    }
  }

  /// Cancels both primary task reminder and secondary overdue alarms
  Future<void> cancelTaskReminder(String taskId) async {
    try {
      final reminderId = hashTaskId(taskId);
      final overdueId = hashOverdueId(taskId);
      await _localPlugin.cancel(reminderId); // Primary reminder
      await _localPlugin.cancel(overdueId); // Overdue alert
      log(
        "Cancelled all notifications for task: $taskId (IDs: $reminderId, $overdueId)",
      );
    } catch (e, stack) {
      throw NotificationSchedulerException(
        "Failed cancelling task alert natively: $e",
        details: stack,
      );
    }
  }

  /// Pre-schedules morning rolling summaries for the next 7 days
  Future<void> scheduleMorningSummaries(
    List<Task> pendingTasks,
    String languageId,
    String summaryTime,
  ) async {
    final parts = summaryTime.split(':');
    final targetHour = int.parse(parts[0]);
    final targetMin = int.parse(parts[1]);

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    const androidDetails = AndroidNotificationDetails(
      _summaryChannelId,
      _summaryChannelName,
      channelDescription: 'Fires every morning summarizing today\'s task load',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    try {
      // Morning summaries will use reserved static IDs 2000000 to 2000006
      for (int i = 0; i < 7; i++) {
        final targetDay = todayStart.add(Duration(days: i));
        final notificationTime = DateTime(
          targetDay.year,
          targetDay.month,
          targetDay.day,
          targetHour,
          targetMin,
        );
        final notificationId = 2000000 + i;

        // Skip today's summary if 8:00 AM has already passed
        if (i == 0 && notificationTime.isBefore(now)) {
          continue;
        }

        // Count tasks due on this specific date
        final dailyCount = pendingTasks.where((t) {
          if (t.dueDate == null) return false;
          final d = t.dueDate!;
          return d.year == targetDay.year &&
              d.month == targetDay.month &&
              d.day == targetDay.day;
        }).length;

        // UX Zero-Task Filter: Skip scheduling summaries for days with no tasks.
        // Explicitly cancel any pre-scheduled alarms for this day slot to prevent stale notifications.
        if (dailyCount == 0) {
          await _localPlugin.cancel(notificationId);
          log(
            "Skipped morning summary for day offset $i: No tasks due (Alarms cleared).",
          );
          continue;
        }

        final summaryTZ = tz.TZDateTime.from(notificationTime, tz.local);

        await _localPlugin.zonedSchedule(
          notificationId,
          NotificationLocalization.getMorningSummaryTitle(languageId),
          NotificationLocalization.getMorningSummaryBody(
            languageId,
            dailyCount,
          ),
          summaryTZ,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
      log("7-day morning summaries pre-scheduled successfully.");
    } catch (e, stack) {
      throw NotificationSchedulerException(
        "Failed scheduling morning rolling summaries: $e",
        details: stack,
      );
    }
  }

  /// Cancels all scheduled rolling morning summaries (IDs 2000000 to 2000006)
  Future<void> cancelAllMorningSummaries() async {
    try {
      for (int i = 0; i < 7; i++) {
        await _localPlugin.cancel(2000000 + i);
      }
      log("Cancelled all rolling morning summaries successfully.");
    } catch (e, stack) {
      throw NotificationSchedulerException(
        "Failed to cancel rolling morning summaries: $e",
        details: stack,
      );
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    log(
      "Notification clicked! ID: ${response.id}, Payload: ${response.payload}",
    );
  }
}
