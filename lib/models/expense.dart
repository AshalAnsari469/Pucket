import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'expense.g.dart';

const uuid = Uuid();

@HiveType(typeId: 0)
class Expense extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final String note;

  @HiveField(5)
  final String location;

  @HiveField(6)
  final bool isIncome;

  @HiveField(7)
  final String currencySymbol;

  @HiveField(8)
  final String? receiptPath;

  @HiveField(9)
  final List<String> tags;

  Expense({
    String? id,
    required this.amount,
    required this.date,
    required this.category,
    this.note = '',
    this.location = '',
    this.isIncome = false,
    this.currencySymbol = '\$',
    this.receiptPath,
    this.tags = const [],
  }) : id = id ?? uuid.v4();
}
