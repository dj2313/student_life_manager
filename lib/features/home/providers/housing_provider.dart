import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/student_os_models.dart';

class HousingProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<HousingApplication> _applications = [];
  List<HousingDeposit> _deposits = [];

  List<HousingApplication> get applications => _applications;
  List<HousingDeposit> get deposits => _deposits;

  String? get _uid => _auth.currentUser?.uid;

  HousingProvider() {
    _init();
  }

  Future<void> _init() async {
    await fetchHousingData();
  }

  Future<void> fetchHousingData() async {
    final uid = _uid;
    if (uid == null) return;

    try {
      final appSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('housing_applications')
          .orderBy('appliedDate', descending: true)
          .get();

      _applications = appSnapshot.docs
          .map((d) => HousingApplication.fromJson({...d.data(), 'id': d.id}))
          .toList();

      final depositSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('housing_deposits')
          .orderBy('datePaid', descending: true)
          .get();

      _deposits = depositSnapshot.docs
          .map((d) => HousingDeposit.fromJson({...d.data(), 'id': d.id}))
          .toList();

      if (_applications.isEmpty && _deposits.isEmpty) {
        _loadMockData();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching housing data: $e');
      _loadMockData();
    }
  }

  void _loadMockData() {
    _applications = [
      HousingApplication(
        id: 'mock_1',
        title: 'Cozy Room in Berlin Mitte',
        platform: 'WG-Gesucht',
        location: 'Berlin Mitte',
        price: 450.0,
        status: 'Applied',
        appliedDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
    _deposits = [
      HousingDeposit(
        id: 'mock_dep_1',
        amount: 1200.0,
        datePaid: DateTime(2023, 10, 1),
        propertyAddress: 'Stendaler Str. 12, Berlin',
        isReturned: false,
      ),
    ];
    notifyListeners();
  }
  Future<void> addApplication(HousingApplication app) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(uid)
          .collection('housing_applications')
          .add(app.toJson());

      _applications.insert(
        0,
        HousingApplication(
          id: docRef.id,
          title: app.title,
          platform: app.platform,
          location: app.location,
          price: app.price,
          status: app.status,
          appliedDate: app.appliedDate,
          url: app.url,
        ),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding application: $e');
    }
  }

  Future<void> updateApplicationStatus(String id, String status) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('housing_applications')
          .doc(id)
          .update({'status': status});

      final index = _applications.indexWhere((app) => app.id == id);
      if (index != -1) {
        _applications[index] = HousingApplication(
          id: _applications[index].id,
          title: _applications[index].title,
          platform: _applications[index].platform,
          location: _applications[index].location,
          price: _applications[index].price,
          status: status,
          appliedDate: _applications[index].appliedDate,
          url: _applications[index].url,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating application status: $e');
    }
  }
  Future<void> addDeposit(HousingDeposit deposit) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(uid)
          .collection('housing_deposits')
          .add(deposit.toJson());

      _deposits.insert(
        0,
        HousingDeposit(
          id: docRef.id,
          amount: deposit.amount,
          datePaid: deposit.datePaid,
          propertyAddress: deposit.propertyAddress,
          isReturned: deposit.isReturned,
          expectedReturnType: deposit.expectedReturnType,
        ),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding deposit: $e');
    }
  }

  Future<void> toggleDepositReturned(String id) async {
    final index = _deposits.indexWhere((d) => d.id == id);
    if (index != -1) {
      final newValue = !_deposits[index].isReturned;
      final uid = _uid;
      if (uid == null) return;
      try {
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('housing_deposits')
            .doc(id)
            .update({'isReturned': newValue});

        _deposits[index] = HousingDeposit(
          id: _deposits[index].id,
          amount: _deposits[index].amount,
          datePaid: _deposits[index].datePaid,
          propertyAddress: _deposits[index].propertyAddress,
          isReturned: newValue,
          expectedReturnType: _deposits[index].expectedReturnType,
        );
        notifyListeners();
      } catch (e) {
        debugPrint('Error toggling deposit return: $e');
      }
    }
  }

  double get totalPotentialReturn =>
      _deposits.where((d) => !d.isReturned).fold(0, (sum, d) => sum + d.amount);
}
