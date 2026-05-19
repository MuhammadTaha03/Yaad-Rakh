// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'tasks/models/task.dart';
import 'tasks/task_provider.dart';
import 'notifications/models/notification_settings.dart';
import 'notifications/notification_provider.dart';
import 'notifications/notification_service.dart';
import 'onboarding/onboarding_provider.dart';
import 'onboarding/screens/language_selection.dart';
import 'tasks/screens/task_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dynamic localized engine
  await EasyLocalization.ensureInitialized();

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
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ur')],
      path: 'assets/lang',
      fallbackLocale: const Locale('en'),
      useOnlyLangCode: true,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TaskProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
          ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ],
        child: const YaadRakhApp(),
      ),
    ),
  );
}

class YaadRakhApp extends StatelessWidget {
  const YaadRakhApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yaad Rakh',
      debugShowCheckedModeBanner: false,
      
      // Wire up easy_localization delegate hooks
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

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
      home: Consumer<OnboardingProvider>(
        builder: (context, onboarding, child) {
          if (!onboarding.onboarded) {
            return const LanguageSelectionScreen();
          }
          return const TaskListScreen();
        },
      ),
    );
  }
}
