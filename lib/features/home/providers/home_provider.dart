import 'package:flutter/material.dart';
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
  String _userName = 'Student User';
  final String _visaStatus = 'Active';
  final int _visaDaysRemaining = 5;

  // Weather Info
  String _locationName = 'Berlin';
  String _temperature = '8°C';
  String _weatherCondition = 'Partly Cloudy';
  IconData _weatherIcon = Icons.cloud_queue_rounded;

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

  HomeProvider() {
    _loadMockData();
  }

  void updateUserName(String name) {
    _userName = name;
    notifyListeners();
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
      Ticket(
        id: '2',
        type: 'Bus',
        route: 'Campus → City',
        date: DateTime.now(),
        time: '10:30',
        ticketNumber: 'Bus 124',
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
      BureaucracyTask(
        title: 'Bank Entry',
        isCompleted: false,
        icon: Icons.account_balance_outlined,
      ),
      BureaucracyTask(
        title: 'Immatriculation',
        isCompleted: true,
        icon: Icons.school_outlined,
      ),
    ];

    notifyListeners();
  }
}
