import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../theme/theme_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/currency_provider.dart';
import '../widgets/settings_drawer.dart';
import '../widgets/expense_chart.dart';
import '../widgets/voice_expense_button.dart';
import 'add_expense_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalBalance = ref.watch(totalBalanceProvider);
    final transactions = ref.watch(expenseProvider);
    final globalCurrency = ref.watch(currencyProvider);
    
    final baseCurrencyFormat = NumberFormat.currency(symbol: globalCurrency, decimalDigits: 2);

    return Scaffold(
      drawer: const SettingsDrawer(),
      appBar: AppBar(
        title: const Text('Pucket'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            tooltip: 'Base Currency',
            onSelected: (String symbol) {
              ref.read(currencyProvider.notifier).setCurrency(symbol);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(value: '\$', child: Text('USD (\$)')),
              const PopupMenuItem<String>(value: '€', child: Text('EUR (€)')),
              const PopupMenuItem<String>(value: '£', child: Text('GBP (£)')),
              const PopupMenuItem<String>(value: '₹', child: Text('INR (₹)')),
              const PopupMenuItem<String>(value: '¥', child: Text('JPY (¥)')),
            ],
          ),
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle Theme',
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Total Balance',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      baseCurrencyFormat.format(totalBalance),
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.0,
                            color: Colors.white,
                          ),
                    ),
                  ],
                ),
              ).animate().fade(duration: 600.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: const ExpenseChart().animate().fade(delay: 200.ms, duration: 600.ms).slideY(begin: 0.2, curve: Curves.easeOutCubic),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Recent Transactions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (transactions.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 80, color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.2)),
                    const SizedBox(height: 16),
                    Text(
                      'No recent transactions',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ).animate().fade().scale(curve: Curves.easeOutBack),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final tx = transactions[index];
                    final isIncome = tx.isIncome;
                    final displayColor = isIncome ? Colors.green : Colors.redAccent;
                    final localFormat = NumberFormat.currency(symbol: tx.currencySymbol, decimalDigits: 2);

                    return Dismissible(
                      key: Key(tx.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(24)
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 28.0),
                        child: const Icon(Icons.delete_sweep, color: Colors.white, size: 30),
                      ),
                      onDismissed: (direction) {
                        ref.read(expenseProvider.notifier).deleteExpense(tx.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${tx.category} deleted')),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            )
                          ]
                        ),
                        child: ListTile(
                          leading: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: displayColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16)
                            ),
                            child: Icon(
                              isIncome ? Icons.keyboard_double_arrow_up : Icons.keyboard_double_arrow_down,
                              color: displayColor,
                            ),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(tx.category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              if (tx.receiptPath != null)
                                const Icon(Icons.attachment, size: 16, color: Colors.grey),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(DateFormat.yMMMd().format(tx.date)),
                              if (tx.location.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Expanded(child: Text(tx.location, style: const TextStyle(color: Colors.grey))),
                                  ],
                                ),
                              ],
                              if (tx.note.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(tx.note, style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.bodyLarge?.color)),
                              ],
                              if (tx.tags.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: tx.tags.map((tag) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8)
                                    ),
                                    child: Text(
                                      '#$tag',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  )).toList(),
                                )
                              ]
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${isIncome ? '+' : '-'}${localFormat.format(tx.amount)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  letterSpacing: -0.5,
                                  color: displayColor,
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => AddExpenseScreen(expense: tx)),
                            );
                          },
                        ),
                      ),
                    ).animate().fade(duration: 400.ms, delay: Duration(milliseconds: 50 * index)).slideX(begin: 0.1, end: 0, curve: Curves.easeOutQuad);
                  },
                  childCount: transactions.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom padding for FABs
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const VoiceExpenseButton().animate().scale(delay: 500.ms, duration: 400.ms, curve: Curves.elasticOut),
            FloatingActionButton(
              heroTag: 'add_fab',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
                );
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.add, size: 28),
            ).animate().scale(delay: 400.ms, duration: 400.ms, curve: Curves.elasticOut),
          ],
        ),
      ),
    );
  }
}
