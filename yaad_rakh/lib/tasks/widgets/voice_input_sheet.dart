// lib/tasks/widgets/voice_input_sheet.dart

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import '../task_provider.dart';
import '../models/task.dart';
import '../services/natural_language_parser.dart';
import '../../onboarding/onboarding_provider.dart';
import 'date_time_picker.dart';

class VoiceInputSheet extends StatefulWidget {
  const VoiceInputSheet({super.key});

  @override
  State<VoiceInputSheet> createState() => _VoiceInputSheetState();
}

class _VoiceInputSheetState extends State<VoiceInputSheet> with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _speechAvailable = false;
  String _transcription = "";
  String _selectedLangCode = "ur-PK"; // Default to Urdu script speaking for Pakistan

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final TextEditingController _manualController = TextEditingController();

  // Parsing outputs
  DateTime? _parsedDate;
  String? _parsedTime;
  String _parsedCleanTitle = "";
  String? _parsedCategoryId;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
    
    // Animation for pulsing mic button
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _manualController.dispose();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    try {
      final available = await _speech.initialize(
        onStatus: (val) {
          log("SpeechToText status change: $val");
          if (val == "notListening" || val == "done") {
            setState(() => _isListening = false);
          }
        },
        onError: (val) {
          log("SpeechToText error: $val");
          setState(() => _isListening = false);
        },
      );
      
      if (mounted) {
        setState(() {
          _speechAvailable = available;
        });
      }
    } catch (e) {
      log("SpeechToText initialization failed: $e");
    }
  }

  void _startListening() async {
    if (!_speechAvailable) {
      // Re-try initialization
      await _initSpeech();
      if (!_speechAvailable) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Voice recognition unavailable. Please use manual fallback.")),
          );
        }
        return;
      }
    }

    setState(() {
      _isListening = true;
      _transcription = "";
      _manualController.clear();
      _parsedDate = null;
      _parsedTime = null;
      _parsedCleanTitle = "";
      _parsedCategoryId = null;
    });

    await _speech.listen(
      localeId: _selectedLangCode,
      onResult: (val) {
        setState(() {
          _transcription = val.recognizedWords;
          _manualController.text = _transcription;
          _onTextChanged(_transcription);
        });
      },
    );
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  void _onTextChanged(String text) {
    if (text.isEmpty) return;
    
    final parsed = NaturalLanguageParser.parse(text);
    setState(() {
      _parsedCleanTitle = parsed.cleanTitle;
      _parsedDate = parsed.detectedDate;
      _parsedTime = parsed.detectedTime;
      _parsedCategoryId = parsed.detectedCategoryId;
    });
  }

  void _saveTask(OnboardingProvider onboarding) async {
    final title = _manualController.text.trim();
    if (title.isEmpty) return;

    // Use our NLP clean title if present, otherwise default to full typed text
    final finalTitle = _parsedCleanTitle.isNotEmpty ? _parsedCleanTitle : title;

    final provider = Provider.of<TaskProvider>(context, listen: false);
    final settingsBox = Hive.box('settings');
    final activeLang = onboarding.languageId;
    final defaultOffset = settingsBox.get('defaultOffsetMinutes', defaultValue: 15) as int;

    TaskCategory staticCat = TaskCategory.other;
    if (_parsedCategoryId == 'home') {
      staticCat = TaskCategory.home;
    } else if (_parsedCategoryId == 'work') {
      staticCat = TaskCategory.work;
    } else if (_parsedCategoryId == 'study') {
      staticCat = TaskCategory.study;
    } else if (_parsedCategoryId == 'shopping') {
      staticCat = TaskCategory.shopping;
    }

    final task = Task(
      id: const Uuid().v4(),
      title: finalTitle,
      dueDate: _parsedDate,
      dueTime: _parsedTime,
      repeatOption: RepeatOption.none,
      category: staticCat,
      customCategoryId: _parsedCategoryId ?? 'other',
      createdAt: DateTime.now(),
      languageId: activeLang,
      reminderOffsetMinutes: defaultOffset,
    );

    await provider.addTask(task);
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            activeLang == 'ur'
                ? "کام شامل کر دیا گیا!"
                : activeLang == 'roman_ur'
                    ? "Kaam shamil ho gaya!"
                    : "Task created successfully!",
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = Provider.of<OnboardingProvider>(context);
    final theme = Theme.of(context);
    final isUrdu = onboarding.languageId == 'ur';

    // Localized typography
    String titleLabel = "Add Task with Voice";
    String startPrompt = "Tap and start speaking...";
    String listeningPrompt = "Listening carefully...";
    String manualOverrideLabel = "Fallback edit box";
    String saveBtnLabel = "SAVE TASK";
    
    if (isUrdu) {
      titleLabel = "آواز سے کام شامل کریں";
      startPrompt = "بولنے کے لیے بٹن دبائیں...";
      listeningPrompt = "سن رہا ہوں...";
      manualOverrideLabel = "ترمیم کریں (ضرورت پڑنے پر)";
      saveBtnLabel = "محفوظ کریں";
    } else if (onboarding.languageId == 'roman_ur') {
      titleLabel = "Awaaz se Task add karein";
      startPrompt = "Bolne ke liye button dabayein...";
      listeningPrompt = "Sun raha hoon...";
      manualOverrideLabel = "Aap edit bhi kar sakte hain";
      saveBtnLabel = "SAVE KAREIN";
    }

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Bar Slider Indicator
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Header with language selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  titleLabel,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Speech-to-Text Language Selection Dropdown
                DropdownButton<String>(
                  value: _selectedLangCode,
                  underline: const SizedBox(),
                  borderRadius: BorderRadius.circular(12),
                  items: const [
                    DropdownMenuItem(
                      value: "ur-PK",
                      child: Row(
                        children: [
                          Text("🇵🇰 "),
                          Text("اردو (Pakistan)"),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: "en-US",
                      child: Row(
                        children: [
                          Text("🇺🇸 "),
                          Text("English"),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedLangCode = val;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Microphone Pulsing listening button
            Center(
              child: GestureDetector(
                onTap: _isListening ? _stopListening : _startListening,
                child: ScaleTransition(
                  scale: _isListening ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: _isListening ? theme.colorScheme.error : theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_isListening ? theme.colorScheme.error : theme.colorScheme.primary).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: theme.colorScheme.onPrimary,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Pulsing listener description status
            Text(
              _isListening ? listeningPrompt : startPrompt,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),

            // Live editable text box fallback override
            TextField(
              controller: _manualController,
              maxLines: 3,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                labelText: manualOverrideLabel,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onChanged: _onTextChanged,
            ),
            
            // Dynamic parser extraction outputs
            if (_parsedDate != null || _parsedTime != null || _parsedCategoryId != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, size: 16, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          isUrdu ? "خود کار طریقے سے نکالا گیا ڈیٹا" : "Auto-extracted Schedule",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_parsedCleanTitle.isNotEmpty)
                      Text(
                        "${isUrdu ? 'کام:' : 'Task:'} $_parsedCleanTitle",
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (_parsedDate != null) ...[
                          Icon(Icons.calendar_month, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                          const SizedBox(width: 4),
                          Text(
                            "${_parsedDate!.day}/${_parsedDate!.month}/${_parsedDate!.year}",
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                        if (_parsedTime != null) ...[
                          const SizedBox(width: 16),
                          Icon(Icons.access_time_filled, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                          const SizedBox(width: 4),
                          Text(
                            _parsedTime!,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                        if (_parsedCategoryId != null) ...[
                          const SizedBox(width: 16),
                          Icon(Icons.label_outline, size: 14, color: theme.colorScheme.primary),
                          const SizedBox(width: 4),
                          Text(
                            _parsedCategoryId!.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            
            // Scheduling picker so user can verify or add reminder time
            DateTimePicker(
              selectedDate: _parsedDate,
              selectedTime: _parsedTime,
              onDateSelected: (date) => setState(() => _parsedDate = date),
              onTimeSelected: (time) => setState(() => _parsedTime = time),
            ),
            
            const SizedBox(height: 32),

            // Save CTA Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _manualController.text.trim().isEmpty ? null : () => _saveTask(onboarding),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  saveBtnLabel,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
