// lib/onboarding/screens/language_selection.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import '../onboarding_provider.dart';
import '../widgets/language_tile.dart';
import '../widgets/primary_button.dart';
import 'name_input.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _selectedLang = 'en';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<OnboardingProvider>(context, listen: false);
      setState(() {
        _selectedLang = provider.languageId;
      });
    });
  }

  void _onLanguageSelected(String langId, OnboardingProvider provider) async {
    setState(() {
      _selectedLang = langId;
    });
    await provider.setCustomLanguage(langId);
    if (!mounted) return;
    
    // Dynamically shift easy_localization context locale if English or Urdu
    if (langId == 'ur') {
      el.EasyLocalization.of(context)?.setLocale(const Locale('ur'));
    } else {
      el.EasyLocalization.of(context)?.setLocale(const Locale('en'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OnboardingProvider>(context);
    final theme = Theme.of(context);

    // Dynamic localized header
    String titleText = "Select your language";
    String continueLabel = "Continue";
    
    if (_selectedLang == 'ur') {
      titleText = "اپنی زبان منتخب کریں";
      continueLabel = "جاری رکھیں";
    } else if (_selectedLang == 'roman_ur') {
      titleText = "Apni zaban chunain";
      continueLabel = "Aage Barein";
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                titleText,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _selectedLang == 'ur'
                    ? "یہ تبدیلیاں بعد میں ترتیبات میں کی جا سکتی ہیں۔"
                    : _selectedLang == 'roman_ur'
                        ? "Yeh settings baad mein bhi change ho sakti hain."
                        : "You can change this later in settings.",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 48),
              Expanded(
                child: ListView(
                  children: [
                    LanguageTile(
                      title: "اردو",
                      subtitle: "Urdu script language profile",
                      flag: "🇵🇰",
                      isSelected: _selectedLang == 'ur',
                      onTap: () => _onLanguageSelected('ur', provider),
                    ),
                    LanguageTile(
                      title: "Roman Urdu",
                      subtitle: "Roman Urdu script profile",
                      flag: "💬",
                      isSelected: _selectedLang == 'roman_ur',
                      onTap: () => _onLanguageSelected('roman_ur', provider),
                    ),
                    LanguageTile(
                      title: "English",
                      subtitle: "Standard English profile",
                      flag: "🇬🇧",
                      isSelected: _selectedLang == 'en',
                      onTap: () => _onLanguageSelected('en', provider),
                    ),
                  ],
                ),
              ),
              PrimaryButton(
                label: continueLabel,
                icon: Icons.arrow_forward_rounded,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NameInputScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
