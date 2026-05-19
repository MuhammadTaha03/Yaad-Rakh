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
    super.key,
    required this.strings,
    required super.child,
  });

  static InheritedRomanUrdu of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<InheritedRomanUrdu>();
    assert(result != null, 'No InheritedRomanUrdu found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(InheritedRomanUrdu oldWidget) =>
      strings != oldWidget.strings;
}
