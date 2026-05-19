// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'tasks/models/task.dart';
import 'tasks/task_provider.dart';
import 'notifications/models/notification_settings.dart';
import 'notifications/notification_provider.dart';
import 'notifications/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize DBs
  await Hive.initFlutter();
  
  // Register adapters
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(RepeatOptionAdapter());
  Hive.registerAdapter(TaskCategoryAdapter());
  Hive.registerAdapter(NotificationSettingsAdapter());

  // Open Hive boxes
  final settingsBox = await Hive.openBox('settings');
  final tasksBox = await Hive.openBox<Task>('tasks');

  // 2. Initialize timezone & local channels
  final notificationService = NotificationService();
  await notificationService.init();

  // 3. Complete Boot/Start Rescheduling Routine
  // Runs silently on startup to ensure alarm systems perfectly reflect the Hive state
  try {
    final String activeLang = settingsBox.get('languageId', defaultValue: 'en') as String;
    final List<Task> pendingTasks = tasksBox.values.where((t) => !t.isCompleted).toList();
    
    // Reschedule all active reminders
    for (final task in pendingTasks) {
      await notificationService.scheduleTaskReminder(task, activeLang);
    }
    
    // Reschedule morning summaries
    final summariesEnabled = settingsBox.get('enableMorningSummary', defaultValue: true) as bool;
    final summaryTime = settingsBox.get('morningSummaryTime', defaultValue: "08:00") as String;
    if (summariesEnabled) {
      await notificationService.scheduleMorningSummaries(pendingTasks, activeLang, summaryTime);
    }
    debugPrint("Startup alarm synchronization completed. Pending tasks verified: ${pendingTasks.length}");
  } catch (e) {
    debugPrint("Startup alarm synchronization failed: $e");
  }

  // 4. Request runtime permissions
  await notificationService.requestPermissions();

  // 5. Run App
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const YaadRakhApp(),
    ),
  );
}

class YaadRakhApp extends StatelessWidget {
  const YaadRakhApp({super.key});

  @override
  Widget build(BuildContext context) {
    // We will render a placeholder or home dashboard screen
    return MaterialApp(
      title: 'Yaad Rakh',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF14B8A6), // Premium vibrant teal
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF14B8A6),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const TempDashboard(),
    );
  }
}

class TempDashboard extends StatelessWidget {
  const TempDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yaad Rakh — یاد رکھ'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_active_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Reminders & Notifications Module Active',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Run "flutter test" to verify isolated timezone operations, boundary ID safety, and localized triggers.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
