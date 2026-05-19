// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 1;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      id: fields[0] as String,
      title: fields[1] as String,
      dueDate: fields[2] as DateTime?,
      dueTime: fields[3] as String?,
      repeatOption: fields[4] as RepeatOption,
      category: fields[5] as TaskCategory,
      isCompleted: fields[6] as bool,
      createdAt: fields[7] as DateTime,
      languageId: fields[8] as String,
      isSyncedToFirestore: fields[9] as bool,
      reminderOffsetMinutes: fields[10] as int,
      customCategoryId: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.dueDate)
      ..writeByte(3)
      ..write(obj.dueTime)
      ..writeByte(4)
      ..write(obj.repeatOption)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.isCompleted)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.languageId)
      ..writeByte(9)
      ..write(obj.isSyncedToFirestore)
      ..writeByte(10)
      ..write(obj.reminderOffsetMinutes)
      ..writeByte(11)
      ..write(obj.customCategoryId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RepeatOptionAdapter extends TypeAdapter<RepeatOption> {
  @override
  final int typeId = 2;

  @override
  RepeatOption read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RepeatOption.none;
      case 1:
        return RepeatOption.daily;
      case 2:
        return RepeatOption.weekly;
      case 3:
        return RepeatOption.monthly;
      case 4:
        return RepeatOption.custom;
      default:
        return RepeatOption.none;
    }
  }

  @override
  void write(BinaryWriter writer, RepeatOption obj) {
    switch (obj) {
      case RepeatOption.none:
        writer.writeByte(0);
        break;
      case RepeatOption.daily:
        writer.writeByte(1);
        break;
      case RepeatOption.weekly:
        writer.writeByte(2);
        break;
      case RepeatOption.monthly:
        writer.writeByte(3);
        break;
      case RepeatOption.custom:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepeatOptionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskCategoryAdapter extends TypeAdapter<TaskCategory> {
  @override
  final int typeId = 3;

  @override
  TaskCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskCategory.home;
      case 1:
        return TaskCategory.work;
      case 2:
        return TaskCategory.study;
      case 3:
        return TaskCategory.shopping;
      case 4:
        return TaskCategory.other;
      default:
        return TaskCategory.home;
    }
  }

  @override
  void write(BinaryWriter writer, TaskCategory obj) {
    switch (obj) {
      case TaskCategory.home:
        writer.writeByte(0);
        break;
      case TaskCategory.work:
        writer.writeByte(1);
        break;
      case TaskCategory.study:
        writer.writeByte(2);
        break;
      case TaskCategory.shopping:
        writer.writeByte(3);
        break;
      case TaskCategory.other:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
