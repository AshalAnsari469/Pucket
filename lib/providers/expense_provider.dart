import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';
import 'currency_provider.dart';
import '../utils/currency_converter.dart';

class ExpenseNotifier extends Notifier<List<Expense>> {
  late final Box<Expense> _box;

  @override
  List<Expense> build() {
    _box = Hive.box<Expense>('premium_transactions');
    return _loadExpenses();
  }

  List<Expense> _loadExpenses() {
    return _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addExpense(Expense expense) async {
    await _box.put(expense.id, expense);
    state = _loadExpenses();
  }

  Future<void> deleteExpense(String id) async {
    await _box.delete(id);
    state = _loadExpenses();
  }

  Future<void> updateExpense(Expense expense) async {
    await _box.put(expense.id, expense);
    state = _loadExpenses();
  }
}

final expenseProvider = NotifierProvider<ExpenseNotifier, List<Expense>>(ExpenseNotifier.new);

// Provider for calculating the total spent/balance in the global currency view
final totalBalanceProvider = Provider<double>((ref) {
  final transactions = ref.watch(expenseProvider);
  final globalCurrency = ref.watch(currencyProvider); // e.g. the Dashboard Base Currency

  return transactions.fold(0.0, (sum, item) {
    
    // Automatically convert the transaction amount from its local currency to the base global currency
    final convertedAmount = CurrencyConverter.convert(
      amount: item.amount,
      fromSymbol: item.currencySymbol,
      toSymbol: globalCurrency,
    );

    if (item.isIncome) {
      return sum + convertedAmount;
    } else {
      return sum - convertedAmount;
    }
  });
});
