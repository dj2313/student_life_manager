import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/india_tracker_models.dart';

class IndiaTrackerProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<IndiaItem> _items = [];
  List<IndiaTravelExpense> _travelExpenses = [];
  bool _isLoading = false;

  List<IndiaItem> get items => _items;
  List<IndiaTravelExpense> get travelExpenses => _travelExpenses;
  bool get isLoading => _isLoading;

  String get _uid => _auth.currentUser?.uid ?? 'guest_user';

  IndiaTrackerProvider() {
    fetchData();
  }

  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch Items
      final itemsSnapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('india_items')
          .get();

      _items = itemsSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return IndiaItem.fromJson(data);
      }).toList();

      // Fetch Travel Expenses
      final expensesSnapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('india_travel_expenses')
          .orderBy('date', descending: true)
          .get();

      _travelExpenses = expensesSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return IndiaTravelExpense.fromJson(data);
      }).toList();

      if (_items.isEmpty && _travelExpenses.isEmpty) {
        _loadMockData();
      }
    } catch (e) {
      debugPrint('Error fetching India tracker data: $e');
      _loadMockData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _loadMockData() {
    _items = [
      IndiaItem(
        id: '1',
        name: 'Jeans',
        category: 'Clothes',
        quantity: 3,
        valueInr: 3000,
        valueEur: 33,
      ),
      IndiaItem(
        id: '2',
        name: 'Shirts',
        category: 'Clothes',
        quantity: 5,
        valueInr: 2500,
        valueEur: 28,
      ),
      IndiaItem(
        id: '3',
        name: 'Masalas & Spices',
        category: 'Food',
        quantity: 1,
        valueInr: 1500,
        valueEur: 17,
      ),
      IndiaItem(
        id: '4',
        name: 'Laptop bag',
        category: 'Electronics',
        quantity: 1,
        valueInr: 2000,
        valueEur: 22,
      ),
    ];

    _travelExpenses = [
      IndiaTravelExpense(
        id: 'e1',
        title: 'Air India Flight',
        description: 'New Delhi to Berlin via Frankfurt',
        amountInr: 65000,
        amountEur: 720,
        date: DateTime.now().subtract(const Duration(days: 15)),
        type: 'Flight',
      ),
      IndiaTravelExpense(
        id: 'e2',
        title: 'Visa Application',
        description: 'VFS Global National Visa',
        amountInr: 8000,
        amountEur: 90,
        date: DateTime.now().subtract(const Duration(days: 45)),
        type: 'Visa',
      ),
    ];
    notifyListeners();
  }

  Future<void> addItem(IndiaItem item) async {
    try {
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('india_items')
          .doc(item.id)
          .set(item.toJson());
      _items.insert(0, item);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding India item: $e');
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('india_items')
          .doc(id)
          .delete();
      _items.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting India item: $e');
    }
  }

  Future<void> addTravelExpense(IndiaTravelExpense expense) async {
    try {
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('india_travel_expenses')
          .doc(expense.id)
          .set(expense.toJson());
      _travelExpenses.insert(0, expense);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding travel expense: $e');
    }
  }

  double get totalItemValueEur =>
      _items.fold(0, (sum, item) => sum + item.valueEur);
  double get totalTravelExpenseEur =>
      _travelExpenses.fold(0, (sum, exp) => sum + exp.amountEur);
}
