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
    final isRoman = onboarding.languageId == 'roman_ur';

    // Localized Headers & String variables
    String titleText = "Settings";
    String remindersHeader = "TASK REMINDERS";
    String enableLabel = "Enable Reminders";
    String offsetLabel = "Default Reminder Interval";
    String summaryHeader = "MORNING SUMMARY";
    String enableSummaryLabel = "Enable Morning Summaries";
    String summaryTimeLabel = "Daily Summary Time";
    String langHeader = "APP LANGUAGE";
    
    // Module 8 Settings additions
    String profileHeader = "USER PROFILE";
    String profileNameLabel = "Profile Name";
    String themeHeader = "APP THEME";
    String systemThemeLabel = "System Default";
    String lightThemeLabel = "Light Mode";
    String darkThemeLabel = "Dark Mode";
    
    String actionsHeader = "ACTIONS";
    String clearCompletedLabel = "Clear Completed Tasks";
    String clearCompletedConfirm = "Are you sure you want to clear all completed tasks?";
    String clearCompletedBtn = "CLEAR";
    String cancelBtn = "CANCEL";
    
    String aboutHeader = "ABOUT & PRIVACY";
    String versionLabel = "Version 1.0.0";
    String privacyPolicyLabel = "Privacy Policy & Terms";
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
      
      profileHeader = "پروفائل";
      profileNameLabel = "پروفائل نام";
      themeHeader = "تھیم";
      systemThemeLabel = "سسٹم ڈیفالٹ";
      lightThemeLabel = "لائٹ موڈ";
      darkThemeLabel = "ڈارک موڈ";
      
      actionsHeader = "اقدامات";
      clearCompletedLabel = "مکمل کام صاف کریں";
      clearCompletedConfirm = "کیا آپ تمام مکمل شدہ کام صاف کرنا چاہتے ہیں؟";
      clearCompletedBtn = "صاف کریں";
      cancelBtn = "منسوخ کریں";
      
      aboutHeader = "ایپ کے بارے میں";
      versionLabel = "ورژن 1.0.0";
      privacyPolicyLabel = "پرائیویسی پالیسی اور شرائط";
      resetBtnLabel = "دوبارہ شروع کریں";
    } else if (isRoman) {
      titleText = "Settings";
      remindersHeader = "TASK REMINDERS";
      enableLabel = "Reminders active karein";
      offsetLabel = "Default Reminder Interval";
      summaryHeader = "MORNING SUMMARY";
      enableSummaryLabel = "Daily morning summaries";
      summaryTimeLabel = "Summary ka time";
      langHeader = "APP LANGUAGE";
      
      profileHeader = "USER PROFILE";
      profileNameLabel = "Profile Name";
      themeHeader = "APP THEME";
      systemThemeLabel = "System Default";
      lightThemeLabel = "Light Mode";
      darkThemeLabel = "Dark Mode";
      
      actionsHeader = "ACTIONS";
      clearCompletedLabel = "Completed Kaam Saaf Karein";
      clearCompletedConfirm = "Kya aap saare completed kaam saaf karna chahte hain?";
      clearCompletedBtn = "SAAF KAREIN";
      cancelBtn = "CANCEL";
      
      aboutHeader = "ABOUT & PRIVACY";
      versionLabel = "Version 1.0.0";
      privacyPolicyLabel = "Privacy Policy & Terms";
      resetBtnLabel = "Onboarding reset karein";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(titleText, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // --- Section 1: User Profile ---
          _buildHeader(theme, profileHeader),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              foregroundColor: theme.colorScheme.primary,
              child: const Icon(Icons.person),
            ),
            title: Text(profileNameLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            subtitle: Text(
              onboarding.userName.isNotEmpty ? onboarding.userName : "User",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.mode_edit_outline_outlined, size: 20),
            onTap: () {
              final controller = TextEditingController(text: onboarding.userName);
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(isUrdu ? "نام تبدیل کریں" : "Edit Profile Name"),
                  content: TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: isUrdu ? "اپنا نام لکھیں" : "Enter your name",
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(cancelBtn),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final val = controller.text.trim();
                        if (val.isNotEmpty) {
                          await onboarding.setName(val);
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      child: Text(isUrdu ? "محفوظ کریں" : "SAVE"),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const Divider(),

          // --- Section 2: App Theme ---
          _buildHeader(theme, themeHeader),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
              foregroundColor: theme.colorScheme.secondary,
              child: const Icon(Icons.palette),
            ),
            title: Text(
              onboarding.themeMode == 'system'
                  ? systemThemeLabel
                  : onboarding.themeMode == 'light'
                      ? lightThemeLabel
                      : darkThemeLabel,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            trailing: DropdownButton<String>(
              value: onboarding.themeMode,
              underline: const SizedBox(),
              borderRadius: BorderRadius.circular(12),
              items: [
                DropdownMenuItem(value: 'system', child: Text(systemThemeLabel)),
                DropdownMenuItem(value: 'light', child: Text(lightThemeLabel)),
                DropdownMenuItem(value: 'dark', child: Text(darkThemeLabel)),
              ],
              onChanged: (val) {
                if (val != null) {
                  onboarding.setThemeMode(val);
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),

          // --- Section 3: Task Reminders ---
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
          const SizedBox(height: 16),
          const Divider(),
          
          // --- Section 4: Morning Summary ---
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
          const SizedBox(height: 16),
          const Divider(),
          
          // --- Section 5: Language Selection ---
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
          const SizedBox(height: 24),
          const Divider(),

          // --- Section 6: Actions ---
          _buildHeader(theme, actionsHeader),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            title: Text(clearCompletedLabel, style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.w500)),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(clearCompletedLabel),
                  content: Text(clearCompletedConfirm),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(cancelBtn),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: theme.colorScheme.onError,
                      ),
                      onPressed: () async {
                        final completed = tasks.completedTasks;
                        for (final t in completed) {
                          await tasks.deleteTask(t.id);
                        }
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(isUrdu ? "مکمل کام صاف ہو گئے!" : "Completed tasks cleared!")),
                          );
                        }
                      },
                      child: Text(clearCompletedBtn),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const Divider(),

          // --- Section 7: About & Privacy ---
          _buildHeader(theme, aboutHeader),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("Yaad Rakh App", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(versionLabel),
            trailing: const Icon(Icons.info_outline, size: 20),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "Yaad Rakh",
                applicationVersion: "1.0.0",
                applicationLegalese: "© 2026 Yaad Rakh Devs. Designed for offline-first simplicity in Pakistan.",
                children: [
                  const SizedBox(height: 12),
                  const Text("An elegant digital scheduler tailored for localization support in Urdu script, English, and Roman Urdu. Includes automated task clustering and smart voice NLP transcription."),
                ],
              );
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(privacyPolicyLabel),
            trailing: const Icon(Icons.lock_outline, size: 20),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(privacyPolicyLabel),
                  content: const SingleChildScrollView(
                    child: Text(
                      "Privacy Policy:\n\n"
                      "1. Offline First: Yaad Rakh stores all tasks, categories, and settings locally on your device using Hive. No data leaves your device unless sync features are explicitly enabled.\n\n"
                      "2. Voice Recognition: Voice inputs are transcribed locally or through the platform standard transcription channels. Transcription streams are never monitored or distributed.\n\n"
                      "3. Security: All stored reminder alerts respect native sandboxing parameters.",
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("CLOSE"),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          
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
          const SizedBox(height: 24),
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
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.12),
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
