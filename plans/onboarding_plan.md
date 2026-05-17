# Module 1 – Onboarding Implementation Plan for **Yaad Rakh**

> **Version:** 6.0 (Final)
> **Status:** Ready for implementation
> **Developer:** Solo
> **Stack:** Flutter + Firebase + Hive

---

## 1. Overview

The onboarding flow introduces the app, lets the user pick a language, collects their name, shows a concise three-screen icon-driven tutorial, and optionally offers account creation — all before landing on the home screen. A flag stored in Hive ensures this flow runs exactly once. The experience must be ultra-simple, fast, offline-capable, and fully localized in Urdu, Roman Urdu, and English.

**Final navigation order:**
```
LanguageSelection → NameInput → Tutorial1 → Tutorial2 → Tutorial3 → AccountOption → Home
```

---

## 2. Screen-by-Screen UI Breakdown

| Screen | Purpose | Layout & Key Widgets |
|--------|---------|----------------------|
| **LanguageSelectionScreen** | First screen — choose app language | Transparent `AppBar` (no back button), centered `Column` with three large `LanguageTile` cards (Urdu / Roman Urdu / English). Tapping a tile calls `provider.setCustomLanguage('ur' / 'roman_ur' / 'en')` and persists to Hive. |
| **NameInputScreen** | Personalize the experience | `AppBar` (no back), localized `Text` prompt, `TextField` with `textDirection: TextDirection.rtl` for Urdu, live `GreetingPreview` widget below field, `PrimaryButton` **Continue** disabled until field is non-empty. |
| **TutorialScreen-1** | Feature highlight: Tasks | Full-screen, `TutorialIconCard` with `Icons.checklist` icon, caption "Create tasks instantly" (localized), bottom row: **Previous** (disabled) + **Next**. |
| **TutorialScreen-2** | Feature highlight: Calendar | Same layout, `Icons.calendar_month` icon, caption "Schedule tasks with a tap". |
| **TutorialScreen-3** | Feature highlight: Progress | Same layout, `Icons.check_circle_outline` icon, caption "Mark tasks done and track progress", **Next** button replaced with **Get Started**. |
| **AccountOptionScreen** | Optional sign-in — placed after tutorial | `AppBar` (no back), two `OutlinedButton`s: **Sign in with Google** (shows `CircularProgressIndicator` while loading) and **Skip for now**. Success → store `uid` in Hive → `completeOnboarding()`. Skip → `completeOnboarding()` directly. |
| **HomeScreen** | Main app | Launched after onboarding completes. Not part of this module. |

---

## 3. Flutter Folder Structure (this module only)

```text
lib/
├── main.dart
└── onboarding/
    ├── onboarding_provider.dart      // ChangeNotifier — state + Hive logic
    ├── screens/
    │   ├── language_selection.dart
    │   ├── name_input.dart
    │   ├── tutorial_page.dart        // Reusable — accepts page index
    │   └── account_option.dart
    ├── widgets/
    │   ├── language_tile.dart
    │   ├── tutorial_icon_card.dart
    │   ├── primary_button.dart
    │   └── greeting_preview.dart
    └── models/
        └── onboarding_state.dart     // Simple data class (optional)
```

---

## 4. Widgets & Their Purpose

| Widget | Purpose |
|--------|---------|
| `LanguageTile` | Large tappable card — language name + flag emoji. Calls `provider.setCustomLanguage(id)` on tap. |
| `PrimaryButton` | Shared styled button for Continue / Next / Get Started. Accepts optional `isLoading` bool to show spinner. |
| `TutorialIconCard` | Centered icon + short localized caption. Accepts `IconData` and `String`. Reused on all three tutorial pages. |
| `GreetingPreview` | Reads `provider.userName` and `provider.languageId` and shows live greeting ("Salaam Ahmed!" / "السلام علیکم احمد!"). Rebuilds on every keystroke. |
| `OnboardingProvider` | Holds `languageId`, `userName`, `isSignedIn`, `onboarded`. Persists to Hive. Notifies UI on change. |
| `AuthService` | Static class wrapping Firebase Google Sign-In. Returns `User?`. Throws typed exceptions. |
| `HiveBoxHelper` | Static helper with safe `get` / `put` wrappers in `try/catch`. |

---

## 5. State Management — OnboardingProvider

```dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'auth_service.dart'; // defined in Section 10

class OnboardingProvider extends ChangeNotifier {
  // 'en', 'ur', or 'roman_ur'
  String _languageId = 'en';
  String get languageId => _languageId;

  // Returns Flutter Locale — Roman Urdu falls back to 'en' locale
  // but the UI reads strings from the custom JSON map directly.
  Locale get locale =>
      _languageId == 'ur' ? const Locale('ur') : const Locale('en');

  String _userName = '';
  String get userName => _userName;

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  bool _onboarded = false;
  bool get onboarded => _onboarded;

  Future<void> setCustomLanguage(String id) async {
    _languageId = id;
    await Hive.box('settings').put('languageId', id);
    notifyListeners();
  }

  Future<void> setName(String name) async {
    _userName = name.trim();
    await Hive.box('settings').put('userName', _userName);
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    final user = await AuthService.signInWithGoogle(); // throws on failure
    if (user != null) {
      _isSignedIn = true;
      await Hive.box('user').put('uid', user.uid);
      notifyListeners();
    }
  }

  Future<void> completeOnboarding() async {
    _onboarded = true;
    await Hive.box('settings').put('onboarded', true);
    notifyListeners();
  }
}
```

---

## 6. Localization Strategy

### Why three separate approaches?

| Language | Approach | Reason |
|----------|----------|--------|
| English | `easy_localization` ARB | Standard Flutter localization |
| Urdu | `easy_localization` ARB | Official `ur` locale code exists |
| Roman Urdu | Custom JSON + `InheritedWidget` | No official locale code exists — cannot use ARB |

### File structure

```
assets/
├── lang/
│   ├── en.arb
│   ├── ur.arb
│   └── roman_ur.json       ← plain JSON, loaded manually
├── fonts/
│   └── JameelNooriNastaleeq.ttf
└── images/
    └── splash_logo.png
```

### Sample `en.arb` (same keys in `ur.arb` and `roman_ur.json`)

```json
{
  "appName": "Yaad Rakh",
  "selectLanguage": "Select your language",
  "enterName": "Enter your name",
  "continueBtn": "Continue",
  "nextBtn": "Next",
  "previousBtn": "Previous",
  "getStarted": "Get Started",
  "signInGoogle": "Sign in with Google",
  "skipForNow": "Skip for now",
  "tutorial1Caption": "Create tasks instantly",
  "tutorial2Caption": "Schedule tasks with a tap",
  "tutorial3Caption": "Mark tasks done and track progress",
  "greetingEn": "Hello",
  "greetingUr": "السلام علیکم"
}
```

### Sample `roman_ur.json`

```json
{
  "appName": "Yaad Rakh",
  "selectLanguage": "Apni zaban chunain",
  "enterName": "Apna naam likhain",
  "continueBtn": "Aage Barein",
  "nextBtn": "Agla",
  "previousBtn": "Pichla",
  "getStarted": "Shuru Karein",
  "signInGoogle": "Google se Login Karein",
  "skipForNow": "Abhi Chhoren",
  "tutorial1Caption": "Foran kaam add karein",
  "tutorial2Caption": "Ek tap mein schedule karein",
  "tutorial3Caption": "Kaam mukammal karein aur dekhein"
}
```

### Custom Roman Urdu delegate

```dart
// lib/core/localization/roman_urdu_delegate.dart

import 'package:flutter/material.dart';

/// Holds the loaded Roman Urdu string map and exposes a lookup method.
class RomanUrduStrings {
  final Map<String, String> _strings;
  RomanUrduStrings(this._strings);

  String get(String key) => _strings[key] ?? key;

  static RomanUrduStrings of(BuildContext context) {
    return InheritedRomanUrdu.of(context).strings;
  }
}

/// InheritedWidget that makes RomanUrduStrings available down the tree.
class InheritedRomanUrdu extends InheritedWidget {
  final RomanUrduStrings strings;

  const InheritedRomanUrdu({
    Key? key,
    required this.strings,
    required Widget child,
  }) : super(key: key, child: child);

  static InheritedRomanUrdu of(BuildContext context) {
    final result =
        context.dependOnInheritedWidgetOfExactType<InheritedRomanUrdu>();
    assert(result != null, 'No InheritedRomanUrdu found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(InheritedRomanUrdu old) =>
      strings != old.strings;
}
```

---

## 7. main.dart — Full Bootstrap

```dart
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'onboarding/onboarding_provider.dart';
import 'core/localization/roman_urdu_delegate.dart';
import 'home/home_screen.dart';
import 'onboarding/screens/language_selection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Hive
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('user');

  // 2. Firebase (catch failure gracefully)
  bool firebaseReady = false;
  try {
    await Firebase.initializeApp();
    firebaseReady = true;
  } catch (_) {
    // Firebase unavailable — app still works offline
  }

  // 3. Load Roman Urdu JSON ONCE here — not inside build()
  final rawJson = await rootBundle.loadString('assets/lang/roman_ur.json');
  final Map<String, String> romanMap =
      Map<String, String>.from(jsonDecode(rawJson));

  // 4. Read saved language
  final savedId =
      Hive.box('settings').get('languageId', defaultValue: 'en') as String;

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ur')],
      path: 'assets/lang',
      fallbackLocale: const Locale('en'),
      startLocale: savedId == 'ur' ? const Locale('ur') : const Locale('en'),
      child: ChangeNotifierProvider(
        create: (_) => OnboardingProvider(),
        child: MyApp(
          romanMap: romanMap,
          firebaseReady: firebaseReady,
        ),
      ),
    ),
  );
}
```

---

## 8. MyApp Widget

```dart
class MyApp extends StatelessWidget {
  final Map<String, String> romanMap;
  final bool firebaseReady;

  const MyApp({
    Key? key,
    required this.romanMap,
    required this.firebaseReady,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();
    final isUrdu = provider.languageId == 'ur';
    final isRomanUrdu = provider.languageId == 'roman_ur';
    final isOnboarded =
        Hive.box('settings').get('onboarded', defaultValue: false) as bool;

    final app = MaterialApp(
      title: 'Yaad Rakh',
      locale: isUrdu ? const Locale('ur') : const Locale('en'),
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      theme: ThemeData(
        fontFamily: isUrdu ? 'JameelNooriNastaleeq' : null,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3B82F6)),
        useMaterial3: true,
      ),
      home: !firebaseReady
          ? const FirebaseErrorScreen() // shows retry button
          : isOnboarded
              ? const HomeScreen()
              : const LanguageSelectionScreen(),
    );

    // Wrap with Roman Urdu InheritedWidget only when needed
    if (isRomanUrdu) {
      return InheritedRomanUrdu(
        strings: RomanUrduStrings(romanMap),
        child: app,
      );
    }
    return app;
  }
}
```

---

## 9. How Screens Read Strings

```dart
// Inside any onboarding screen widget:

String _t(BuildContext context, String key) {
  final provider = context.read<OnboardingProvider>();
  if (provider.languageId == 'roman_ur') {
    return RomanUrduStrings.of(context).get(key);
  }
  return key.tr(); // easy_localization for 'en' and 'ur'
}

// Usage:
Text(_t(context, 'tutorial1Caption'))
```

This single helper works for all three languages with no duplication.

---

## 10. AuthService

```dart
// lib/onboarding/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static Future<User?> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null; // user cancelled

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    return userCredential.user;
  }
}
```

**AccountOptionScreen error handling:**

```dart
Future<void> _handleSignIn(BuildContext context) async {
  setState(() => _isLoading = true);
  try {
    await context.read<OnboardingProvider>().signInWithGoogle();
    await context.read<OnboardingProvider>().completeOnboarding();
    if (mounted) Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const HomeScreen()));
  } on FirebaseAuthException catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Sign in failed')),
      );
    }
  } catch (_) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong. Please try again.')),
      );
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}
```

---

## 11. Packages

### `pubspec.yaml` — dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # State
  provider: ^6.1.2

  # Local storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # Firebase
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  google_sign_in: ^6.2.0

  # Localization
  easy_localization: ^3.0.7
  intl: ^0.19.0

  # UI
  google_fonts: ^6.1.0

  # Network detection
  connectivity_plus: ^5.0.2

  # Splash screen
  flutter_native_splash: ^2.3.10
```

### `pubspec.yaml` — dev_dependencies

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  hive_generator: ^2.0.1
  build_runner: ^2.4.9
  flutter_lints: ^4.0.0
```

### `pubspec.yaml` — assets & fonts

```yaml
flutter:
  assets:
    - assets/lang/en.arb
    - assets/lang/ur.arb
    - assets/lang/roman_ur.json
    - assets/images/splash_logo.png

  fonts:
    - family: JameelNooriNastaleeq
      fonts:
        - asset: assets/fonts/JameelNooriNastaleeq.ttf
```

---

## 12. Splash Screen Setup

Add to `pubspec.yaml`:

```yaml
flutter_native_splash:
  color: "#ffffff"
  image: assets/images/splash_logo.png
  android: true
  ios: true
  android_12:
    color: "#ffffff"
    image: assets/images/splash_logo.png
```

Then run:

```bash
dart run flutter_native_splash:create
```

---

## 13. Firebase Setup Steps

1. Go to [console.firebase.google.com](https://console.firebase.google.com)
2. Create project → Add Android app (package name must match `android/app/build.gradle`)
3. Download `google-services.json` → place in `android/app/`
4. Add iOS app → download `GoogleService-Info.plist` → place in `ios/Runner/`
5. Enable **Google Sign-In** in Firebase Console → Authentication → Sign-in methods
6. Add SHA-1 fingerprint of your debug keystore to Firebase Android app settings

---

## 14. Edge Cases & Handling

| Edge Case | Mitigation |
|-----------|------------|
| Android back button during onboarding | Wrap every onboarding screen with `PopScope(canPop: false, onPopInvoked: (_) {})` |
| Google Sign-In cancelled by user | `googleUser` returns `null` — `AuthService` returns `null` — no error shown, stays on screen |
| `FirebaseAuthException` | Caught in `_handleSignIn`, shown as `SnackBar` in user's language |
| No internet during sign-in | Check with `connectivity_plus` before attempting — show inline offline banner — Skip always available |
| Firebase init failure | `firebaseReady = false` in `main()` — `MyApp` shows `FirebaseErrorScreen` with Retry button |
| Hive box fails to open | `try/catch` in `main()` — fallback to in-memory map — alert user to reinstall |
| Roman Urdu JSON missing from assets | `rootBundle.loadString` throws — catch in `main()`, fallback to English |
| Urdu font not rendering | `JameelNooriNastaleeq` in assets — fallback: `google_fonts` Noto Nastaliq Urdu |
| Empty name submitted | `PrimaryButton` disabled until `TextField` value is non-empty after trim |
| RTL not applied for Urdu | `Directionality(textDirection: TextDirection.rtl)` when `provider.languageId == 'ur'` — also set on `TextField` |
| Language changed after onboarding | Settings screen calls `provider.setCustomLanguage(id)` → `notifyListeners()` → `MyApp` rebuilds |
| App updated with new onboarding steps | Add versioned flag `onboarded_v2` alongside existing `onboarded` — existing users skip new steps |
| Low-end Android device (slow storage) | Hive is async — always `await` writes — show loading indicator if needed |

---

## 15. Developer Checklist

- [ ] Create folder structure exactly as shown in Section 3
- [ ] Create `assets/lang/en.arb`, `ur.arb`, `roman_ur.json` with matching keys
- [ ] Download `JameelNooriNastaleeq.ttf` and place in `assets/fonts/`
- [ ] Add splash logo to `assets/images/splash_logo.png`
- [ ] Copy `pubspec.yaml` dependencies, dev_dependencies, assets, and fonts from Section 11
- [ ] Run `flutter pub get`
- [ ] Run `dart run flutter_native_splash:create`
- [ ] Set up Firebase project and download `google-services.json` (Section 13)
- [ ] Enable Google Sign-In in Firebase Console
- [ ] Add SHA-1 fingerprint to Firebase Android app
- [ ] Implement `OnboardingProvider` (Section 5)
- [ ] Implement `RomanUrduDelegate` + `InheritedRomanUrdu` (Section 6)
- [ ] Implement `main()` exactly as shown in Section 7
- [ ] Implement `MyApp` exactly as shown in Section 8
- [ ] Implement `_t()` helper in screens (Section 9)
- [ ] Implement `AuthService` (Section 10)
- [ ] Build all screens with `PopScope(canPop: false)` on each
- [ ] Test: English UI end-to-end
- [ ] Test: Urdu UI — RTL layout, Nastaleeq font, Urdu notifications
- [ ] Test: Roman Urdu UI — all strings show correctly
- [ ] Test: Skip flow — app works fully offline without sign-in
- [ ] Test: Google Sign-In — success, cancel, and network error states
- [ ] Test: Kill and reopen app — confirm onboarding does NOT show again
- [ ] Run `dart run build_runner build` (for Hive generators)
- [ ] Run `flutter analyze` — fix all warnings
- [ ] Run `flutter test`

---

**End of Plan**
