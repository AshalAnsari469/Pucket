// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpenseAdapter extends TypeAdapter<Expense> {
  @override
  final int typeId = 0;

  @override
  Expense read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Expense(
      id: fields[0] as String?,
      amount: fields[1] as double,
      date: fields[2] as DateTime,
      category: fields[3] as String,
      note: fields[4] as String,
      location: fields[5] as String,
      isIncome: fields[6] as bool,
      currencySymbol: fields[7] as String,
      receiptPath: fields[8] as String?,
      tags: (fields[9] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Expense obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.note)
      ..writeByte(5)
      ..write(obj.location)
      ..writeByte(6)
      ..write(obj.isIncome)
      ..writeByte(7)
      ..write(obj.currencySymbol)
      ..writeByte(8)
      ..write(obj.receiptPath)
      ..writeByte(9)
      ..write(obj.tags);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
