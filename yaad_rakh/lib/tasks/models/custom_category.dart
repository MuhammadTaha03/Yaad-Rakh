// lib/tasks/models/custom_category.dart

import 'package:hive/hive.dart';

part 'custom_category.g.dart';

@HiveType(typeId: 5)
class CustomCategory extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String nameEnglish;

  @HiveField(2)
  String nameUrdu;

  @HiveField(3)
  String nameRomanUrdu;

  @HiveField(4)
  int colorHex; // Stored as ARGB integer, e.g. 0xFF8B5CF6

  CustomCategory({
    required this.id,
    required this.nameEnglish,
    required this.nameUrdu,
    required this.nameRomanUrdu,
    required this.colorHex,
  });

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'nameEnglish': nameEnglish,
        'nameUrdu': nameUrdu,
        'nameRomanUrdu': nameRomanUrdu,
        'colorHex': colorHex,
      };

  factory CustomCategory.fromFirestore(Map<String, dynamic> data) => CustomCategory(
        id: data['id'] as String,
        nameEnglish: data['nameEnglish'] as String,
        nameUrdu: data['nameUrdu'] as String,
        nameRomanUrdu: data['nameRomanUrdu'] as String,
        colorHex: data['colorHex'] as int,
      );
}
