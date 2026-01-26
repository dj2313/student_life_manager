import 'package:flutter/material.dart';
import '../../../data/models/ticket.dart';

class HomeProvider extends ChangeNotifier {
  String _userName = 'Student User';
  final String _visaStatus = 'Active';
  final int _visaDaysRemaining = 5;

  List<Ticket> _activeTickets = [];

  String get userName => _userName;
  String get visaStatus => _visaStatus;
  int get visaDaysRemaining => _visaDaysRemaining;
  List<Ticket> get activeTickets => _activeTickets;

  HomeProvider() {
    _loadMockData();
  }

  void updateUserName(String name) {
    _userName = name;
    notifyListeners();
  }

  void _loadMockData() {
    // Simulating loading data
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
    notifyListeners();
  }
}
