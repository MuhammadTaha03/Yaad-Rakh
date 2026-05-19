// test/notification_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:yaad_rakh/notifications/notification_service.dart';
import 'package:yaad_rakh/notifications/notification_localization.dart';

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Karachi'));
  });

  group('Pure Fallback Logic Tests (calculateScheduledTime)', () {
    final DateTime now = DateTime(2026, 5, 20, 12, 0); // Mock "Now" = 12:00 PM

    test('Branch 1: Returns target offset when it is in the future', () {
      final DateTime dueTime = DateTime(2026, 5, 20, 13, 0); // Due 1:00 PM
      const int offset = 15; // 15 mins before = 12:45 PM
      
      final result = NotificationService.calculateScheduledTime(dueTime, offset, now);
      
      expect(result, isNotNull);
      expect(result, equals(DateTime(2026, 5, 20, 12, 45)));
    });

    test('Branch 2: Falls back to exact "On Time" when offset is in the past but due time is in the future', () {
      final DateTime dueTime = DateTime(2026, 5, 20, 12, 10); // Due 12:10 PM
      const int offset = 15; // 15 mins before = 11:55 AM (past)
      
      final result = NotificationService.calculateScheduledTime(dueTime, offset, now);
      
      expect(result, isNotNull);
      expect(result, equals(dueTime)); // falls back to 12:10 PM
    });

    test('Branch 3: Returns null when both offset and due times are in the past', () {
      final DateTime dueTime = DateTime(2026, 5, 20, 11, 50); // Due 11:50 AM (past)
      const int offset = 15; // 15 mins before = 11:35 AM (past)
      
      final result = NotificationService.calculateScheduledTime(dueTime, offset, now);
      
      expect(result, isNull);
    });
  });

  group('Notification ID Math Isolation Tests', () {
    final service = NotificationService();
    const String uuidA = "b24d7870-07bf-4f9b-ab9f-689369eb34a9";
    const String uuidB = "b24d7870-07bf-4f9b-ab9f-689369eb34aa";

    test('Isolated @visibleForTesting integer spaces prevent collisions between primary and overdue alarms', () {
      final int reminderIdA = service.hashTaskId(uuidA);
      final int overdueIdA = service.hashOverdueId(uuidA);
      final int reminderIdB = service.hashTaskId(uuidB);
      final int overdueIdB = service.hashOverdueId(uuidB);

      // Boundaries isolation assertion
      expect(reminderIdA, inClosedOpenRange(0, 900000));
      expect(reminderIdB, inClosedOpenRange(0, 900000));
      expect(overdueIdA, inClosedOpenRange(1000000, 1900000));
      expect(overdueIdB, inClosedOpenRange(1000000, 1900000));
      
      // Ensure zero cross-collision possible across adjacent inputs
      expect(overdueIdA, isNot(equals(reminderIdB)));
      expect(overdueIdB, isNot(equals(reminderIdA)));
    });
  });

  group('Localization String Generation Tests', () {
    test('Validates Localization String generation maps Urdu and English accurately', () {
      final urBodyText = NotificationLocalization.getReminderBody('ur', 'Doctor Appointment', '18:00');
      final enBodyText = NotificationLocalization.getReminderBody('en', 'Doctor Appointment', '18:00');

      expect(urBodyText, contains('کیا آپ نے یہ کام کر لیا؟'));
      expect(enBodyText, contains('Did you complete this task?'));
    });
  });
}
