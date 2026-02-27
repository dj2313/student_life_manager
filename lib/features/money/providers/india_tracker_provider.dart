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

  String? get _uid => _auth.currentUser?.uid;

  IndiaTrackerProvider() {
    fetchData();
  }

  Future<void> fetchData() async {
    final uid = _uid;
    if (uid == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Fetch Items
      final itemsSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('india_items')
          .get();

      _items = itemsSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return IndiaItem.fromJson(data);
      }).toList();
      _items.sort((a, b) => b.date.compareTo(a.date));

      // Fetch Travel Expenses
      final expensesSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('india_travel_expenses')
          .orderBy('date', descending: true)
          .get();

      _travelExpenses = expensesSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return IndiaTravelExpense.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching India tracker data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addItem(IndiaItem item) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('india_items')
          .doc(item.id)
          .set(item.toJson());
      _items.insert(0, item);
      _items.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding India item: $e');
    }
  }

  Future<void> updateItem(IndiaItem item) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('india_items')
          .doc(item.id)
          .update(item.toJson());

      final index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _items[index] = item;
        _items.sort((a, b) => b.date.compareTo(a.date));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating India item: $e');
    }
  }

  Future<void> deleteItem(String id) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(uid)
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
    final uid = _uid;
    if (uid == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('india_travel_expenses')
          .doc(expense.id)
          .set(expense.toJson());
      _travelExpenses.insert(0, expense);
      _travelExpenses.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding travel expense: $e');
    }
  }

  Future<void> updateTravelExpense(IndiaTravelExpense expense) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('india_travel_expenses')
          .doc(expense.id)
          .update(expense.toJson());

      final index = _travelExpenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        _travelExpenses[index] = expense;
        _travelExpenses.sort((a, b) => b.date.compareTo(a.date));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating travel expense: $e');
    }
  }

  Future<void> deleteTravelExpense(String id) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('india_travel_expenses')
          .doc(id)
          .delete();
      _travelExpenses.removeWhere((exp) => exp.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting travel expense: $e');
    }
  }

  double get totalItemValueEur =>
      _items.fold(0, (sum, item) => sum + item.valueEur);
  double get totalTravelExpenseEur =>
      _travelExpenses.fold(0, (sum, exp) => sum + exp.amountEur);

  double get readinessScore {
    double score = 0;
    // 60% for Travel Essentials (20% each)
    final essentialTypes = ['Flight', 'Visa', 'Insurance'];
    for (final type in essentialTypes) {
      if (_travelExpenses.any(
        (e) => e.type.toLowerCase() == type.toLowerCase(),
      )) {
        score += 0.20;
      }
    }

    // 40% for Inventory Prep (13.3% each for major categories)
    final majorCategories = ['Clothes', 'Food', 'Electronics'];
    for (final cat in majorCategories) {
      if (_items.any((i) => i.category.toLowerCase() == cat.toLowerCase())) {
        score += 0.133;
      }
    }

    return score.clamp(0.0, 1.0);
  }
}
