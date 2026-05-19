// lib/onboarding/screens/tutorial_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../onboarding_provider.dart';
import '../widgets/tutorial_icon_card.dart';
import 'account_option.dart';

class TutorialPage extends StatelessWidget {
  final int pageIndex;

  const TutorialPage({
    super.key,
    required this.pageIndex,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OnboardingProvider>(context);
    final theme = Theme.of(context);
    final isUrdu = provider.languageId == 'ur';

    // 1. Resolve content for current page index
    IconData pageIcon;
    String caption;

    switch (pageIndex) {
      case 0:
        pageIcon = Icons.checklist_rounded;
        caption = provider.languageId == 'ur'
            ? "فوری طور پر کام بنائیں۔"
            : provider.languageId == 'roman_ur'
                ? "Foran kaam add karein"
                : "Create tasks instantly";
        break;
      case 1:
        pageIcon = Icons.calendar_month_rounded;
        caption = provider.languageId == 'ur'
            ? "صرف ایک تھپتھپانے سے شیڈول کریں۔"
            : provider.languageId == 'roman_ur'
                ? "Ek tap mein schedule karein"
                : "Schedule tasks with a tap";
        break;
      case 2:
      default:
        pageIcon = Icons.check_circle_outline_rounded;
        caption = provider.languageId == 'ur'
            ? "کاموں کو مکمل کریں اور پیشرفت دیکھیں۔"
            : provider.languageId == 'roman_ur'
                ? "Kaam mukammal karein aur dekhein"
                : "Mark tasks done and track progress";
        break;
    }

    // Localized button text
    String nextLabel = pageIndex == 2 ? "Get Started" : "Next";
    String prevLabel = "Previous";

    if (isUrdu) {
      nextLabel = pageIndex == 2 ? "شروع کریں" : "اگلا";
      prevLabel = "پچھلا";
    } else if (provider.languageId == 'roman_ur') {
      nextLabel = pageIndex == 2 ? "Shuru Karein" : "Agla";
      prevLabel = "Pichla";
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              // Top progress indicator indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: index == pageIndex ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == pageIndex
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const Spacer(),
              TutorialIconCard(
                icon: pageIcon,
                caption: caption,
              ),
              const Spacer(),
              // Navigation buttons row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous button
                  TextButton(
                    onPressed: pageIndex == 0
                        ? null
                        : () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                    child: Text(
                      prevLabel,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  // Next / Get Started button
                  ElevatedButton(
                    onPressed: () {
                      if (pageIndex < 2) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TutorialPage(pageIndex: pageIndex + 1),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AccountOptionScreen(),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          nextLabel,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        if (pageIndex < 2) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 18),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
