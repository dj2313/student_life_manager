import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/ticket.dart';

class BureaucracyTask {
  final String title;
  final bool isCompleted;
  final IconData icon;

  BureaucracyTask({
    required this.title,
    required this.isCompleted,
    required this.icon,
  });
}

class HomeProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _userName = 'Student User';
  final String _visaStatus = 'Active';
  final int _visaDaysRemaining = 5;

  // Weather & Residency Info
  String _locationName = 'Berlin';
  final String _temperature = '8°C';
  final String _weatherCondition = 'Partly Cloudy';
  final IconData _weatherIcon = Icons.cloud_queue_rounded;

  List<Ticket> _activeTickets = [];
  List<BureaucracyTask> _bureaucracyTasks = [];

  String get userName => _userName;
  String get visaStatus => _visaStatus;
  int get visaDaysRemaining => _visaDaysRemaining;
  List<Ticket> get activeTickets => _activeTickets;
  List<BureaucracyTask> get bureaucracyTasks => _bureaucracyTasks;

  String get locationName => _locationName;
  String get temperature => _temperature;
  String get weatherCondition => _weatherCondition;
  IconData get weatherIcon => _weatherIcon;

  String get _uid => _auth.currentUser?.uid ?? 'guest_user';

  HomeProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      if (_auth.currentUser == null) {
        await _auth.signInAnonymously();
      }
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
        _userName = data['name'] ?? 'Student User';
        _locationName = data['location'] ?? 'Berlin';
        // Add more fields if needed
        notifyListeners();
      }

      // For now, if lists are empty, load mock data to ensure visibility
      if (_bureaucracyTasks.isEmpty || _activeTickets.isEmpty) {
        _loadMockData();
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      _loadMockData();
    }
  }

  Future<void> updateLocation(String location) async {
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

    _bureaucracyTasks = [
      BureaucracyTask(
        title: 'Anmeldung',
        isCompleted: true,
        icon: Icons.home_work_outlined,
      ),
      BureaucracyTask(
        title: 'TK Insurance',
        isCompleted: false,
        icon: Icons.health_and_safety_outlined,
      ),
    ];

    notifyListeners();
  }

  void toggleBureaucracyTask(int index) {
    if (index >= 0 && index < _bureaucracyTasks.length) {
      final task = _bureaucracyTasks[index];
      _bureaucracyTasks[index] = BureaucracyTask(
        title: task.title,
        isCompleted: !task.isCompleted,
        icon: task.icon,
      );
      notifyListeners();
    }
  }
}
