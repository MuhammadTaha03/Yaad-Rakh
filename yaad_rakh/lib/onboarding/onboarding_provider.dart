// lib/onboarding/onboarding_provider.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'auth_service.dart';

class OnboardingProvider extends ChangeNotifier {
  final Box _settingsBox = Hive.box('settings');

  String get languageId => _settingsBox.get('languageId', defaultValue: 'en') as String;

  Locale get locale => languageId == 'ur' ? const Locale('ur') : const Locale('en');

  String get userName => _settingsBox.get('userName', defaultValue: '') as String;

  bool get isSignedIn => _settingsBox.get('isSignedIn', defaultValue: false) as bool;

  bool get onboarded => _settingsBox.get('onboarded', defaultValue: false) as bool;

  String get themeMode => _settingsBox.get('themeMode', defaultValue: 'system') as String;

  ThemeMode get activeThemeMode {
    switch (themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(String mode) async {
    await _settingsBox.put('themeMode', mode);
    notifyListeners();
  }

  Future<void> setCustomLanguage(String id) async {
    await _settingsBox.put('languageId', id);
    notifyListeners();
  }

  Future<void> setName(String name) async {
    await _settingsBox.put('userName', name.trim());
    notifyListeners();
  }

  Future<bool> signInWithGoogle() async {
    try {
      final user = await AuthService.signInWithGoogle();
      if (user != null) {
        await _settingsBox.put('uid', user.uid);
        await _settingsBox.put('isSignedIn', true);
        if (user.displayName != null && userName.isEmpty) {
          await setName(user.displayName!);
        }
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("OnboardingProvider: Google Sign-In caught error: $e");
    }
    return false;
  }

  Future<void> completeOnboarding() async {
    await _settingsBox.put('onboarded', true);
    notifyListeners();
  }

  Future<void> resetOnboarding() async {
    await _settingsBox.put('onboarded', false);
    await _settingsBox.put('userName', '');
    await _settingsBox.put('isSignedIn', false);
    notifyListeners();
  }
}
