// lib/notifications/notification_localization.dart

class NotificationLocalization {
  static String getReminderTitle(String lang) {
    switch (lang) {
      case 'ur':
        return 'کام کی یاددہانی ⏰';
      case 'roman_ur':
        return 'Kaam ki yaad-dehani ⏰';
      default:
        return 'Task Reminder ⏰';
    }
  }

  static String getReminderBody(String lang, String taskTitle, String? time) {
    final timeStr = time != null ? ' ($time)' : '';
    switch (lang) {
      case 'ur':
        return 'کیا آپ نے یہ کام کر لیا؟ "$taskTitle"$timeStr';
      case 'roman_ur':
        return 'Kya aapne ye kaam kar liya? "$taskTitle"$timeStr';
      default:
        return 'Did you complete this task? "$taskTitle"$timeStr';
    }
  }

  static String getOverdueTitle(String lang) {
    switch (lang) {
      case 'ur':
        return 'کام کی معیاد ختم! ⚠️';
      case 'roman_ur':
        return 'Kaam ka time guzar gaya! ⚠️';
      default:
        return 'Task Overdue! ⚠️';
    }
  }

  static String getOverdueBody(String lang, String taskTitle) {
    switch (lang) {
      case 'ur':
        return 'یہ کام ابھی تک ادھورا ہے: "$taskTitle"';
      case 'roman_ur':
        return 'Ye kaam abhi tak adhura hai: "$taskTitle"';
      default:
        return 'This task is still pending: "$taskTitle"';
    }
  }

  static String getMorningSummaryTitle(String lang) {
    switch (lang) {
      case 'ur':
        return 'السلام علیکم! آج کا شیڈول 🌅';
      case 'roman_ur':
        return 'Salaam! Today\'s schedule 🌅';
      default:
        return 'Good morning! Today\'s Schedule 🌅';
    }
  }

  static String getMorningSummaryBody(String lang, int count) {
    switch (lang) {
      case 'ur':
        return 'آج آپ کے $count اہم کام ہیں۔ اپنی لسٹ دیکھیں۔';
      case 'roman_ur':
        return 'Aaj aap ke $count aham kaam hain. Apni list dekhein.';
      default:
        return 'You have $count important tasks today. Open your list.';
    }
  }
}
