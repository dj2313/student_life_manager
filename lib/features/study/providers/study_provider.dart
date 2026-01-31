import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/lecture.dart';
import '../../../data/models/study_models.dart';
import '../../../data/models/university.dart';

class StudyProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _germanLevel = 'A2';
  double _hoursLoggedThisWeek = 8;
  double _weeklyTargetHours = 12;
  double _germanClassFees = 250.0;
  Map<String, DateTime> _examDates = {'A1': DateTime(2026, 2, 16)};

  Map<String, String> _germanProgress = {
    'A1': 'Cleared',
    'A2': 'Completed',
    'B1': 'Pending',
    'B2': 'Pending',
    'C1': 'Pending',
    'C2': 'Pending',
  };

  List<Lecture> _todayLectures = [];
  List<GermanSession> _sessions = [];
  List<StudyGoal> _goals = [];
  List<University> _universities = [];

  String get germanLevel => _germanLevel;
  Map<String, String> get germanProgress => _germanProgress;
  double get hoursLoggedThisWeek => _hoursLoggedThisWeek;
  double get weeklyTargetHours => _weeklyTargetHours;
  double get germanClassFees => _germanClassFees;
  Map<String, DateTime> get examDates => _examDates;
  List<Lecture> get todayLectures => _todayLectures;
  List<GermanSession> get sessions => _sessions;
  List<StudyGoal> get goals => _goals;
  List<University> get universities => _universities;

  String get _uid => _auth.currentUser?.uid ?? 'guest_user';

  StudyProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      if (_auth.currentUser == null) {
        await _auth.signInAnonymously();
      }
      await fetchUniversities();
      _loadMockData();
    } catch (e) {
      debugPrint('StudyProvider Initialization Error: $e');
      _loadMockData();
    }
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
        uniType: 'Private', // Changed one to Private for testing
        subject: 'Computer Science',
        dayOfWeek: DateTime.now().weekday,
        time: '14:00',
        room: 'Lab 1',
        professor: 'Dr. Muller',
      ),
    ];

    _goals = [
      StudyGoal(
        id: '1',
        title: 'Complete A2 Grammar',
        deadline: DateTime.now().add(const Duration(days: 30)),
        targetProgress: 100,
        currentProgress: 65,
      ),
    ];

    _sessions = [
      GermanSession(
        id: 's1',
        date: DateTime.now().subtract(const Duration(days: 1)),
        durationHours: 2,
        topicsCovered: 'Verbs with Dativ',
      ),
      GermanSession(
        id: 's2',
        date: DateTime.now().subtract(const Duration(days: 2)),
        durationHours: 1.5,
        topicsCovered: 'Listening B1 level',
      ),
    ];

    notifyListeners();
  }

  void logSession(GermanSession session) {
    _sessions.insert(0, session);
    _hoursLoggedThisWeek += session.durationHours;
    notifyListeners();
  }

  void updateGoal(String id, double progress) {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index != -1) {
      _goals[index].currentProgress = progress;
      notifyListeners();
    }
  }

  // University Management
  Future<void> fetchUniversities() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('universities')
          .orderBy('name', descending: false)
          .get();

      _universities = snapshot.docs.map((doc) {
        return University.fromJson({...doc.data(), 'id': doc.id});
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching universities: $e');
    }
  }

  List<University> getUniversitiesByType(String type) {
    return _universities.where((uni) => uni.type == type).toList();
  }

  Future<void> addUniversity(University university) async {
    try {
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('universities')
          .doc(university.id)
          .set(university.toJson());

      _universities.add(university);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding university: $e');
    }
  }

  void updateGermanFees(double fees) {
    _germanClassFees = fees;
    notifyListeners();
  }

  void updateExamDate(String level, DateTime date) {
    _examDates[level] = date;
    notifyListeners();
  }

  Future<void> updateUniversity(String id, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('universities')
          .doc(id)
          .update(updates);

      final index = _universities.indexWhere((uni) => uni.id == id);
      if (index != -1) {
        _universities[index] = University.fromJson({
          ..._universities[index].toJson(),
          ...updates,
        });
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating university: $e');
    }
  }

  Future<void> deleteUniversity(String id) async {
    try {
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('universities')
          .doc(id)
          .delete();

      _universities.removeWhere((uni) => uni.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting university: $e');
    }
  }
}
