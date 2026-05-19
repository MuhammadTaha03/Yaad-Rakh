// lib/tasks/screens/task_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../task_provider.dart';
import '../widgets/task_tile.dart';
import '../widgets/empty_task_view.dart';
import 'add_task_screen.dart';
import '../../onboarding/onboarding_provider.dart';
import '../widgets/voice_input_sheet.dart';
import '../../notifications/screens/settings_screen.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    final onboarding = Provider.of<OnboardingProvider>(context);
    final theme = Theme.of(context);
    
    final isUrdu = onboarding.languageId == 'ur';
    String dashboardTitle = "Yaad Rakh";
    
    if (isUrdu) {
      dashboardTitle = "یاد رکھ";
    } else if (onboarding.languageId == 'roman_ur') {
      dashboardTitle = "Yaad Rakh";
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            dashboardTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: theme.colorScheme.primaryContainer,
          actions: [
            // Settings trigger button
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: "Settings",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(
                text: isUrdu
                    ? "باقی کام (${provider.pendingTasks.length})"
                    : onboarding.languageId == 'roman_ur'
                        ? "Baqi (${provider.pendingTasks.length})"
                        : "Pending (${provider.pendingTasks.length})",
              ),
              Tab(
                text: isUrdu
                    ? "مکمل کام (${provider.completedTasks.length})"
                    : onboarding.languageId == 'roman_ur'
                        ? "Mukammal (${provider.completedTasks.length})"
                        : "Completed (${provider.completedTasks.length})",
              ),
            ],
            indicatorColor: theme.colorScheme.primary,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: TabBarView(
          children: [
            // 1. Pending tasks list
            provider.pendingTasks.isEmpty
                ? const EmptyTaskView()
                : RefreshIndicator(
                    onRefresh: () => provider.syncFromFirestore("local_uid"),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: provider.pendingTasks.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
                      itemBuilder: (context, index) {
                        return TaskTile(task: provider.pendingTasks[index]);
                      },
                    ),
                  ),
                  
            // 2. Completed tasks list
            provider.completedTasks.isEmpty
                ? const EmptyTaskView()
                : RefreshIndicator(
                    onRefresh: () => provider.syncFromFirestore("local_uid"),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: provider.completedTasks.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
                      itemBuilder: (context, index) {
                        return TaskTile(task: provider.completedTasks[index]);
                      },
                    ),
                  ),
          ],
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: "voice_input_fab",
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  builder: (_) => const VoiceInputSheet(),
                );
              },
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: theme.colorScheme.onSecondary,
              tooltip: "Voice Input",
              child: const Icon(Icons.mic),
            ),
            const SizedBox(width: 16),
            FloatingActionButton.extended(
              heroTag: "primary_add_fab",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddTaskScreen(),
                  ),
                );
              },
              label: Text(
                isUrdu
                    ? "نیا کام"
                    : onboarding.languageId == 'roman_ur'
                        ? "Naya Kaam"
                        : "Add Task",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
