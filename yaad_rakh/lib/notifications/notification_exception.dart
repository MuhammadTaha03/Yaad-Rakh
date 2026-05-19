// lib/notifications/notification_exception.dart

class NotificationSchedulerException implements Exception {
  final String message;
  final dynamic details;

  NotificationSchedulerException(this.message, {this.details});

  @override
  String toString() => "NotificationSchedulerException: $message | Details: $details";
}
