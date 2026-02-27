import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/ticket.dart';

class HomeProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  dynamic _authSubscription;
  dynamic _userDocumentSubscription;

  String _userName = 'Student';
  DateTime? _visaExpiryDate;
  String? _visaDocumentUrl;

  // Weather & Residency Info
  String _locationName = 'Berlin';
  final String _temperature = '8°C';
  final String _weatherCondition = 'Partly Cloudy';
  final IconData _weatherIcon = Icons.cloud_queue_rounded;

  List<Ticket> _activeTickets = [];
  bool _notificationsEnabled = true;
  bool _remindersEnabled = true;

  String get userName => _userName;
  DateTime? get visaExpiryDate => _visaExpiryDate;
  String? get visaDocumentUrl => _visaDocumentUrl;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get remindersEnabled => _remindersEnabled;

  String get visaStatus {
    if (_visaExpiryDate == null) return 'Not Set';
    final days = _visaExpiryDate!.difference(DateTime.now()).inDays;
    if (days < 0) return 'Expired';
    if (days < 30) return 'Expiring Soon';
    return 'Active';
  }

  int get visaDaysRemaining {
    if (_visaExpiryDate == null) return 0;
    final days = _visaExpiryDate!.difference(DateTime.now()).inDays;
    return days < 0 ? 0 : days;
  }

  List<Ticket> get activeTickets => _activeTickets;

  String get locationName => _locationName;
  String get temperature => _temperature;
  String get weatherCondition => _weatherCondition;
  IconData get weatherIcon => _weatherIcon;

  String get _uid => _auth.currentUser?.uid ?? 'guest_user';

  HomeProvider() {
    _init();
    _authSubscription = _auth.authStateChanges().listen((user) {
      _userDocumentSubscription?.cancel();
      if (user != null) {
        // Set initial name from Auth while waiting for Firestore
        _userName = user.displayName ?? 'Student';
        notifyListeners();
        _listenToUserDocument(user.uid);
      } else {
        _userName = 'Guest';
        _visaExpiryDate = null;
        notifyListeners();
      }
    });
  }

  void _listenToUserDocument(String uid) {
    _userDocumentSubscription = _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((doc) {
          if (doc.exists && doc.data() != null) {
            final data = doc.data()!;
            _userName =
                data['name'] ?? _auth.currentUser?.displayName ?? 'Student';
            _locationName = data['location'] ?? 'Berlin';
            if (data['visaExpiryDate'] != null) {
              _visaExpiryDate = (data['visaExpiryDate'] as Timestamp).toDate();
            }
            _visaDocumentUrl = data['visaDocumentUrl'];
            _notificationsEnabled = data['notificationsEnabled'] ?? true;
            _remindersEnabled = data['remindersEnabled'] ?? true;
            notifyListeners();
          }
        });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _userDocumentSubscription?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      await fetchUserData();
    } catch (e) {
      debugPrint('HomeProvider Initialization Error: $e');
      _loadMockData();
    }
  }

  Future<void> fetchUserData() async {
    try {
      final doc = await _firestore.collection('users').doc(_uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        _userName = data['name'] ?? _auth.currentUser?.displayName ?? 'Student';
        _locationName = data['location'] ?? 'Berlin';
        if (data['visaExpiryDate'] != null) {
          _visaExpiryDate = (data['visaExpiryDate'] as Timestamp).toDate();
        }
        _visaDocumentUrl = data['visaDocumentUrl'];
        _notificationsEnabled = data['notificationsEnabled'] ?? true;
        _remindersEnabled = data['remindersEnabled'] ?? true;

        notifyListeners();
      }

      if (_activeTickets.isEmpty) {
        _loadMockData();
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      _loadMockData();
    }
  }

  Future<void> updateLocation(String location) async {
    if (_locationName == location) return;
    try {
      _locationName = location;
      await _firestore.collection('users').doc(_uid).set({
        'location': location,
      }, SetOptions(merge: true));
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating location: $e');
    }
  }

  Future<void> updateUserName(String name) async {
    try {
      _userName = name;
      await _firestore.collection('users').doc(_uid).set({
        'name': name,
      }, SetOptions(merge: true));
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating username: $e');
    }
  }

  Future<void> updateVisaExpiryDate(DateTime date) async {
    try {
      _visaExpiryDate = date;
      await _firestore.collection('users').doc(_uid).set({
        'visaExpiryDate': Timestamp.fromDate(date),
      }, SetOptions(merge: true));
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating visa expiry date: $e');
    }
  }

  Future<void> updateVisaDocumentUrl(String url) async {
    try {
      _visaDocumentUrl = url;
      await _firestore.collection('users').doc(_uid).set({
        'visaDocumentUrl': url,
      }, SetOptions(merge: true));
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating visa document URL: $e');
    }
  }

  Future<void> updateNotificationsEnabled(bool value) async {
    try {
      _notificationsEnabled = value;
      await _firestore.collection('users').doc(_uid).set({
        'notificationsEnabled': value,
      }, SetOptions(merge: true));
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating notifications status: $e');
    }
  }

  Future<void> updateRemindersEnabled(bool value) async {
    try {
      _remindersEnabled = value;
      await _firestore.collection('users').doc(_uid).set({
        'remindersEnabled': value,
      }, SetOptions(merge: true));
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating reminders status: $e');
    }
  }

  void _loadMockData() {
    _activeTickets = [
      Ticket(
        id: '1',
        type: 'Train',
        route: 'Berlin Hbf → Munich',
        date: DateTime.now(),
        time: '14:45',
        ticketNumber: 'ICE 592',
      ),
    ];

    notifyListeners();
  }
}
