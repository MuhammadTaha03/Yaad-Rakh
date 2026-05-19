// lib/tasks/screens/task_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../task_provider.dart';
import '../widgets/task_tile.dart';
import '../widgets/empty_task_view.dart';
import 'add_task_screen.dart';
import '../../onboarding/onboarding_provider.dart';
import 'calendar_screen_tab.dart';
import '../widgets/voice_input_sheet.dart';
import '../../notifications/screens/settings_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  // Category filter state ('all' means show all categories)
  String _selectedFilterCategoryId = 'all';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    final onboarding = Provider.of<OnboardingProvider>(context);
    final theme = Theme.of(context);
    
    final isUrdu = onboarding.languageId == 'ur';
    final isRoman = onboarding.languageId == 'roman_ur';
    
    String dashboardTitle = "Yaad Rakh";
    if (isUrdu) {
      dashboardTitle = "یاد رکھ";
    }

    // 1. Personalized Greeting lookup
    String greeting = "Hello";
    if (isUrdu) {
      greeting = "السلام علیکم";
    } else if (isRoman) {
      greeting = "Salaam";
    }
    
    final userName = onboarding.userName.isNotEmpty ? onboarding.userName : "User";
    final fullGreeting = isUrdu ? "$greeting، $userName!" : "$greeting $userName!";

    // 2. Localized task count summaries
    final completedCount = provider.completedTasks.length;
    final remainingCount = provider.pendingTasks.length;
    
    String progressSubtitle = "$completedCount completed, $remainingCount remaining";
    if (isUrdu) {
      progressSubtitle = "$completedCount مکمل، $remainingCount باقی";
    } else if (isRoman) {
      progressSubtitle = "$completedCount mukammal, $remainingCount baqi";
    }

    // 3. Section Headers
    String overdueHeader = "Overdue Tasks";
    String todayHeader = "Today's Tasks";
    String upcomingHeader = "Upcoming Tasks";
    
    if (isUrdu) {
      overdueHeader = "وقت سے اوپر کام";
      todayHeader = "آج کے کام";
      upcomingHeader = "آنے والے کام";
    } else if (isRoman) {
      overdueHeader = "Overdue Kaam";
      todayHeader = "Aaj Ke Kaam";
      upcomingHeader = "Aane Wale Kaam";
    }

    // 4. Filter task lists dynamically
    final String selFilter = _selectedFilterCategoryId;
    
    final filteredOverdue = selFilter == 'all'
        ? provider.overdueTasks
        : provider.overdueTasks.where((t) => (t.customCategoryId ?? t.category.name) == selFilter).toList();
        
    final filteredToday = selFilter == 'all'
        ? provider.todayTasks
        : provider.todayTasks.where((t) => (t.customCategoryId ?? t.category.name) == selFilter).toList();
        
    final filteredUpcoming = selFilter == 'all'
        ? provider.upcomingTasks
        : provider.upcomingTasks.where((t) => (t.customCategoryId ?? t.category.name) == selFilter).toList();
        
    final filteredCompleted = selFilter == 'all'
        ? provider.completedTasks
        : provider.completedTasks.where((t) => (t.customCategoryId ?? t.category.name) == selFilter).toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            dashboardTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: theme.colorScheme.primaryContainer,
          actions: [
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
                    ? "ڈیش بورڈ"
                    : isRoman
                        ? "Dashboard"
                        : "Dashboard",
              ),
              Tab(
                text: isUrdu
                    ? "کیلنڈر"
                    : isRoman
                        ? "Calendar"
                        : "Calendar",
              ),
              Tab(
                text: isUrdu
                    ? "مکمل کام ($completedCount)"
                    : isRoman
                        ? "Mukammal ($completedCount)"
                        : "Completed ($completedCount)",
              ),
            ],
            indicatorColor: theme.colorScheme.primary,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: TabBarView(
          children: [
            // --- TAB 1: Home Dashboard ---
            RefreshIndicator(
              onRefresh: () => provider.syncFromFirestore("local_uid"),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // A. Premium Glassmorphic Gradient Header Card
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primaryContainer,
                            theme.colorScheme.secondaryContainer.withValues(alpha: 0.4),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullGreeting,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            progressSubtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Simple progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: (completedCount + remainingCount) == 0
                                  ? 0
                                  : completedCount / (completedCount + remainingCount),
                              backgroundColor: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.12),
                              color: theme.colorScheme.primary,
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // B. Horizontal Scrolling Category Filter Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: SizedBox(
                        height: 48,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: provider.customCategories.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              // "All" filter chip
                              final isSelected = _selectedFilterCategoryId == 'all';
                              return Container(
                                margin: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(
                                    isUrdu ? "سب" : isRoman ? "Sab" : "All",
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  selected: isSelected,
                                  selectedColor: theme.colorScheme.primary,
                                  checkmarkColor: Colors.white,
                                  backgroundColor: theme.colorScheme.surface,
                                  side: BorderSide(
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurface.withValues(alpha: 0.12),
                                  ),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  onSelected: (val) {
                                    if (val) {
                                      setState(() {
                                        _selectedFilterCategoryId = 'all';
                                      });
                                    }
                                  },
                                ),
                              );
                            }
                            
                            final cat = provider.customCategories[index - 1];
                            final isSelected = _selectedFilterCategoryId == cat.id;
                            final color = Color(cat.colorHex);

                            String displayName = cat.nameEnglish;
                            if (isUrdu) {
                              displayName = cat.nameUrdu;
                            } else if (isRoman) {
                              displayName = cat.nameRomanUrdu;
                            }

                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(
                                  displayName,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: color,
                                checkmarkColor: Colors.white,
                                backgroundColor: theme.colorScheme.surface,
                                side: BorderSide(
                                  color: isSelected ? color : theme.colorScheme.onSurface.withValues(alpha: 0.12),
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                onSelected: (val) {
                                  if (val) {
                                    setState(() {
                                      _selectedFilterCategoryId = cat.id;
                                    });
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // If zero tasks exist in current filtered state, render clean placeholder
                    if (provider.pendingTasks.isEmpty) ...[
                      const SizedBox(height: 32),
                      const EmptyTaskView(),
                    ] else ...[
                      // Section 1: Overdue Tasks (High Impact Red)
                      if (filteredOverdue.isNotEmpty) ...[
                        _buildSectionHeader(context, overdueHeader, true),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredOverdue.length,
                          separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
                          itemBuilder: (context, index) {
                            final task = filteredOverdue[index];
                            return Theme(
                              data: theme.copyWith(
                                colorScheme: theme.colorScheme.copyWith(
                                  onSurface: theme.colorScheme.error,
                                ),
                              ),
                              child: TaskTile(task: task),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Section 2: Today's Tasks
                      if (filteredToday.isNotEmpty) ...[
                        _buildSectionHeader(context, todayHeader, false),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredToday.length,
                          separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
                          itemBuilder: (context, index) {
                            return TaskTile(task: filteredToday[index]);
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Section 3: Upcoming / Someday Tasks
                      if (filteredUpcoming.isNotEmpty) ...[
                        _buildSectionHeader(context, upcomingHeader, false),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredUpcoming.length,
                          separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
                          itemBuilder: (context, index) {
                            return TaskTile(task: filteredUpcoming[index]);
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Filter fallback if all segments are empty but total items exist
                      if (filteredOverdue.isEmpty && filteredToday.isEmpty && filteredUpcoming.isEmpty) ...[
                        const SizedBox(height: 48),
                        Center(
                          child: Text(
                            isUrdu ? "اس کیٹیگری میں کوئی کام نہیں ہے۔" : "No tasks in this category.",
                            style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
                  
            // --- TAB 2: Calendar View ---
            const CalendarScreenTab(),
                  
            // --- TAB 3: Completed History ---
            filteredCompleted.isEmpty
                ? const EmptyTaskView()
                : RefreshIndicator(
                    onRefresh: () => provider.syncFromFirestore("local_uid"),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: filteredCompleted.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
                      itemBuilder: (context, index) {
                        return TaskTile(task: filteredCompleted[index]);
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
                    : isRoman
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

  Widget _buildSectionHeader(BuildContext context, String text, bool isError) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (isError) ...[
            Icon(Icons.warning_rounded, size: 16, color: theme.colorScheme.error),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: isError ? theme.colorScheme.error : theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
