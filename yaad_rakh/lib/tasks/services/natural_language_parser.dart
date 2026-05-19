// lib/tasks/services/natural_language_parser.dart

class ParsedTaskInput {
  final String cleanTitle;
  final DateTime? detectedDate;
  final String? detectedTime; // "HH:mm"

  const ParsedTaskInput({
    required this.cleanTitle,
    this.detectedDate,
    this.detectedTime,
  });
}

class NaturalLanguageParser {
  static ParsedTaskInput parse(String input) {
    String text = input.toLowerCase().trim();
    DateTime? date;
    String? time;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // --- Date keywords ---
    if (_contains(text, ['aaj', 'آج', 'today'])) {
      date = today;
    } else if (_contains(text, ['kal', 'کل', 'tomorrow'])) {
      date = today.add(const Duration(days: 1));
    } else if (_contains(text, ['parso', 'پرسوں', 'day after'])) {
      date = today.add(const Duration(days: 2));
    } else if (_contains(text, ['is hafte', 'اس ہفتے', 'this week'])) {
      date = today.add(const Duration(days: 3));
    } else if (_contains(text, ['agale hafte', 'اگلے ہفتے', 'next week'])) {
      date = today.add(const Duration(days: 7));
    }

    // Day names (English + Roman Urdu + Urdu)
    const dayNames = {
      'monday': 1, 'somwar': 1, 'سوموار': 1,
      'tuesday': 2, 'mangal': 2, 'منگل': 2,
      'wednesday': 3, 'budh': 3, 'بدھ': 3,
      'thursday': 4, 'jumerat': 4, 'جمعرات': 4,
      'friday': 5, 'jumma': 5, 'جمعہ': 5,
      'saturday': 6, 'hafta': 6, 'ہفتہ': 6,
      'sunday': 7, 'itwar': 7, 'اتوار': 7,
    };
    for (final entry in dayNames.entries) {
      if (text.contains(entry.key)) {
        final targetWeekday = entry.value;
        int diff = targetWeekday - now.weekday;
        if (diff <= 0) diff += 7;
        date = today.add(Duration(days: diff));
        break;
      }
    }

    // --- Time patterns ---
    // Matches: "9 baje", "9:30", "9 AM", "9 PM", "9 bajay"
    final timeRegex = RegExp(
      r'(\d{1,2})(?::(\d{2}))?\s*'
      r'(baje|bajay|بجے|am|pm|a\.m|p\.m)?',
      caseSensitive: false,
    );
    final match = timeRegex.firstMatch(text);
    if (match != null) {
      int hour = int.parse(match.group(1)!);
      int minute = int.tryParse(match.group(2) ?? '0') ?? 0;
      final suffix = (match.group(3) ?? '').toLowerCase();

      if (suffix == 'pm' || suffix == 'p.m') {
        if (hour < 12) hour += 12;
      } else if (suffix == 'am' || suffix == 'a.m') {
        if (hour == 12) hour = 0;
      }

      time = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    }

    // Remove matched keywords from title
    String clean = input;
    final removeWords = [
      'aaj', 'kal', 'parso', 'baje', 'bajay', 'today', 'tomorrow',
      'is hafte', 'agale hafte', 'this week', 'next week',
    ];
    for (final w in removeWords) {
      clean = clean.replaceAll(RegExp(w, caseSensitive: false), '').trim();
    }
    clean = clean.replaceAll(timeRegex, '').trim();
    clean = clean.replaceAll(RegExp(r'\s+'), ' ').trim();

    return ParsedTaskInput(
      cleanTitle: clean.isEmpty ? input : clean,
      detectedDate: date,
      detectedTime: time,
    );
  }

  static bool _contains(String text, List<String> keywords) =>
      keywords.any((k) => text.contains(k));
}
