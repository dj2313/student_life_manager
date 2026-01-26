import 'package:flutter/material.dart';
import '../../../data/models/lecture.dart';

class StudyProvider with ChangeNotifier {
  double _hoursLogged = 12.5;
  List<Lecture> _todayLectures = [];

  double get hoursLogged => _hoursLogged;
  List<Lecture> get todayLectures => _todayLectures;

  StudyProvider() {
    _loadMockData();
  }

  void _loadMockData() {
    _todayLectures = [
      Lecture(
        id: '1',
        uniType: 'Public',
        subject: 'German A2',
        dayOfWeek: DateTime.now().weekday,
        time: '10:00',
        room: 'Room 302',
        professor: 'Kalpesh Sir',
      ),
      Lecture(
        id: '2',
        uniType: 'Public',
        subject: 'Data Structures',
        dayOfWeek: DateTime.now().weekday,
        time: '14:00',
        room: 'Audimax',
        professor: 'Dr. Muller',
      ),
    ];
    notifyListeners();
  }

  void logHours(double hours) {
    _hoursLogged += hours;
    notifyListeners();
  }
}
