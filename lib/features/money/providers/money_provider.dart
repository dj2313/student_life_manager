import 'package:flutter/material.dart';
import '../../../data/models/expense.dart';

class MoneyProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  double _totalBalance = 2450.00;
  double _blockedAccountBalance = 11208.00;

  List<Expense> get expenses => _expenses;
  double get totalBalance => _totalBalance;
  double get blockedAccountBalance => _blockedAccountBalance;

  MoneyProvider() {
    _loadMockData();
  }

  void _loadMockData() {
    _expenses = [
      Expense(
        id: '1',
        description: 'Rent',
        amount: 450.00,
        date: DateTime.now().subtract(const Duration(days: 5)),
        category: 'Housing',
      ),
      Expense(
        id: '2',
        description: 'Groceries',
        amount: 45.20,
        date: DateTime.now().subtract(const Duration(days: 2)),
        category: 'Food',
      ),
      Expense(
        id: '3',
        description: 'Subscription',
        amount: 12.99,
        date: DateTime.now().subtract(const Duration(days: 1)),
        category: 'Entertainment',
      ),
    ];
    notifyListeners();
  }

  void addExpense(Expense expense) {
    _expenses.add(expense);
    _totalBalance -= expense.amount;
    notifyListeners();
  }

  double getMonthlySpending() {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.date.month == now.month && e.date.year == now.year)
        .fold(0.0, (sum, e) => sum + e.amount);
  }
}
