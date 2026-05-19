// lib/notifications/models/notification_settings.dart

import 'package:hive/hive.dart';

part 'notification_settings.g.dart';

@HiveType(typeId: 4)
class NotificationSettings extends HiveObject {
  @HiveField(0)
  bool enableReminders;

  @HiveField(1)
  bool enableMorningSummary;

  @HiveField(2)
  String morningSummaryTime; // "HH:mm" - e.g., "08:00"

  @HiveField(3)
  int defaultOffsetMinutes; // 15 by default

  NotificationSettings({
    this.enableReminders = true,
    this.enableMorningSummary = true,
    this.morningSummaryTime = "08:00",
    this.defaultOffsetMinutes = 15,
  });
}
