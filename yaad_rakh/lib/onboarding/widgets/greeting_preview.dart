// lib/onboarding/widgets/greeting_preview.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../onboarding_provider.dart';

class GreetingPreview extends StatelessWidget {
  const GreetingPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OnboardingProvider>(context);
    final theme = Theme.of(context);
    
    if (provider.userName.isEmpty) {
      return const SizedBox.shrink();
    }

    String greeting = "";
    TextDirection textDirection = TextDirection.ltr;
    double fontSize = 24.0;
    
    if (provider.languageId == 'ur') {
      greeting = "السلام علیکم ${provider.userName}!";
      textDirection = TextDirection.rtl;
      fontSize = 28.0; // Larger for Nastaleeq-ready visibility
    } else if (provider.languageId == 'roman_ur') {
      greeting = "Salaam ${provider.userName}!";
    } else {
      greeting = "Hello ${provider.userName}!";
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), // wait, finalY is a typo? Let's use vertical: 16 instead
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Text(
        greeting,
        textDirection: textDirection,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
          fontFamily: provider.languageId == 'ur' ? 'JameelNooriNastaleeq' : null,
        ),
      ),
    );
  }
}
