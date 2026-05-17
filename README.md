# 📋 Yaad Rakh — یاد رکھ
### The Task Manager That Works For Everyone

> *Itna simple ho ke Ammi bhi use kar sakein*
> *(So simple that even Mom can use it)*

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore-orange?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey)](https://flutter.dev)
[![Status](https://img.shields.io/badge/Status-In%20Development-yellow)]()
[![Language](https://img.shields.io/badge/Languages-Urdu%20%7C%20Roman%20Urdu%20%7C%20English-brightgreen)]()

---

## 🌟 About The App

**Yaad Rakh** is a free, offline-first task and reminder app built for **everyone** — from tech-savvy students to mothers who have never used a productivity app in their life.

Most task apps are built for English-speaking office workers. **Yaad Rakh** is built for **Pakistan** — with full Urdu language support, voice input in Urdu, and an interface so simple that no tutorial is needed.

---

## ✨ Key Features

- 🗣️ **Voice Input in Urdu** — Speak naturally, app creates the task automatically
- 🌐 **Multilingual** — Full support for Urdu (اردو), Roman Urdu, and English
- 📴 **Works Offline** — Reminders and tasks work without internet
- 🔔 **Reliable Reminders** — Notifications in your own language
- 🧠 **Smart Task Detection** — Auto-detects date, time, and category from what you type or say
- 📅 **Calendar View** — See all your tasks across days and months
- 🗂️ **Categories** — Home, Work, Study, Shopping and custom lists
- 🌙 **Dark Mode** — Easy on the eyes
- 💯 **Completely Free** — No subscriptions, no hidden charges

---

## 📱 Screenshots

> Coming soon...

---

## 🏗️ App Modules

| # | Module | Status |
|---|--------|--------|
| 1 | Onboarding (Language Selection) | 🔄 Planned |
| 2 | Task Management | 🔄 Planned |
| 3 | Reminders & Notifications | 🔄 Planned |
| 4 | Voice Input (Urdu + English) | 🔄 Planned |
| 5 | Home Dashboard | 🔄 Planned |
| 6 | Calendar View | 🔄 Planned |
| 7 | Categories / Lists | 🔄 Planned |
| 8 | Settings | 🔄 Planned |
| 9 | Basic AI Layer | 🔄 Planned |
| 10 | Offline Mode | 🔄 Planned |

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| 📱 Frontend | Flutter 3.x |
| 🗄️ Local Storage | Hive |
| ☁️ Backend / Sync | Firebase Firestore |
| 🔐 Authentication | Firebase Auth |
| 🔔 Notifications | Flutter Local Notifications + FCM |
| 🎙️ Voice Input | Google Speech-to-Text API (ur-PK) |
| 🌐 Localization | flutter_localizations |

---

## 📂 Project Structure

```
yaad_rakh/
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart
│   │   └── routes.dart
│   ├── core/
│   │   ├── constants/
│   │   ├── theme/
│   │   └── utils/
│   ├── data/
│   │   ├── models/
│   │   ├── repositories/
│   │   └── services/
│   ├── modules/
│   │   ├── onboarding/
│   │   ├── dashboard/
│   │   ├── tasks/
│   │   ├── calendar/
│   │   ├── categories/
│   │   ├── voice/
│   │   ├── notifications/
│   │   └── settings/
│   └── l10n/
│       ├── app_en.arb
│       ├── app_ur.arb
│       └── app_roman_ur.arb
├── assets/
│   ├── images/
│   ├── icons/
│   └── fonts/
├── test/
├── pubspec.yaml
└── README.md
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.x or higher
- Dart SDK
- Android Studio / VS Code
- Firebase account
- Google Cloud account (for Speech-to-Text API)

### Installation

1. **Clone the repository**
```bash
https://github.com/MuhammadTaha03/Yaad-Rakh.git
cd yaad_rakh
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Setup Firebase**
   - Create a new Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Add Android & iOS apps
   - Download and place `google-services.json` in `android/app/`
   - Download and place `GoogleService-Info.plist` in `ios/Runner/`

4. **Setup Google Speech-to-Text**
   - Enable Speech-to-Text API in Google Cloud Console
   - Add your API key to environment config

5. **Run the app**
```bash
flutter run
```

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Firebase
  firebase_core: latest
  cloud_firestore: latest
  firebase_auth: latest
  firebase_messaging: latest

  # Local Storage
  hive: latest
  hive_flutter: latest

  # Notifications
  flutter_local_notifications: latest

  # Voice Input
  speech_to_text: latest

  # Localization
  flutter_localizations:
    sdk: flutter
  intl: latest

  # UI
  table_calendar: latest
  google_fonts: latest

  # State Management
  provider: latest
```

---

## 🌍 Supported Languages

| Language | Status |
|----------|--------|
| English | ✅ Supported |
| اردو (Urdu) | ✅ Supported |
| Roman Urdu | ✅ Supported |
| Hindi | 🔄 Phase 2 |
| Arabic | 🔄 Phase 2 |

---

## 🗺️ Roadmap

### Phase 1 — MVP *(Current)*
- [x] Module planning & documentation
- [ ] Project setup & architecture
- [ ] Onboarding flow
- [ ] Core task management
- [ ] Offline reminders
- [ ] Urdu voice input
- [ ] Home dashboard
- [ ] Calendar view
- [ ] Settings

### Phase 2 — Intelligence
- [ ] Habit tracking
- [ ] Productivity analytics
- [ ] AI behavior detection
- [ ] Burnout prediction
- [ ] Pomodoro timer

### Phase 3 — Growth
- [ ] Shared tasks / Family lists
- [ ] Widget support
- [ ] WearOS support
- [ ] More language support
- [ ] Play Store & App Store launch

---

## 🤝 Contributing

This project is currently in solo development. Contributions, suggestions, and feedback are welcome!

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 🐛 Reporting Issues

Found a bug? Please open an issue with:
- Device model & OS version
- Steps to reproduce
- Expected vs actual behavior
- Screenshot (if possible)

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Developer

Built with ❤️ in Pakistan 🇵🇰

> *This app was inspired by the need to build technology that works for everyone — not just those who speak English or understand complex interfaces.*

---

## 🙏 Acknowledgements

- [Flutter](https://flutter.dev) — UI framework
- [Firebase](https://firebase.google.com) — Backend & sync
- [Google Speech-to-Text](https://cloud.google.com/speech-to-text) — Urdu voice recognition
- All the Pakistani users who deserve better apps

---

⭐ **If you like this project, please give it a star!** ⭐
