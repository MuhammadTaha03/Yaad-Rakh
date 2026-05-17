# 📱 Task App — Module Documentation

> **App Philosophy:** *Itna simple ho ke Ammi bhi use kar sakein*
> Target: Pakistani users — Students, Housewives, Shopkeepers, Office Workers
> Stack: Flutter + Firebase
> Languages: Urdu | Roman Urdu | English

---

## Module 1 — Onboarding

**Purpose:** First impression. Must be simple, welcoming, and fast.

### Features
- Language selection screen (Urdu / Roman Urdu / English) — shown before anything else
- Name input — personalizes the app ("Salaam Ahmed!")
- Optional account creation — user can skip and use locally
- 3-screen simple tutorial — no walls of text, icon-based guidance

### Notes
- Language selected here controls entire app UI, notifications, and voice input
- Skip button always visible — never force registration
- Onboarding only shown once on fresh install

---

## Module 2 — Task Management (Core)

**Purpose:** The heart of the app. Must be fast, reliable, and dead simple.

### Features
- Add task via text input
- Natural language parsing ("kal 9 baje doctor k pas jana hai" → auto sets date & time)
- Due date + time picker
- Repeat options — Daily / Weekly / Monthly / Custom
- Mark task as complete (satisfying checkmark animation)
- Edit existing task
- Delete task (with undo option)
- Simple categories — Home, Work, Study, Shopping, Other

### Notes
- Task entry must work in Urdu script, Roman Urdu, and English
- Keep add-task screen minimal — title, date, time, category only
- No mandatory fields except task title

---

## Module 3 — Reminders & Notifications

**Purpose:** Core utility. If reminders fail, app fails. Reliability is #1.

### Features
- Reminder timing options — On time / 15 min before / 1 hour before / 1 day before
- Notifications displayed in user's selected language
- Offline reminders — work 100% without internet
- Recurring task notifications
- Morning summary notification — "Aaj 3 kaam hain" (You have 3 tasks today)
- Overdue task alert

### Notes
- Use Flutter Local Notifications package for offline reliability
- Firebase Cloud Messaging (FCM) for online push notifications
- Never miss a reminder due to app being closed — use background services
- Notification text must be in Urdu if user selected Urdu

---

## Module 4 — Voice Input

**Purpose:** Key differentiator. Allows non-tech users like Ammi to add tasks by speaking.

### Features
- Tap microphone → speak → task created automatically
- Supports Urdu speech input
- Supports English speech input
- Roman Urdu text input (typed, not voice)
- Auto-extracts date, time, and task name from spoken sentence

### Notes
- Use Google Speech-to-Text API (supports Urdu — language code: ur-PK)
- Fallback to manual entry if voice fails
- Show live transcription while user speaks (so they know it's working)
- Voice button always accessible from home screen

---

## Module 5 — Home Dashboard

**Purpose:** First screen user sees daily. Must show everything important at a glance.

### Features
- Personalized greeting — "Salaam Ahmed!" / "السلام علیکم احمد!"
- Today's tasks list
- Upcoming tasks section
- Overdue tasks — highlighted in red
- Quick Add button — always visible (floating action button)
- Task count summary — "2 complete, 3 remaining"

### Notes
- No clutter — maximum 3 sections on home screen
- Overdue tasks must be visually distinct (red color, warning icon)
- Quick Add button always one tap away
- Pull to refresh for sync

---

## Module 6 — Calendar View

**Purpose:** Visual overview of tasks across days and months.

### Features
- Monthly calendar view
- Tap any date → see tasks for that day
- Color coded dots on dates — pending (blue), done (green), overdue (red)
- Swipe left/right to change months
- Today highlighted clearly

### Notes
- Keep it simple — no complex week/agenda views for MVP
- Use table_calendar Flutter package
- Calendar respects selected language (Urdu month names if Urdu selected)

---

## Module 7 — Categories / Lists

**Purpose:** Organize tasks without overwhelming the user.

### Features
- Default categories — Home (گھر), Work (کام), Study (پڑھائی), Shopping (خریداری), Other (دیگر)
- User can create custom categories
- Assign color to each category
- Filter tasks by category
- Category shown as small color tag on each task

### Notes
- Category names shown in selected language
- Maximum recommended custom categories — 10 (prevent overwhelm)
- Categories optional — user doesn't have to assign one

---

## Module 8 — Settings

**Purpose:** User control over app behavior and appearance.

### Features
- Language change (Urdu / Roman Urdu / English)
- Notification preferences (on/off, timing defaults)
- Theme — Light / Dark / System default
- Profile name edit
- Clear completed tasks option
- App version info
- Privacy policy / About screen

### Notes
- Language change should instantly apply without restart
- Keep settings screen minimal — max 10 options
- No hidden or confusing toggles

---

## Module 9 — Basic AI Layer

**Purpose:** Smart behavior without complexity. Feels intelligent, not robotic.

### Features
- Auto date/time detection from natural language input
- Auto category suggestion based on task keywords
  - "Doctor" → Health
  - "Exam / Imtihan" → Study
  - "Bazar / Shopping" → Shopping
- Smart overdue reminders — re-notify if task still not done
- Morning briefing notification — daily task summary at user-set time
- Keyword detection works in Urdu, Roman Urdu, and English

### Notes
- No external AI API needed for MVP — rule-based keyword matching is enough
- Can upgrade to Gemini API in Phase 2 for true NLP
- Keep AI suggestions subtle — never force them on user

---

## Module 10 — Offline Mode

**Purpose:** App must work perfectly without internet. Critical for Pakistan.

### Features
- All tasks stored locally on device (Hive database)
- Reminders fire offline — no internet needed
- Auto sync to Firebase when internet available
- Conflict resolution — local changes take priority
- No crash, no error screen when offline — silent graceful handling
- Offline indicator (subtle, not alarming)

### Notes
- Use Hive for local storage (fast, Flutter-native)
- Firebase Firestore offline persistence as backup sync layer
- Never show "No Internet" blocking screen — app always usable
- Sync happens silently in background

---

# Module Priority Summary

| # | Module | Priority | Phase |
|---|--------|----------|-------|
| 1 | Onboarding | 🔴 Must Have | MVP |
| 2 | Task Management | 🔴 Must Have | MVP |
| 3 | Reminders & Notifications | 🔴 Must Have | MVP |
| 4 | Voice Input | 🔴 Must Have | MVP |
| 5 | Home Dashboard | 🔴 Must Have | MVP |
| 6 | Calendar View | 🟡 Important | MVP |
| 7 | Categories / Lists | 🟡 Important | MVP |
| 8 | Settings | 🔴 Must Have | MVP |
| 9 | Basic AI Layer | 🟡 Important | MVP |
| 10 | Offline Mode | 🔴 Must Have | MVP |

---

# Intentionally Left Out (Phase 2)

| Feature | Reason |
|---------|--------|
| Habit Tracking | Adds complexity, confuses simple users |
| Analytics Dashboard | Not needed until user base grows |
| Shared / Team Tasks | Solo use case first |
| Pomodoro Timer | Separate concern, Phase 2 |
| Complex AI Behavior Detection | Needs data first |
| Subscription / Monetization | Free for now |

---

# Tech Stack Reference

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter |
| Local Storage | Hive |
| Backend / Sync | Firebase Firestore |
| Authentication | Firebase Auth (optional/skip) |
| Notifications | Flutter Local Notifications + FCM |
| Voice Input | Google Speech-to-Text API (ur-PK) |
| Localization | flutter_localizations |

---

*Document Version: 1.0*
*App Status: Planning Phase*
*Developer: Solo*
