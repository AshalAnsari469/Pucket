import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyNotifier extends Notifier<String> {
  static const _currencyKey = 'currency_preference';

  @override
  String build() {
    _loadCurrency();
    return '\$'; // Default currency
  }

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCurrency = prefs.getString(_currencyKey);
    if (savedCurrency != null) {
      state = savedCurrency;
    }
  }

  Future<void> setCurrency(String symbol) async {
    state = symbol;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, symbol);
  }
}

final currencyProvider = NotifierProvider<CurrencyNotifier, String>(CurrencyNotifier.new);
