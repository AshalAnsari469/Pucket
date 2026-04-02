import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../providers/currency_provider.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final Expense? expense;
  final String? initialNote;

  const AddExpenseScreen({super.key, this.expense, this.initialNote});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _locationController = TextEditingController();
  final _tagController = TextEditingController();

  late String _selectedCategory;
  late bool _isIncome;
  late String _localCurrency;
  late DateTime _selectedDate;
  String? _receiptPath;
  List<String> _tags = [];

  final List<String> _expenseCategories = [
    'Food', 'Transport', 'Entertainment', 'Shopping', 'Bills', 'Other'
  ];

  final List<String> _incomeCategories = [
    'Salary', 'Freelance', 'Gift', 'Investment', 'Other'
  ];

  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      final e = widget.expense!;
      _amountController.text = e.amount.toString();
      _noteController.text = e.note;
      _locationController.text = e.location;
      _isIncome = e.isIncome;
      _selectedCategory = e.category;
      _localCurrency = e.currencySymbol;
      _selectedDate = e.date;
      _receiptPath = e.receiptPath;
      _tags = List.from(e.tags);
    } else {
      _isIncome = false;
      _selectedCategory = 'Food';
      _localCurrency = '\$';
      _selectedDate = DateTime.now();
      if (widget.initialNote != null) _noteController.text = widget.initialNote!;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit && widget.expense == null) {
      _localCurrency = ref.read(currencyProvider);
      _isInit = false;
    }
  }

  void _addTag(String tag) {
    if (tag.trim().isNotEmpty && !_tags.contains(tag.trim().toLowerCase())) {
      setState(() {
        _tags.add(tag.trim().toLowerCase());
        _tagController.clear();
      });
    }
  }

  Future<void> _pickReceipt(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _receiptPath = pickedFile.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to load image')));
    }
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _saveTransaction() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final expense = Expense(
      id: widget.expense?.id,
      amount: amount,
      date: _selectedDate,
      category: _selectedCategory,
      note: _noteController.text.trim(),
      location: _locationController.text.trim(),
      isIncome: _isIncome,
      currencySymbol: _localCurrency,
      receiptPath: _receiptPath,
      tags: _tags,
    );

    if (widget.expense == null) {
      ref.read(expenseProvider.notifier).addExpense(expense);
    } else {
      ref.read(expenseProvider.notifier).updateExpense(expense);
    }
    
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final currentCategories = _isIncome ? _incomeCategories : _expenseCategories;

    if (!currentCategories.contains(_selectedCategory)) {
      _selectedCategory = currentCategories.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense == null 
            ? (_isIncome ? 'Add Income' : 'Add Expense')
            : 'Edit Transaction'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Expense'), icon: Icon(Icons.arrow_upward)),
                  ButtonSegment(value: true, label: Text('Income'), icon: Icon(Icons.arrow_downward)),
                ],
                selected: {_isIncome},
                onSelectionChanged: (Set<bool> newSelection) {
                  setState(() {
                    _isIncome = newSelection.first;
                    if (!(_isIncome ? _incomeCategories : _expenseCategories).contains(_selectedCategory)) {
                      _selectedCategory = (_isIncome ? _incomeCategories : _expenseCategories).first;
                    }
                  });
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                    (states) {
                      if (states.contains(WidgetState.selected)) {
                        return _isIncome ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2);
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: _isIncome ? Colors.green : Colors.redAccent,
              ),
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixIcon: PopupMenuButton<String>(
                  icon: Center(
                    widthFactor: 1.5,
                    child: Text(
                      _localCurrency,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _isIncome ? Colors.green : Colors.redAccent,
                      ),
                    ),
                  ),
                  tooltip: 'Change Transaction Currency',
                  onSelected: (String symbol) {
                    setState(() {
                      _localCurrency = symbol;
                    });
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(value: '\$', child: Text('USD (\$)')),
                    const PopupMenuItem<String>(value: '€', child: Text('EUR (€)')),
                    const PopupMenuItem<String>(value: '£', child: Text('GBP (£)')),
                    const PopupMenuItem<String>(value: '₹', child: Text('INR (₹)')),
                    const PopupMenuItem<String>(value: '¥', child: Text('JPY (¥)')),
                  ],
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    items: currentCategories.map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: _selectDate,
                    borderRadius: BorderRadius.circular(24),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat.yMMMd().format(_selectedDate)),
                          const Icon(Icons.calendar_month, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Location / Payee',
                prefixIcon: const Icon(Icons.storefront_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Note (optional)',
                prefixIcon: const Icon(Icons.notes),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _tagController,
              decoration: InputDecoration(
                labelText: 'Add Tag (press Enter)',
                prefixIcon: const Icon(Icons.tag),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
              ),
              onSubmitted: _addTag,
            ),
            if (_tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _tags.map((tag) => InputChip(
                    label: Text('#$tag'),
                    onDeleted: () {
                      setState(() {
                        _tags.remove(tag);
                      });
                    },
                    backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    deleteIconColor: Theme.of(context).colorScheme.primary,
                  )).toList(),
                ),
              ),
            const SizedBox(height: 32),
            Text('Attachments', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (_receiptPath != null)
              Stack(
                children: [
                   ClipRRect(
                     borderRadius: BorderRadius.circular(16),
                     child: Image.file(File(_receiptPath!), height: 120, width: 120, fit: BoxFit.cover),
                   ),
                   Positioned(
                     top: 4, right: 4,
                     child: GestureDetector(
                       onTap: () => setState(() => _receiptPath = null),
                       child: const CircleAvatar(radius: 14, backgroundColor: Colors.red, child: Icon(Icons.close, size: 16, color: Colors.white)),
                     )
                   )
                ],
              )
            else
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _pickReceipt(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Camera'),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => _pickReceipt(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Gallery'),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  )
                ],
              ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(widget.expense == null ? 'Save Transaction' : 'Update Transaction', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
