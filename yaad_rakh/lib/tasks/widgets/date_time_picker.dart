// lib/tasks/widgets/date_time_picker.dart

import 'package:flutter/material.dart';

class DateTimePicker extends StatelessWidget {
  final DateTime? selectedDate;
  final String? selectedTime;
  final ValueChanged<DateTime?> onDateSelected;
  final ValueChanged<String?> onTimeSelected;

  const DateTimePicker({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.onDateSelected,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // Date Selector button
        Expanded(
          child: TextButton.icon(
            onPressed: () async {
              final DateTime? date = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
              );
              onDateSelected(date);
            },
            icon: Icon(Icons.calendar_month, color: theme.colorScheme.primary),
            label: Text(
              selectedDate == null
                  ? "Select Date"
                  : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
              style: TextStyle(
                color: selectedDate == null ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                fontWeight: selectedDate == null ? FontWeight.normal : FontWeight.bold,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.12)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Time Selector button
        Expanded(
          child: TextButton.icon(
            onPressed: () async {
              final TimeOfDay? time = await showTimePicker(
                context: context,
                initialTime: selectedTime == null
                    ? TimeOfDay.now()
                    : TimeOfDay(
                        hour: int.parse(selectedTime!.split(':')[0]),
                        minute: int.parse(selectedTime!.split(':')[1]),
                      ),
              );
              if (time != null) {
                final formatted = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                onTimeSelected(formatted);
              } else {
                onTimeSelected(null);
              }
            },
            icon: Icon(Icons.access_time_filled, color: theme.colorScheme.primary),
            label: Text(
              selectedTime ?? "Select Time",
              style: TextStyle(
                color: selectedTime == null ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                fontWeight: selectedTime == null ? FontWeight.normal : FontWeight.bold,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.12)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
