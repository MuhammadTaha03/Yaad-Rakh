// lib/onboarding/screens/account_option.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../onboarding_provider.dart';
import '../widgets/primary_button.dart';

class AccountOptionScreen extends StatefulWidget {
  const AccountOptionScreen({super.key});

  @override
  State<AccountOptionScreen> createState() => _AccountOptionScreenState();
}

class _AccountOptionScreenState extends State<AccountOptionScreen> {
  bool _isLoading = false;

  void _handleGoogleSignIn(OnboardingProvider provider) async {
    setState(() {
      _isLoading = true;
    });

    final success = await provider.signInWithGoogle();
    
    setState(() {
      _isLoading = false;
    });

    if (success) {
      await provider.completeOnboarding();
      if (mounted) {
        // Pop all previous onboarding screens and land on the main screen
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Authentication failed. Please try again or Skip."),
          ),
        );
      }
    }
  }

  void _handleSkip(OnboardingProvider provider) async {
    await provider.completeOnboarding();
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OnboardingProvider>(context);
    final theme = Theme.of(context);
    final isUrdu = provider.languageId == 'ur';

    // Localized strings
    String headingText = "Sync & Save Your Tasks";
    String descText = "Sign in to keep your tasks synced silently in the background and safe if you switch devices.";
    String googleBtnLabel = "Sign in with Google";
    String skipBtnLabel = "Skip for now";

    if (isUrdu) {
      headingText = "اپنے کاموں کو محفوظ کریں";
      descText = "اپنے کاموں کو بیک گراؤنڈ میں محفوظ رکھنے کے لیے سائن ان کریں۔ اگر آپ موبائل تبدیل کریں گے تو بھی آپ کا ڈیٹا محفوظ رہے گا۔";
      googleBtnLabel = "گوگل کے ساتھ لاگ ان کریں";
      skipBtnLabel = "ابھی چھوڑیں";
    } else if (provider.languageId == 'roman_ur') {
      headingText = "Tasks ko save aur sync karein";
      descText = "Google se login karein takay aap ke tasks backup ho sakain aur mobile badalne par bhi mehfooz rahain.";
      googleBtnLabel = "Google se Login Karein";
      skipBtnLabel = "Abhi Chhoren";
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              const Spacer(),
              Icon(
                Icons.cloud_sync_rounded,
                size: 96,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 32),
              Text(
                headingText,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  descText,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    height: 1.5,
                  ),
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: googleBtnLabel,
                isLoading: _isLoading,
                icon: Icons.login_rounded,
                onPressed: () => _handleGoogleSignIn(provider),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isLoading ? null : () => _handleSkip(provider),
                style: TextButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: theme.colorScheme.onSurface.withOpacity(0.12),
                    ),
                  ),
                ),
                child: Text(
                  skipBtnLabel,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
