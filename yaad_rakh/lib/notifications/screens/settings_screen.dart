// lib/notifications/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import '../notification_provider.dart';
import '../../onboarding/onboarding_provider.dart';
import '../../tasks/task_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notification = Provider.of<NotificationProvider>(context);
    final onboarding = Provider.of<OnboardingProvider>(context);
    final tasks = Provider.of<TaskProvider>(context);
    final theme = Theme.of(context);
    
    final isUrdu = onboarding.languageId == 'ur';

    // Localized headers
    String titleText = "Settings";
    String remindersHeader = "TASK REMINDERS";
    String enableLabel = "Enable Reminders";
    String offsetLabel = "Default Reminder Interval";
    String summaryHeader = "MORNING SUMMARY";
    String enableSummaryLabel = "Enable Morning Summaries";
    String summaryTimeLabel = "Daily Summary Time";
    String langHeader = "APP LANGUAGE";
    String resetBtnLabel = "Reset Onboarding";

    if (isUrdu) {
      titleText = "ترتیبات";
      remindersHeader = "یاد دہانیاں";
      enableLabel = "یاد دہانیاں فعال کریں";
      offsetLabel = "پہلے سے طے شدہ وقت";
      summaryHeader = "صبح کا خلاصہ";
      enableSummaryLabel = "روزانہ صبح کا خلاصہ";
      summaryTimeLabel = "خلاصہ کا وقت";
      langHeader = "ایپ کی زبان";
      resetBtnLabel = "دوبارہ شروع کریں";
    } else if (onboarding.languageId == 'roman_ur') {
      titleText = "Settings";
      remindersHeader = "TASK REMINDERS";
      enableLabel = "Reminders active karein";
      offsetLabel = "Default Reminder Interval";
      summaryHeader = "MORNING SUMMARY";
      enableSummaryLabel = "Daily morning summaries";
      summaryTimeLabel = "Summary ka time";
      langHeader = "APP LANGUAGE";
      resetBtnLabel = "Onboarding reset karein";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(titleText, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // --- Category 1: Reminders ---
          _buildHeader(theme, remindersHeader),
          
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(enableLabel, style: const TextStyle(fontWeight: FontWeight.w500)),
            value: notification.isNotificationEnabled,
            onChanged: (val) {
              notification.setNotificationEnabled(val, tasks.pendingTasks, onboarding.languageId);
            },
          ),
          
          if (notification.isNotificationEnabled) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(offsetLabel),
              trailing: DropdownButton<int>(
                value: notification.defaultOffsetMinutes,
                underline: const SizedBox(),
                borderRadius: BorderRadius.circular(12),
                items: const [
                  DropdownMenuItem(value: 0, child: Text("On Time")),
                  DropdownMenuItem(value: 5, child: Text("5 Minutes Before")),
                  DropdownMenuItem(value: 15, child: Text("15 Minutes Before")),
                  DropdownMenuItem(value: 30, child: Text("30 Minutes Before")),
                  DropdownMenuItem(value: 60, child: Text("1 Hour Before")),
                ],
                onChanged: (val) {
                  if (val != null) {
                    notification.setDefaultOffset(val);
                  }
                },
              ),
            ),
          ],
          const SizedBox(height: 24),
          const Divider(),
          
          // --- Category 2: Morning Summary ---
          _buildHeader(theme, summaryHeader),
          
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(enableSummaryLabel, style: const TextStyle(fontWeight: FontWeight.w500)),
            value: notification.isMorningSummaryEnabled,
            onChanged: (val) {
              notification.setMorningSummaryEnabled(val, tasks.pendingTasks, onboarding.languageId);
            },
          ),
          
          if (notification.isMorningSummaryEnabled) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(summaryTimeLabel),
              trailing: TextButton(
                onPressed: () async {
                  final parts = notification.morningSummaryTime.split(':');
                  final TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: int.parse(parts[0]),
                      minute: int.parse(parts[1]),
                    ),
                  );
                  if (time != null && context.mounted) {
                    final formatted = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                    await notification.setMorningSummaryTime(formatted, tasks.pendingTasks, onboarding.languageId);
                  }
                },
                child: Text(
                  notification.morningSummaryTime,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          const Divider(),
          
          // --- Category 3: Language ---
          _buildHeader(theme, langHeader),
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLangBtn(context, "English", "en", onboarding, notification, tasks),
              _buildLangBtn(context, "Roman", "roman_ur", onboarding, notification, tasks),
              _buildLangBtn(context, "اردو", "ur", onboarding, notification, tasks),
            ],
          ),
          
          const SizedBox(height: 48),
          const Divider(),
          const SizedBox(height: 24),
          
          // --- Action: Reset Onboarding ---
          ElevatedButton.icon(
            onPressed: () async {
              await onboarding.resetOnboarding();
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.errorContainer,
              foregroundColor: theme.colorScheme.onErrorContainer,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: Text(
              resetBtnLabel,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildLangBtn(
    BuildContext context,
    String name,
    String langId,
    OnboardingProvider onboarding,
    NotificationProvider notification,
    TaskProvider tasks,
  ) {
    final theme = Theme.of(context);
    final isSelected = onboarding.languageId == langId;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: OutlinedButton(
          onPressed: () async {
            await onboarding.setCustomLanguage(langId);
            
            // Adjust locales
            if (context.mounted) {
              if (langId == 'ur') {
                el.EasyLocalization.of(context)?.setLocale(const Locale('ur'));
              } else {
                el.EasyLocalization.of(context)?.setLocale(const Locale('en'));
              }
            }

            // Sync all native scheduled alarms to reflect the language shift
            await notification.rescheduleAllReminders(tasks.pendingTasks, langId);
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: isSelected ? theme.colorScheme.primary : Colors.transparent,
            foregroundColor: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
            side: BorderSide(
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.12),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
