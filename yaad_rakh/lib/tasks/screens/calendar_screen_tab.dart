// lib/tasks/screens/calendar_screen_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../task_provider.dart';
import '../models/task.dart';
import '../widgets/task_tile.dart';
import '../../onboarding/onboarding_provider.dart';

class CalendarScreenTab extends StatefulWidget {
  const CalendarScreenTab({super.key});

  @override
  State<CalendarScreenTab> createState() => _CalendarScreenTabState();
}

class _CalendarScreenTabState extends State<CalendarScreenTab> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<Task> _getTasksForDay(DateTime day, List<Task> allTasks) {
    return allTasks.where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.year == day.year &&
             task.dueDate!.month == day.month &&
             task.dueDate!.day == day.day;
    }).toList();
  }

  Color _getDotColor(Task task) {
    if (task.isCompleted) {
      return const Color(0xFF10B981); // Completed (Green)
    }

    // Check if overdue
    if (task.dueDate == null) return const Color(0xFF3B82F6);
    
    final now = DateTime.now();
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

    if (dueDateTime.isBefore(now)) {
      return const Color(0xFFEF4444); // Overdue (Red)
    }
    return const Color(0xFF3B82F6); // Pending (Blue)
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    final onboarding = Provider.of<OnboardingProvider>(context);
    final theme = Theme.of(context);
    
    final isUrdu = onboarding.languageId == 'ur';
    final isRoman = onboarding.languageId == 'roman_ur';

    // Localized Headers & Placeholders
    String listHeader = "Tasks for this Day";
    String emptyDayMessage = "No tasks scheduled for this day.";
    
    if (isUrdu) {
      listHeader = "اس دن کے کام";
      emptyDayMessage = "اس دن کے لیے کوئی کام شیڈول نہیں ہے۔";
    } else if (isRoman) {
      listHeader = "Is Din Ke Kaam";
      emptyDayMessage = "Is din koi kaam scheduled nahi hai.";
    }

    final tasksForSelectedDay = _getTasksForDay(_selectedDay ?? _focusedDay, provider.tasks);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Monthly Table Calendar Widget
        TableCalendar(
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365 * 5)),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          locale: isUrdu ? 'ur' : 'en_US',
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          eventLoader: (day) {
            return _getTasksForDay(day, provider.tasks);
          },
          
          // Styling the Calendar
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            todayTextStyle: TextStyle(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
            selectedDecoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            markerSize: 6.0,
            markersMaxCount: 4,
          ),
          
          // Color Coded Custom Marker Dots Builder
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isEmpty) return const SizedBox();
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: events.take(4).map((event) {
                  final task = event as Task;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1.0),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _getDotColor(task),
                      shape: BoxShape.circle,
                    ),
                  );
                }).toList(),
              );
            },
          ),
          
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        
        const Divider(),
        
        // 2. Tasks list for the selected day
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            listHeader,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        
        Expanded(
          child: tasksForSelectedDay.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      emptyDayMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: tasksForSelectedDay.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (context, index) {
                    return TaskTile(task: tasksForSelectedDay[index]);
                  },
                ),
        ),
      ],
    );
  }
}
