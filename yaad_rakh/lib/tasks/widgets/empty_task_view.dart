// lib/tasks/widgets/empty_task_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../onboarding/onboarding_provider.dart';

class EmptyTaskView extends StatelessWidget {
  const EmptyTaskView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OnboardingProvider>(context);
    final theme = Theme.of(context);
    final isUrdu = provider.languageId == 'ur';

    String msg = "No tasks yet! Add one using the button below.";
    if (isUrdu) {
      msg = "ابھی تک کوئی کام نہیں ہے! نیچے بٹن سے شروع کریں۔";
    } else if (provider.languageId == 'roman_ur') {
      msg = "Abhi koi kaam nahi hai! Niche wale button se add karein.";
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt_rounded,
            size: 80,
            color: theme.colorScheme.primary.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              msg,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
