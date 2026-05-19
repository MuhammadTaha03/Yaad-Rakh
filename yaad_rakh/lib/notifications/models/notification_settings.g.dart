// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationSettingsAdapter extends TypeAdapter<NotificationSettings> {
  @override
  final int typeId = 4;

  @override
  NotificationSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationSettings(
      enableReminders: fields[0] as bool,
      enableMorningSummary: fields[1] as bool,
      morningSummaryTime: fields[2] as String,
      defaultOffsetMinutes: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationSettings obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.enableReminders)
      ..writeByte(1)
      ..write(obj.enableMorningSummary)
      ..writeByte(2)
      ..write(obj.morningSummaryTime)
      ..writeByte(3)
      ..write(obj.defaultOffsetMinutes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
