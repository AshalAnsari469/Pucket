class CurrencyConverter {
  // Static average Exchange rates relative to USD (1.0)
  static const Map<String, double> ratesVsUSD = {
    '\$': 1.0,     // USD
    '€': 0.92,     // EUR
    '£': 0.79,     // GBP
    '₹': 83.3,     // INR
    '¥': 151.0,    // JPY
  };

  /// Automatically converts an amount between two global currencies.
  static double convert({
    required double amount,
    required String fromSymbol,
    required String toSymbol,
  }) {
    if (fromSymbol == toSymbol) return amount;
    
    final fromRate = ratesVsUSD[fromSymbol] ?? 1.0;
    final toRate = ratesVsUSD[toSymbol] ?? 1.0;

    // Convert original currency to base USD equivalent
    final amountInUSD = amount / fromRate;

    // Convert USD to final target currency
    return amountInUSD * toRate;
  }
}
