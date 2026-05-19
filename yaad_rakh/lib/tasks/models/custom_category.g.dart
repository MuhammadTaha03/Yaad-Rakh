// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomCategoryAdapter extends TypeAdapter<CustomCategory> {
  @override
  final int typeId = 5;

  @override
  CustomCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomCategory(
      id: fields[0] as String,
      nameEnglish: fields[1] as String,
      nameUrdu: fields[2] as String,
      nameRomanUrdu: fields[3] as String,
      colorHex: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CustomCategory obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nameEnglish)
      ..writeByte(2)
      ..write(obj.nameUrdu)
      ..writeByte(3)
      ..write(obj.nameRomanUrdu)
      ..writeByte(4)
      ..write(obj.colorHex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
