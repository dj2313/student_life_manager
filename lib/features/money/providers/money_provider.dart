import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/expense.dart';
import '../../../data/models/loan.dart';
import '../../../data/models/grocery.dart';
import '../../../core/services/currency_service.dart';

class MoneyProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Dio _dio = Dio();
  final CurrencyService _currencyService = CurrencyService();

  List<Expense> _expenses = [];
  List<Loan> _loans = [];
  List<Grocery> _groceries = [];

  double _totalBalance = 2450.00;
  double _blockedAccountBalance = 11208.00;
  double _eurToInrRate = 89.50;
  bool _isLoading = false;
  bool _isRefreshingRates = false;

  // Multi-currency support
  String _selectedCurrency = 'EUR';
  String _baseCurrency = 'EUR';

  List<Expense> get expenses => _expenses;
  List<Loan> get loans => _loans;
  List<Grocery> get groceries => _groceries;
  bool get isLoading => _isLoading;
  bool get isRefreshingRates => _isRefreshingRates;

  double get totalBalance => _totalBalance;
  double get blockedAccountBalance => _blockedAccountBalance;
  double get eurToInrRate => _eurToInrRate;
  double get inrToEurRate => 1.0 / _eurToInrRate;

  String get selectedCurrency => _selectedCurrency;
  String get baseCurrency => _baseCurrency;
  DateTime? get lastRateUpdate => _currencyService.lastUpdated;
  bool get isRatesStale => _currencyService.isStale;

  String get _uid => _auth.currentUser?.uid ?? 'guest_user';

  MoneyProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      // Load saved currency preference
      await _loadCurrencyPreference();

      if (_auth.currentUser == null) {
        await _auth.signInAnonymously();
      }
      await Future.wait([
        fetchBalances(),
        fetchExpenses(),
        fetchLoans(),
        fetchGroceries(),
        refreshCurrencyRates(),
      ]);
    } catch (e) {
      debugPrint('MoneyProvider Initialization Error: $e');
      _loadMockData();
    }
  }

  Future<void> _loadCurrencyPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _selectedCurrency = prefs.getString('selected_currency') ?? 'EUR';
      _baseCurrency = prefs.getString('base_currency') ?? 'EUR';
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading currency preference: $e');
    }
  }

  Future<void> setSelectedCurrency(String currency) async {
    try {
      _selectedCurrency = currency;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_currency', currency);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving currency preference: $e');
    }
  }

  Future<void> fetchBalances() async {
    try {
      final doc = await _firestore.collection('users').doc(_uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        _totalBalance = (data['personalBalance'] ?? 2450.0).toDouble();
        _blockedAccountBalance = (data['blockedBalance'] ?? 11208.0).toDouble();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching balances: $e');
    }
  }

  Future<void> updateBalances({double? personal, double? blocked}) async {
    try {
      final updates = <String, dynamic>{};
      if (personal != null) {
        updates['personalBalance'] = personal;
        _totalBalance = personal;
      }
      if (blocked != null) {
        updates['blockedBalance'] = blocked;
        _blockedAccountBalance = blocked;
      }

      await _firestore
          .collection('users')
          .doc(_uid)
          .set(updates, SetOptions(merge: true));
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating balances: $e');
    }
  }

  Future<void> fetchExpenses() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('expenses')
          .orderBy('date', descending: true)
          .get();

      _expenses = snapshot.docs
          .map((doc) => Expense.fromJson(doc.data()))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching expenses: $e');
    }
  }

  Future<void> fetchLoans() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('loans')
          .orderBy('dueDate', descending: false)
          .get();

      _loans = snapshot.docs.map((doc) => Loan.fromJson(doc.data())).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching loans: $e');
    }
  }

  Future<void> fetchGroceries() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('groceries')
          .orderBy('date', descending: true)
          .get();

      _groceries = snapshot.docs
          .map((doc) => Grocery.fromJson(doc.data()))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching groceries: $e');
    }
  }

  /// Refresh currency rates from API
  Future<void> refreshCurrencyRates() async {
    _isRefreshingRates = true;
    notifyListeners();

    try {
      await _currencyService.fetchRates(base: _baseCurrency);

      // Update EUR to INR for backward compatibility
      _eurToInrRate = _currencyService.getRate('EUR', 'INR');

      debugPrint('✅ Currency rates refreshed successfully');
    } catch (e) {
      debugPrint('❌ Error refreshing currency rates: $e');
    } finally {
      _isRefreshingRates = false;
      notifyListeners();
    }
  }

  /// Convert amount between currencies
  double convertCurrency(double amount, String from, String to) {
    return _currencyService.convert(amount: amount, from: from, to: to);
  }

  /// Get exchange rate between two currencies
  double getExchangeRate(String from, String to) {
    return _currencyService.getRate(from, to);
  }

  /// Get currency symbol
  String getCurrencySymbol(String code) {
    return _currencyService.getCurrencySymbol(code);
  }

  /// Get currency name
  String getCurrencyName(String code) {
    return _currencyService.getCurrencyName(code);
  }

  /// Get list of supported currencies
  List<String> get supportedCurrencies => _currencyService.supportedCurrencies;

  void _loadMockData() {
    _expenses = [
      Expense(
        id: '1',
        description: 'Rent',
        amount: 450.00,
        date: DateTime.now().subtract(const Duration(days: 5)),
        category: 'Housing',
      ),
    ];
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    try {
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('expenses')
          .doc(expense.id)
          .set(expense.toJson());

      _expenses.insert(0, expense);
      _totalBalance -= expense.amount;
      await updateBalances(personal: _totalBalance);
    } catch (e) {
      debugPrint('Error adding expense: $e');
    }
  }

  Future<void> addLoan(Loan loan) async {
    try {
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('loans')
          .doc(loan.id)
          .set(loan.toJson());

      _loans.add(loan);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding loan: $e');
    }
  }

  Future<void> updateLoanPayment(String id, double amount) async {
    final index = _loans.indexWhere((l) => l.id == id);
    if (index != -1) {
      final loan = _loans[index];
      loan.remaining -= amount;
      loan.payments ??= [];
      loan.payments!.add(LoanPayment(amount: amount, date: DateTime.now()));

      if (loan.remaining <= 0) {
        loan.status = 'completed';
      }

      try {
        await _firestore
            .collection('users')
            .doc(_uid)
            .collection('loans')
            .doc(id)
            .update(loan.toJson());
        notifyListeners();
      } catch (e) {
        debugPrint('Error updating loan: $e');
      }
    }
  }

  Future<void> addGrocery(Grocery grocery) async {
    try {
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('groceries')
          .doc(grocery.id)
          .set(grocery.toJson());

      _groceries.insert(0, grocery);

      final exp = Expense(
        id: 'grocery_${grocery.id}',
        description: 'Grocery Shopping',
        amount: grocery.total,
        date: grocery.date,
        category: 'Food',
      );

      await addExpense(exp);
    } catch (e) {
      debugPrint('Error adding grocery: $e');
    }
  }

  double getMonthlySpending() {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.date.month == now.month && e.date.year == now.year)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  Map<String, double> getCategorySpending() {
    Map<String, double> summary = {};
    for (var expense in _expenses) {
      summary[expense.category] =
          (summary[expense.category] ?? 0.0) + expense.amount;
    }
    return summary;
  }
}
