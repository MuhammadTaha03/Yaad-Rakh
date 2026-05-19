// lib/onboarding/screens/name_input.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../onboarding_provider.dart';
import '../widgets/greeting_preview.dart';
import '../widgets/primary_button.dart';
import 'tutorial_page.dart';

class NameInputScreen extends StatefulWidget {
  const NameInputScreen({super.key});

  @override
  State<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<OnboardingProvider>(context, listen: false);
      _controller.text = provider.userName;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OnboardingProvider>(context);
    final theme = Theme.of(context);
    final isUrdu = provider.languageId == 'ur';

    // Localized typography elements
    String titleText = "Enter your name";
    String labelHint = "Your name";
    String continueLabel = "Continue";

    if (isUrdu) {
      titleText = "اپنا نام درج کریں";
      labelHint = "آپ کا نام";
      continueLabel = "جاری رکھیں";
    } else if (provider.languageId == 'roman_ur') {
      titleText = "Apna naam likhain";
      labelHint = "Aap ka naam";
      continueLabel = "Aage Barein";
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                titleText,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _controller,
                textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  labelText: labelHint,
                  labelStyle: TextStyle(
                    color: theme.colorScheme.primary.withOpacity(0.8),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                  ),
                ),
                onChanged: (val) {
                  provider.setName(val);
                },
              ),
              const SizedBox(height: 8),
              const GreetingPreview(),
              const Spacer(),
              PrimaryButton(
                label: continueLabel,
                icon: Icons.arrow_forward_rounded,
                onPressed: provider.userName.isEmpty
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TutorialPage(pageIndex: 0),
                          ),
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
